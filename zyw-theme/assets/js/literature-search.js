(function () {
  "use strict";

  var PAGE_SIZE = 10;
  var MAX_PER_SOURCE = 60;
  var MAX_KEYWORDS = 12;
  var MAX_KEYWORD_LENGTH = 80;
  var MAX_KEYWORD_INPUT_LENGTH = 320;
  var SEARCH_COOLDOWN_MS = 4000;
  var RATE_WINDOW_MS = 5 * 60 * 1000;
  var MAX_SEARCHES_PER_WINDOW = 8;
  var MAX_SEARCHES_PER_SESSION = 30;
  var STORAGE_KEY = "literatureRateStateV1";

  var fallbackProfiles = {
    "data-provenance": {
      keywords: ["data science", "provenance", "traceability"],
      lookbackDays: 365,
    },
    "llm-governance": {
      keywords: ["large language model", "governance", "safety"],
      lookbackDays: 365,
    },
    "supply-chain-security": {
      keywords: ["software supply chain", "provenance", "integrity"],
      lookbackDays: 730,
    },
    custom: {
      keywords: ["data science", "provenance"],
      lookbackDays: 365,
    },
  };

  function parseJsonScript(id, fallbackValue) {
    var node = document.getElementById(id);
    if (!node || !node.textContent) {
      return fallbackValue;
    }
    try {
      return JSON.parse(node.textContent);
    } catch (err) {
      return fallbackValue;
    }
  }

  var configuredProfiles = parseJsonScript("literature-profiles-json", null);
  var profiles =
    configuredProfiles &&
    typeof configuredProfiles === "object" &&
    Object.keys(configuredProfiles).length > 0
      ? configuredProfiles
      : fallbackProfiles;
  var configuredDefaultProfile = parseJsonScript(
    "literature-default-profile",
    "data-provenance"
  );

  var state = {
    rows: [],
    page: 1,
    keywords: [],
    matchMode: "all",
    sourceErrors: [],
    security: {
      timestamps: [],
      lastRunAt: 0,
      sessionCount: 0,
      blockUntil: 0,
      failureStreak: 0,
    },
  };

  var els = {
    focusProfile: document.getElementById("focusProfile"),
    matchMode: document.getElementById("matchMode"),
    keywordInput: document.getElementById("keywordInput"),
    dateRangeInput: document.getElementById("dateRangeInput"),
    srcOpenAlex: document.getElementById("srcOpenAlex"),
    srcCrossref: document.getElementById("srcCrossref"),
    runSearch: document.getElementById("runSearch"),
    resetForm: document.getElementById("resetForm"),
    statusText: document.getElementById("statusText"),
    resultMeta: document.getElementById("resultMeta"),
    resultList: document.getElementById("resultList"),
    emptyState: document.getElementById("emptyState"),
    pagination: document.getElementById("pagination"),
  };

  if (!els.focusProfile || !els.runSearch || !els.resetForm) {
    return;
  }

  function toISODate(daysAgo) {
    var date = new Date();
    date.setDate(date.getDate() - daysAgo);
    var year = date.getFullYear();
    var month = String(date.getMonth() + 1).padStart(2, "0");
    var day = String(date.getDate()).padStart(2, "0");
    return year + "-" + month + "-" + day;
  }

  function getSearchFromDate() {
    if (els.dateRangeInput && els.dateRangeInput.value) {
      var parts = els.dateRangeInput.value.split(" - ");
      if (parts.length === 2 && parts[0]) {
        try {
          var startDate = window.moment(parts[0], "YYYY-MM-DD");
          if (startDate.isValid()) {
            return startDate.format("YYYY-MM-DD");
          }
        } catch (err) {
          // Fall through to default.
        }
      }
    }
    return toISODate(7);
  }

  function getSearchDateWindow() {
    var today = window.moment().startOf("day");
    var endDate = today.format("YYYY-MM-DD");
    var startDate = getSearchFromDate();

    if (els.dateRangeInput && els.dateRangeInput.value) {
      var parts = els.dateRangeInput.value.split(" - ");
      if (parts.length === 2) {
        var parsedStart = window.moment(parts[0], "YYYY-MM-DD", true);
        var parsedEnd = window.moment(parts[1], "YYYY-MM-DD", true);
        if (parsedStart.isValid() && parsedEnd.isValid()) {
          if (parsedStart.isAfter(today)) {
            parsedStart = today.clone();
          }
          if (parsedEnd.isAfter(today)) {
            parsedEnd = today.clone();
          }
          if (parsedStart.isAfter(parsedEnd)) {
            parsedStart = parsedEnd.clone();
          }

          startDate = parsedStart.format("YYYY-MM-DD");
          endDate = parsedEnd.format("YYYY-MM-DD");
        }
      }
    }

    return {
      startDate: startDate,
      endDate: endDate,
    };
  }

  function initializeDateRangePicker(daysLookback) {
    if (
      typeof window.moment === "undefined" ||
      typeof window.jQuery === "undefined"
    ) {
      return;
    }

    var today = window.moment().startOf("day");
    var startDate = today.clone().subtract(daysLookback || 7, "days");
    var endDate = today.clone();
    var $input = window.jQuery(els.dateRangeInput);

    function clampPickerDates(picker, maxDay) {
      if (!picker || !maxDay) {
        return;
      }

      var safeEnd =
        picker.endDate && picker.endDate.isAfter(maxDay)
          ? maxDay.clone()
          : picker.endDate || maxDay.clone();
      var safeStart =
        picker.startDate && picker.startDate.isAfter(safeEnd)
          ? safeEnd.clone()
          : picker.startDate || safeEnd.clone();

      picker.maxDate = maxDay.clone().endOf("day");
      picker.setStartDate(safeStart);
      picker.setEndDate(safeEnd);
      picker.updateCalendars();
      picker.updateView();
      picker.updateElement();
    }

    var isNarrowViewport =
      window.matchMedia && window.matchMedia("(max-width: 768px)").matches;

    if ($input.data("daterangepicker")) {
      var existingPicker = $input.data("daterangepicker");
      clampPickerDates(existingPicker, today.clone());
      existingPicker.setStartDate(startDate);
      existingPicker.setEndDate(endDate);
      existingPicker.updateCalendars();
      return;
    }

    $input.attr("readonly", true);

    $input.daterangepicker({
      startDate: startDate,
      endDate: endDate,
      maxDate: today.clone().endOf("day"),
      linkedCalendars: !isNarrowViewport,
      ranges: {
        "Last Year": [today.clone().subtract(364, "days"), today.clone()],
        "Last 90 Days": [today.clone().subtract(89, "days"), today.clone()],
        "Last 30 Days": [today.clone().subtract(29, "days"), today.clone()],
        "Last 7 Days": [today.clone().subtract(6, "days"), today.clone()],
        Yesterday: [today.clone().subtract(1, "days"), today.clone()],
        Today: [today.clone(), today.clone()],
      },
      locale: {
        format: "YYYY-MM-DD",
      },
      alwaysShowCalendars: true,
      autoUpdateInput: true,
    });

    $input.on("show.daterangepicker", function (event, picker) {
      var narrow =
        window.matchMedia && window.matchMedia("(max-width: 768px)").matches;
      clampPickerDates(picker, window.moment().startOf("day"));
      picker.linkedCalendars = !narrow;
      if (narrow) {
        picker.container.addClass("single-calendar-mobile");
      } else {
        picker.container.removeClass("single-calendar-mobile");
      }
      picker.updateCalendars();
    });

    $input.on("apply.daterangepicker", function (event, picker) {
      clampPickerDates(picker, window.moment().startOf("day"));
    });
  }

  function decodeHtmlEntities(value) {
    var input = String(value || "");
    if (!input) {
      return "";
    }
    var textarea = document.createElement("textarea");
    textarea.innerHTML = input;
    return textarea.value;
  }

  function sanitizeText(value) {
    return decodeHtmlEntities(value)
      .replace(/<[^>]*>/g, " ")
      .replace(/\s+/g, " ")
      .trim();
  }

  function hasUsableKeywords() {
    return splitKeywords(String(els.keywordInput.value || "")).length > 0;
  }

  function updateSearchAvailability() {
    var canSearch = hasUsableKeywords();
    els.runSearch.disabled = !canSearch;
    if (!canSearch) {
      updateStatus("Enter at least one keyword to enable search.");
    }
  }

  function nowMs() {
    return Date.now();
  }

  function bucketQueryLength(length) {
    if (length <= 20) {
      return "1-20";
    }
    if (length <= 60) {
      return "21-60";
    }
    return "61+";
  }

  function buildSourcesSelected() {
    var sources = [];
    if (els.srcOpenAlex && els.srcOpenAlex.checked) {
      sources.push("openalex");
    }
    if (els.srcCrossref && els.srcCrossref.checked) {
      sources.push("crossref");
    }
    return sources;
  }

  function trackAnalyticsEvent(name, params) {
    if (typeof window.gtag === "function") {
      window.gtag("event", name, params || {});
      return;
    }
    // Fallback for setups that consume dataLayer custom events via GTM.
    if (window.dataLayer && Array.isArray(window.dataLayer)) {
      window.dataLayer.push(Object.assign({ event: name }, params || {}));
    }
  }

  function guardrailErrorCode(message) {
    var text = String(message || "").toLowerCase();
    if (text.indexOf("select at least one source") !== -1) {
      return "no_source_selected";
    }
    if (text.indexOf("date") !== -1) {
      return "invalid_date_window";
    }
    return "guardrail_other";
  }

  function sourceErrorCode(messages) {
    var joined = String((messages || []).join(" | ") || "").toLowerCase();
    if (joined.indexOf("timeout") !== -1 || joined.indexOf("abort") !== -1) {
      return "source_timeout";
    }
    if (joined.indexOf("http") !== -1) {
      return "source_http_error";
    }
    if (joined.indexOf("parse") !== -1 || joined.indexOf("json") !== -1) {
      return "source_parse_error";
    }
    return "source_other";
  }

  function sleep(ms) {
    return new Promise(function (resolve) {
      setTimeout(resolve, ms);
    });
  }

  function pruneTimestamps(timestamps, currentTime) {
    return timestamps.filter(function (ts) {
      return currentTime - ts <= RATE_WINDOW_MS;
    });
  }

  function loadSecurityState() {
    try {
      var raw = sessionStorage.getItem(STORAGE_KEY);
      if (!raw) {
        return;
      }
      var parsed = JSON.parse(raw);
      if (!parsed || typeof parsed !== "object") {
        return;
      }
      var currentTime = nowMs();
      state.security.timestamps = pruneTimestamps(
        Array.isArray(parsed.timestamps) ? parsed.timestamps : [],
        currentTime
      );
      state.security.lastRunAt = Number(parsed.lastRunAt) || 0;
      state.security.sessionCount = Number(parsed.sessionCount) || 0;
      state.security.blockUntil = Number(parsed.blockUntil) || 0;
      state.security.failureStreak = Number(parsed.failureStreak) || 0;
    } catch (err) {
      // Ignore storage access failures.
    }
  }

  function saveSecurityState() {
    try {
      sessionStorage.setItem(STORAGE_KEY, JSON.stringify(state.security));
    } catch (err) {
      // Ignore storage access failures.
    }
  }

  function isLikelyAutomatedClient() {
    return typeof navigator !== "undefined" && navigator.webdriver === true;
  }

  function clampInputKeywords(keywords) {
    return keywords.slice(0, MAX_KEYWORDS).map(function (kw) {
      return kw.slice(0, MAX_KEYWORD_LENGTH);
    });
  }

  function validateSearchGuardrails(rawInput, keywords, selectedSources) {
    var currentTime = nowMs();
    state.security.timestamps = pruneTimestamps(
      state.security.timestamps,
      currentTime
    );

    if (isLikelyAutomatedClient()) {
      return "Automated browser context detected. Search requests are blocked for abuse protection.";
    }

    if (selectedSources < 1) {
      return "Select at least one source.";
    }

    if (rawInput.length > MAX_KEYWORD_INPUT_LENGTH) {
      return (
        "Keyword input is too long. Please keep it under " +
        MAX_KEYWORD_INPUT_LENGTH +
        " characters."
      );
    }

    if (keywords.length > MAX_KEYWORDS) {
      return (
        "Too many keywords. Please use up to " + MAX_KEYWORDS + " keywords."
      );
    }

    var overlongKeyword = keywords.some(function (kw) {
      return kw.length > MAX_KEYWORD_LENGTH;
    });
    if (overlongKeyword) {
      return (
        "One or more keywords are too long. Keep each keyword under " +
        MAX_KEYWORD_LENGTH +
        " characters."
      );
    }

    if (state.security.blockUntil > currentTime) {
      var waitFor = Math.ceil((state.security.blockUntil - currentTime) / 1000);
      return (
        "Temporary protection window active. Please wait " +
        waitFor +
        "s and retry."
      );
    }

    if (
      state.security.lastRunAt &&
      currentTime - state.security.lastRunAt < SEARCH_COOLDOWN_MS
    ) {
      var cooldown = Math.ceil(
        (SEARCH_COOLDOWN_MS - (currentTime - state.security.lastRunAt)) / 1000
      );
      return "Please wait " + cooldown + "s before running another search.";
    }

    if (state.security.timestamps.length >= MAX_SEARCHES_PER_WINDOW) {
      var firstTs = state.security.timestamps[0];
      var waitSeconds = Math.ceil(
        (RATE_WINDOW_MS - (currentTime - firstTs)) / 1000
      );
      return (
        "Rate limit reached. Please wait " + waitSeconds + "s before retrying."
      );
    }

    if (state.security.sessionCount >= MAX_SEARCHES_PER_SESSION) {
      return "Session limit reached. Please refresh the page before continuing.";
    }

    return "";
  }

  function registerSearchAttempt(success) {
    var currentTime = nowMs();
    state.security.timestamps = pruneTimestamps(
      state.security.timestamps,
      currentTime
    );
    state.security.timestamps.push(currentTime);
    state.security.lastRunAt = currentTime;
    state.security.sessionCount += 1;

    if (success) {
      state.security.failureStreak = 0;
      state.security.blockUntil = 0;
    } else {
      state.security.failureStreak += 1;
      if (state.security.failureStreak >= 3) {
        var backoffSeconds = Math.min(60, 10 * state.security.failureStreak);
        state.security.blockUntil = currentTime + backoffSeconds * 1000;
      }
    }

    saveSecurityState();
  }

  function isRetryableStatus(status) {
    return (
      status === 408 ||
      status === 425 ||
      status === 429 ||
      status === 500 ||
      status === 502 ||
      status === 503 ||
      status === 504
    );
  }

  async function fetchWithRetry(url, options, policy) {
    var attempts = (policy && policy.attempts) || 2;
    var timeoutMs = (policy && policy.timeoutMs) || 12000;
    var baseDelayMs = (policy && policy.baseDelayMs) || 500;
    var lastError;

    for (var attempt = 1; attempt <= attempts; attempt += 1) {
      var controller =
        typeof AbortController !== "undefined" ? new AbortController() : null;
      var timeoutId = null;
      if (controller) {
        timeoutId = setTimeout(function () {
          controller.abort();
        }, timeoutMs);
      }

      try {
        var merged = Object.assign({}, options || {});
        if (controller) {
          merged.signal = controller.signal;
        }

        var response = await fetch(url, merged);
        if (response.ok) {
          if (timeoutId) {
            clearTimeout(timeoutId);
          }
          return response;
        }

        if (!isRetryableStatus(response.status) || attempt === attempts) {
          throw new Error("HTTP " + response.status);
        }

        var retryAfter = Number(response.headers.get("retry-after"));
        var waitMs =
          Number.isFinite(retryAfter) && retryAfter > 0
            ? retryAfter * 1000
            : baseDelayMs * Math.pow(2, attempt - 1) +
              Math.floor(Math.random() * 250);
        if (timeoutId) {
          clearTimeout(timeoutId);
        }
        await sleep(waitMs);
      } catch (err) {
        if (timeoutId) {
          clearTimeout(timeoutId);
        }
        lastError = err;
        var isAbort = err && err.name === "AbortError";
        if (!isAbort && attempt === attempts) {
          break;
        }
        if (attempt < attempts) {
          var jitterMs =
            baseDelayMs * Math.pow(2, attempt - 1) +
            Math.floor(Math.random() * 250);
          await sleep(jitterMs);
        }
      }
    }

    throw lastError || new Error("Request failed");
  }

  function splitKeywords(raw) {
    return raw
      .split(",")
      .map(function (token) {
        return token.trim().toLowerCase();
      })
      .filter(function (token) {
        return token.length > 0;
      });
  }

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }

  function applyProfile(profileKey) {
    var profile =
      profiles[profileKey] || profiles.custom || fallbackProfiles.custom;
    if (profileKey === "custom") {
      els.keywordInput.value = "";
    } else {
      els.keywordInput.value = (profile.keywords || []).join(", ");
    }
    initializeDateRangePicker(profile.lookbackDays || 365);
    updateSearchAvailability();
  }

  function reconstructOpenAlexAbstract(indexObj) {
    if (!indexObj || typeof indexObj !== "object") {
      return "";
    }

    var pairs = [];
    Object.keys(indexObj).forEach(function (word) {
      var positions = indexObj[word] || [];
      positions.forEach(function (position) {
        pairs.push({ position: position, word: word });
      });
    });

    pairs.sort(function (a, b) {
      return a.position - b.position;
    });

    return pairs
      .map(function (item) {
        return item.word;
      })
      .join(" ");
  }

  function firstCrossrefDatePart(datePartsContainer) {
    if (
      !datePartsContainer ||
      !Array.isArray(datePartsContainer["date-parts"])
    ) {
      return null;
    }
    var datePart = datePartsContainer["date-parts"][0] || [];
    if (!datePart[0]) {
      return null;
    }
    return {
      year: String(datePart[0]),
      month: String(datePart[1] || 1).padStart(2, "0"),
      day: String(datePart[2] || 1).padStart(2, "0"),
    };
  }

  function extractCrossrefPublicationDate(item) {
    var preferredFields = [
      "published-print",
      "published-online",
      "issued",
      "published",
      "created",
    ];

    for (var i = 0; i < preferredFields.length; i += 1) {
      var candidate = firstCrossrefDatePart(item[preferredFields[i]]);
      if (candidate) {
        return candidate.year + "-" + candidate.month + "-" + candidate.day;
      }
    }

    return "";
  }

  function matchKeywords(text, keywords, mode) {
    var normalized = (text || "").toLowerCase();
    if (keywords.length === 0) {
      return true;
    }
    if (mode === "any") {
      return keywords.some(function (kw) {
        return normalized.indexOf(kw) !== -1;
      });
    }
    return keywords.every(function (kw) {
      return normalized.indexOf(kw) !== -1;
    });
  }

  async function fetchOpenAlex(keywords, fromDate, endDate) {
    var query = encodeURIComponent(keywords.join(" "));
    var filters = encodeURIComponent(
      "from_publication_date:" + fromDate + ",to_publication_date:" + endDate
    );
    var url =
      "https://api.openalex.org/works?search=" +
      query +
      "&filter=" +
      filters +
      "&per-page=" +
      MAX_PER_SOURCE +
      "&sort=publication_date:desc";

    var response = await fetchWithRetry(
      url,
      { headers: { Accept: "application/json" } },
      {
        attempts: 3,
        timeoutMs: 12000,
        baseDelayMs: 500,
      }
    );
    if (!response.ok) {
      throw new Error("OpenAlex request failed: HTTP " + response.status);
    }

    var payload = await response.json();
    return (payload.results || []).map(function (item) {
      var host =
        item.primary_location && item.primary_location.source
          ? item.primary_location.source.display_name
          : "OpenAlex";
      var title = sanitizeText(item.title) || "Untitled";
      var abstractText = reconstructOpenAlexAbstract(
        item.abstract_inverted_index
      );
      var authors = (item.authorships || [])
        .map(function (a) {
          return a.author && a.author.display_name ? a.author.display_name : "";
        })
        .filter(Boolean);

      return {
        id: String(item.id || ""),
        title: title,
        abstract: abstractText,
        authors: authors,
        source: "OpenAlex",
        url: item.doi
          ? "https://doi.org/" + item.doi.replace(/^https?:\/\/doi.org\//i, "")
          : item.primary_location
            ? item.primary_location.landing_page_url || ""
            : "",
        publishedAt: item.publication_date || "",
        venue: host,
        type: item.type || "article",
      };
    });
  }

  async function fetchCrossref(keywords, fromDate, endDate) {
    var query = encodeURIComponent(keywords.join(" "));
    var filter = encodeURIComponent(
      "from-pub-date:" + fromDate + ",until-pub-date:" + endDate
    );
    var url =
      "https://api.crossref.org/works?rows=" +
      MAX_PER_SOURCE +
      "&sort=published&order=desc&query.bibliographic=" +
      query +
      "&filter=" +
      filter +
      "&mailto=hello@zenithlaw.com";

    var response = await fetchWithRetry(
      url,
      { headers: { Accept: "application/json" } },
      {
        attempts: 3,
        timeoutMs: 12000,
        baseDelayMs: 500,
      }
    );
    if (!response.ok) {
      throw new Error("Crossref request failed: HTTP " + response.status);
    }

    var payload = await response.json();
    return ((payload.message && payload.message.items) || []).map(
      function (item) {
        var publicationDate = extractCrossrefPublicationDate(item);

        var abstractRaw = item.abstract || "";
        var abstractText = sanitizeText(abstractRaw);

        var typeLabel = item.type === "posted-content" ? "preprint" : "article";
        var container =
          (item["container-title"] && item["container-title"][0]) || "Crossref";
        var title = sanitizeText(item.title && item.title[0]) || "Untitled";
        var authors = (item.author || [])
          .map(function (a) {
            var given = a.given || "";
            var family = a.family || "";
            return (given + " " + family).trim();
          })
          .filter(Boolean);

        return {
          id: item.DOI || title,
          title: title,
          abstract: abstractText,
          authors: authors,
          source: "Crossref",
          url: item.URL || (item.DOI ? "https://doi.org/" + item.DOI : ""),
          publishedAt: publicationDate,
          venue: container,
          type: typeLabel,
        };
      }
    );
  }

  function formatDate(dateValue) {
    var normalized = normalizeDateValue(dateValue);
    if (!normalized) {
      return "Date unavailable";
    }
    return normalized;
  }

  function normalizeDateValue(dateValue) {
    var raw = String(dateValue || "").trim();
    if (!raw) {
      return "";
    }

    if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) {
      return raw;
    }

    if (/^\d{4}-\d{2}$/.test(raw)) {
      return raw + "-01";
    }

    if (/^\d{4}$/.test(raw)) {
      return raw + "-01-01";
    }

    var parsed = new Date(raw);
    if (isNaN(parsed.getTime())) {
      return "";
    }
    return parsed.toISOString().slice(0, 10);
  }

  function isWithinDateWindow(row, dateWindow) {
    if (!dateWindow || !dateWindow.startDate || !dateWindow.endDate) {
      return true;
    }

    var normalized = normalizeDateValue(row.publishedAt);
    if (!normalized) {
      return false;
    }

    return (
      normalized >= dateWindow.startDate && normalized <= dateWindow.endDate
    );
  }

  function safeUrl(urlValue) {
    var url = String(urlValue || "").trim();
    if (/^https?:\/\//i.test(url)) {
      return url;
    }
    return "#";
  }

  function sortRows(rows) {
    return rows.slice().sort(function (a, b) {
      var aTime = new Date(a.publishedAt || "1900-01-01").getTime();
      var bTime = new Date(b.publishedAt || "1900-01-01").getTime();
      return bTime - aTime;
    });
  }

  function renderPage() {
    var total = state.rows.length;
    var totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
    if (state.page > totalPages) {
      state.page = totalPages;
    }

    var start = (state.page - 1) * PAGE_SIZE;
    var end = start + PAGE_SIZE;
    var pageRows = state.rows.slice(start, end);

    els.resultList.innerHTML = "";
    pageRows.forEach(function (item, index) {
      var li = document.createElement("li");
      li.className =
        "rounded-xl border border-gray-200 bg-gray-50 p-4 dark:border-gray-700 dark:bg-gray-800";

      var title = document.createElement("h4");
      title.className =
        "m-0 text-base font-semibold text-gray-900 dark:text-gray-100";

      var link = document.createElement("a");
      link.href = safeUrl(item.url);
      link.target = "_blank";
      link.rel = "noopener noreferrer";
      link.className = "underline decoration-sky-400 underline-offset-2";
      link.textContent = item.title;
      link.addEventListener("click", function () {
        trackAnalyticsEvent("literature_result_click", {
          source: String(item.source || "unknown").toLowerCase(),
          result_rank: start + index + 1,
          page_number: state.page,
        });
      });
      title.appendChild(link);

      var meta = document.createElement("p");
      meta.className = "mt-2 mb-0 text-sm text-gray-700 dark:text-gray-300";
      meta.textContent =
        item.source +
        " | " +
        (item.venue || "Unknown venue") +
        " | " +
        formatDate(item.publishedAt) +
        " | " +
        item.type;

      var authors = document.createElement("p");
      authors.className = "mt-1 mb-0 text-sm text-gray-700 dark:text-gray-300";
      authors.textContent = item.authors.length
        ? item.authors.slice(0, 8).join(", ")
        : "Authors unavailable";

      var abs = document.createElement("p");
      abs.className =
        "mt-2 mb-0 text-sm leading-6 text-gray-800 dark:text-gray-200";
      abs.innerHTML = escapeHtml(
        item.abstract || "No abstract available."
      ).slice(0, 720);

      li.appendChild(title);
      li.appendChild(meta);
      li.appendChild(authors);
      li.appendChild(abs);
      els.resultList.appendChild(li);
    });

    els.emptyState.classList.toggle("hidden", pageRows.length > 0);

    els.resultMeta.textContent = total
      ? "Showing " +
        (start + 1) +
        "-" +
        Math.min(end, total) +
        " of " +
        total +
        " results"
      : "No results";

    renderPagination(totalPages);
  }

  function pageButton(label, targetPage, disabled) {
    var btn = document.createElement("button");
    btn.type = "button";
    btn.className =
      "rounded-md border px-3 py-1.5 text-sm " +
      (disabled
        ? "cursor-not-allowed border-gray-200 text-gray-400 dark:border-gray-700 dark:text-gray-600"
        : "border-gray-300 text-gray-700 hover:bg-gray-100 dark:border-gray-600 dark:text-gray-200 dark:hover:bg-gray-800");
    btn.textContent = label;
    btn.disabled = disabled;
    if (!disabled) {
      btn.addEventListener("click", function () {
        state.page = targetPage;
        renderPage();
        window.scrollTo({
          top: els.resultList.offsetTop - 80,
          behavior: "smooth",
        });
      });
    }
    return btn;
  }

  function renderPagination(totalPages) {
    els.pagination.innerHTML = "";
    if (totalPages <= 1) {
      return;
    }

    els.pagination.appendChild(
      pageButton("Prev", state.page - 1, state.page <= 1)
    );

    var start = Math.max(1, state.page - 2);
    var end = Math.min(totalPages, state.page + 2);
    for (var p = start; p <= end; p += 1) {
      var isCurrent = p === state.page;
      var btn = pageButton(String(p), p, false);
      if (isCurrent) {
        btn.className =
          "rounded-md border border-sky-600 bg-sky-600 px-3 py-1.5 text-sm text-white";
      }
      els.pagination.appendChild(btn);
    }

    els.pagination.appendChild(
      pageButton("Next", state.page + 1, state.page >= totalPages)
    );
  }

  function updateStatus(text) {
    els.statusText.textContent = text;
  }

  function filterRows(rows, keywords, mode, dateWindow) {
    return rows.filter(function (row) {
      var combined = (row.title || "") + " " + (row.abstract || "");
      return (
        matchKeywords(combined, keywords, mode) &&
        isWithinDateWindow(row, dateWindow)
      );
    });
  }

  async function runSearch() {
    var startedAt = nowMs();
    var rawInput = String(els.keywordInput.value || "").trim();
    var keywords = clampInputKeywords(splitKeywords(rawInput));
    var matchMode = els.matchMode.value || "all";

    if (keywords.length === 0) {
      updateStatus("Enter at least one keyword to run a search.");
      return;
    }

    var dateWindow = getSearchDateWindow();
    var fromDate = dateWindow.startDate;
    var endDate = dateWindow.endDate;
    var tasks = [];
    var sourceErrors = [];
    var sourcesSelected = buildSourcesSelected();
    var selectedSources = sourcesSelected.length;

    trackAnalyticsEvent("literature_search_run", {
      profile_key: String(els.focusProfile.value || "unknown"),
      match_mode: matchMode,
      sources_selected_count: selectedSources,
      sources_selected: sourcesSelected.join(","),
      date_window_days: Math.max(
        0,
        Math.round((new Date(endDate) - new Date(fromDate)) / 86400000)
      ),
      keyword_count: keywords.length,
      query_length_bucket: bucketQueryLength(rawInput.length),
    });

    var guardrailMessage = validateSearchGuardrails(
      rawInput,
      keywords,
      selectedSources
    );
    if (guardrailMessage) {
      trackAnalyticsEvent("literature_search_error", {
        error_type: "guardrail",
        error_code: guardrailErrorCode(guardrailMessage),
      });
      updateStatus(guardrailMessage);
      return;
    }

    updateStatus("Fetching literature sources...");
    els.runSearch.disabled = true;

    try {
      if (els.srcOpenAlex.checked) {
        tasks.push(
          fetchOpenAlex(keywords, fromDate, endDate).catch(function (err) {
            sourceErrors.push("OpenAlex: " + err.message);
            return [];
          })
        );
      }
      if (els.srcCrossref.checked) {
        tasks.push(
          fetchCrossref(keywords, fromDate, endDate).catch(function (err) {
            sourceErrors.push("Crossref: " + err.message);
            return [];
          })
        );
      }
      var chunks = await Promise.all(tasks);
      var merged = [].concat.apply([], chunks);
      var filtered = filterRows(merged, keywords, matchMode, dateWindow);

      state.rows = sortRows(filtered);
      state.page = 1;
      state.keywords = keywords;
      state.matchMode = matchMode;
      state.sourceErrors = sourceErrors;

      var hasSuccessfulSource = sourceErrors.length < selectedSources;
      registerSearchAttempt(hasSuccessfulSource);

      if (sourceErrors.length > 0) {
        trackAnalyticsEvent("literature_search_error", {
          error_type: "source",
          error_code: sourceErrorCode(sourceErrors),
          sources_failed_count: sourceErrors.length,
          sources_failed: sourceErrors.join(" | ").slice(0, 180),
        });
      }

      var durationMs = nowMs() - startedAt;
      var durationBucket = Math.max(0, Math.round(durationMs / 50) * 50);
      trackAnalyticsEvent(
        state.rows.length > 0
          ? "literature_search_results"
          : "literature_search_no_results",
        {
          result_count: state.rows.length,
          duration_ms: durationBucket,
          status: sourceErrors.length > 0 ? "partial" : "ok",
        }
      );

      if (sourceErrors.length > 0) {
        updateStatus(
          "Loaded with source warnings: " + sourceErrors.join(" | ")
        );
      } else {
        updateStatus("Loaded " + state.rows.length + " matching results.");
      }

      renderPage();
    } finally {
      els.runSearch.disabled = false;
    }
  }

  function resetForm() {
    els.focusProfile.value = configuredDefaultProfile;
    els.matchMode.value = "all";
    els.srcOpenAlex.checked = true;
    els.srcCrossref.checked = true;
    applyProfile(configuredDefaultProfile);
    state.rows = [];
    state.page = 1;
    state.sourceErrors = [];
    els.resultList.innerHTML = "";
    els.resultMeta.textContent = "";
    els.pagination.innerHTML = "";
    els.emptyState.classList.add("hidden");
    updateStatus("Form reset. Run a new search.");
  }

  els.focusProfile.addEventListener("change", function (event) {
    applyProfile(event.target.value);
  });
  els.keywordInput.addEventListener("input", updateSearchAvailability);
  els.runSearch.addEventListener("click", runSearch);
  els.resetForm.addEventListener("click", resetForm);

  applyProfile(configuredDefaultProfile);
  loadSecurityState();
  updateStatus("Ready. Choose sources and click Search Literature.");
  updateSearchAvailability();
})();
