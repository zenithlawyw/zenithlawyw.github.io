/**
 * Client-side PDF generation using pdfmake.
 * Replaces window.print() with proper font embedding for small file sizes.
 *
 * Usage: called from printArticle() in post.html
 * Dependencies: pdfmake + vfs_fonts (loaded from CDN on demand)
 */

(function () {
  "use strict";

  /* Lazy-load pdfmake, then its virtual-file-system fonts, from CDN.
     Fonts must load AFTER pdfmake so the assignment to pdfMake.vfs works. */
  var _loaded = false;
  var _loading = null;

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var s = document.createElement("script");
      s.src = src;
      s.onload = resolve;
      s.onerror = function () {
        reject(new Error("Failed to load " + src));
      };
      document.head.appendChild(s);
    });
  }

  function loadDeps() {
    if (_loaded) return Promise.resolve();
    if (_loading) return _loading;

    _loading = loadScript(
      "https://cdn.jsdelivr.net/npm/pdfmake@0.3.11/build/pdfmake.min.js"
    )
      .then(function () {
        return loadScript(
          "https://cdn.jsdelivr.net/npm/pdfmake@0.3.11/build/vfs_fonts.js"
        );
      })
      .then(function () {
        _loaded = true;
      });

    return _loading;
  }

  /* ── HTML → pdfmake conversion ── */

  /**
   * Walk the article DOM and produce a pdfmake content array.
   * Handles: paragraphs, headings, lists, code blocks, links, bold/italic,
   * tables, blockquotes, horizontal rules, and images (skipped for size).
   */
  function domToContent(el) {
    var nodes = [];
    var child = el.firstChild;
    while (child) {
      if (child.nodeType === 3) {
        /* Text node */
        var t = child.textContent;
        if (t.trim()) nodes.push(t);
      } else if (child.nodeType === 1) {
        var tag = child.tagName.toLowerCase();
        var style = window.getComputedStyle(child);

        /* Skip hidden elements */
        if (style.display === "none" || style.visibility === "hidden") {
          child = child.nextSibling;
          continue;
        }

        switch (tag) {
          case "h1":
            nodes.push({
              text: inlineText(child),
              style: "title",
              margin: [0, 20, 0, 8],
            });
            break;
          case "h2":
            nodes.push({
              text: inlineText(child),
              style: "heading",
              margin: [0, 16, 0, 6],
            });
            break;
          case "h3":
            nodes.push({
              text: inlineText(child),
              style: "subheading",
              margin: [0, 12, 0, 4],
            });
            break;
          case "h4":
          case "h5":
          case "h6":
            nodes.push({
              text: inlineText(child),
              style: "subheading",
              margin: [0, 10, 0, 4],
            });
            break;
          case "p":
            nodes.push({
              text: inlineText(child),
              margin: [0, 4, 0, 4],
            });
            break;
          case "ul":
            nodes.push(listToContent(child, false));
            break;
          case "ol":
            nodes.push(listToContent(child, true));
            break;
          case "blockquote":
            nodes.push({
              text: inlineText(child),
              margin: [20, 6, 0, 6],
              color: "#4b5563",
              italics: true,
            });
            break;
          case "pre":
            nodes.push(codeBlockToContent(child));
            break;
          case "table":
            nodes.push(tableToContent(child));
            break;
          case "hr":
            nodes.push({
              canvas: [
                {
                  type: "line",
                  x1: 0,
                  y1: 0,
                  x2: 515,
                  y2: 0,
                  lineWidth: 0.5,
                  lineColor: "#d1d5db",
                },
              ],
              margin: [0, 8, 0, 8],
            });
            break;
          case "figure":
          case "img":
          case "svg":
          case "video":
          case "iframe":
            /* Skip media for small file size */
            break;
          case "div":
          case "section":
          case "article":
          case "aside":
          case "nav":
          case "header":
          case "footer":
          case "main":
          case "details":
          case "summary":
            /* Recurse into structural elements */
            var inner = domToContent(child);
            if (inner.length) nodes.push.apply(nodes, inner);
            break;
          case "a":
            /* Standalone link (not inside a paragraph) */
            nodes.push({
              text: child.textContent.trim(),
              link: child.href,
              color: "#1d4ed8",
              margin: [0, 2, 0, 2],
            });
            break;
          case "span":
          case "strong":
          case "b":
          case "em":
          case "i":
          case "code":
          case "kbd":
          case "mark":
          case "small":
          case "sub":
          case "sup":
          case "del":
          case "s":
          case "u":
            /* Inline elements — handled by inlineText in parent */
            break;
          default:
            /* Unknown element — try to recurse */
            var fallback = domToContent(child);
            if (fallback.length) nodes.push.apply(nodes, fallback);
            break;
        }
      }
      child = child.nextSibling;
    }
    return nodes;
  }

  /** Extract inline text with formatting from an element. */
  function inlineText(el) {
    var parts = [];
    walkInline(el, parts);
    if (parts.length === 0) return el.textContent || "";
    if (parts.length === 1 && typeof parts[0] === "string") return parts[0];
    return parts;
  }

  function walkInline(node, acc) {
    var child = node.firstChild;
    while (child) {
      if (child.nodeType === 3) {
        var t = child.textContent;
        if (t) acc.push(t);
      } else if (child.nodeType === 1) {
        var tag = child.tagName.toLowerCase();
        switch (tag) {
          case "strong":
          case "b":
            acc.push({ text: child.textContent, bold: true });
            break;
          case "em":
          case "i":
            acc.push({ text: child.textContent, italics: true });
            break;
          case "code":
            acc.push({
              text: child.textContent,
              font: "Courier",
              fontSize: 9,
            });
            break;
          case "a":
            acc.push({
              text: child.textContent,
              link: child.href,
              color: "#1d4ed8",
              decoration: "underline",
            });
            break;
          case "br":
            acc.push("\n");
            break;
          case "span":
          case "kbd":
          case "mark":
          case "small":
          case "sub":
          case "sup":
          case "del":
          case "s":
          case "u":
            /* Recurse for inline formatting */
            walkInline(child, acc);
            break;
          default:
            walkInline(child, acc);
            break;
        }
      }
      child = child.nextSibling;
    }
  }

  /** Convert a <ul> or <ol> to pdfmake list. */
  function listToContent(listEl, ordered) {
    var items = [];
    var child = listEl.firstChild;
    while (child) {
      if (child.nodeType === 1 && child.tagName.toLowerCase() === "li") {
        var nested = [];
        var sub = child.firstChild;
        while (sub) {
          if (sub.nodeType === 1) {
            var st = sub.tagName.toLowerCase();
            if (st === "ul") nested.push(listToContent(sub, false));
            else if (st === "ol") nested.push(listToContent(sub, true));
          }
          sub = sub.nextSibling;
        }
        var item = { text: inlineText(child) };
        if (nested.length) item.nested = nested;
        items.push(item);
      }
      child = child.nextSibling;
    }
    return {
      ol: ordered ? items : undefined,
      ul: ordered ? undefined : items,
      margin: [0, 4, 0, 4],
    };
  }

  /** Convert a <pre><code> block to a pdfmake code block. */
  function codeBlockToContent(pre) {
    var code = pre.querySelector("code") || pre;
    var text = code.textContent || "";
    return {
      text: text,
      font: "Courier",
      fontSize: 8,
      color: "#374151",
      background: "#f3f4f6",
      margin: [8, 6, 8, 6],
      preservation: true,
    };
  }

  /** Convert a <table> to a pdfmake table. */
  function tableToContent(tableEl) {
    var rows = [];
    var child = tableEl.firstChild;
    while (child) {
      if (child.nodeType === 1) {
        var tag = child.tagName.toLowerCase();
        if (tag === "thead" || tag === "tbody" || tag === "tfoot") {
          var row = child.firstChild;
          while (row) {
            if (row.nodeType === 1 && row.tagName.toLowerCase() === "tr") {
              var cells = [];
              var cell = row.firstChild;
              while (cell) {
                if (cell.nodeType === 1) {
                  var ct = cell.tagName.toLowerCase();
                  if (ct === "td" || ct === "th") {
                    cells.push({
                      text: inlineText(cell),
                      bold: ct === "th",
                      margin: [4, 3, 4, 3],
                    });
                  }
                }
                cell = cell.nextSibling;
              }
              if (cells.length) rows.push(cells);
            }
            row = row.nextSibling;
          }
        } else if (tag === "tr") {
          var cells2 = [];
          var cell2 = child.firstChild;
          while (cell2) {
            if (cell2.nodeType === 1) {
              var ct2 = cell2.tagName.toLowerCase();
              if (ct2 === "td" || ct2 === "th") {
                cells2.push({
                  text: inlineText(cell2),
                  bold: ct2 === "th",
                  margin: [4, 3, 4, 3],
                });
              }
            }
            cell2 = cell2.nextSibling;
          }
          if (cells2.length) rows.push(cells2);
        }
      }
      child = child.nextSibling;
    }
    if (!rows.length) return { text: "" };
    return {
      table: {
        headerRows: tableEl.querySelector("thead") ? 1 : 0,
        widths: rows[0].map(function () {
          return "*";
        }),
        body: rows,
      },
      margin: [0, 6, 0, 6],
      layout: {
        hLineWidth: function (i) {
          return i === 0 || i === rows.length ? 0.5 : 0.25;
        },
        vLineWidth: function () {
          return 0.25;
        },
        hLineColor: function () {
          return "#d1d5db";
        },
        vLineColor: function () {
          return "#d1d5db";
        },
        paddingLeft: function () {
          return 4;
        },
        paddingRight: function () {
          return 4;
        },
        paddingTop: function () {
          return 3;
        },
        paddingBottom: function () {
          return 3;
        },
      },
    };
  }

  /* ── PDF generation ── */

  function getArticleMeta() {
    var title =
      (
        document.querySelector(".post-print-header h1") ||
        document.querySelector("h1") ||
        {}
      ).textContent || "Article";
    var author =
      (document.querySelector(".post-print-header .post-print-meta") || {})
        .textContent || "";
    var url =
      (document.querySelector(".post-print-header .post-print-url") || {})
        .textContent || window.location.href;
    return { title: title.trim(), author: author.trim(), url: url.trim() };
  }

  function generatePDF() {
    var article =
      document.querySelector(".post-main") ||
      document.querySelector("article") ||
      document.querySelector(".post");
    if (!article) {
      alert("Could not find article content.");
      return;
    }

    var meta = getArticleMeta();
    var content = domToContent(article);

    var docDefinition = {
      pageSize: "A4",
      pageMargins: [25, 20, 25, 25],
      defaultStyle: {
        font: "Roboto",
        fontSize: 10,
        lineHeight: 1.3,
        color: "#111827",
      },
      styles: {
        title: { fontSize: 18, bold: true, margin: [0, 0, 0, 4] },
        heading: { fontSize: 14, bold: true, margin: [0, 12, 0, 4] },
        subheading: { fontSize: 12, bold: true, margin: [0, 8, 0, 4] },
      },
      header: function () {
        return {
          text: meta.title,
          alignment: "right",
          fontSize: 7,
          color: "#9ca3af",
          margin: [0, 10, 20, 0],
        };
      },
      footer: function (currentPage, pageCount) {
        return {
          text: currentPage + " / " + pageCount,
          alignment: "center",
          fontSize: 7,
          color: "#9ca3af",
        };
      },
      content: content,
    };

    pdfMake
      .createPdf(docDefinition)
      .download(sanitizeFilename(meta.title) + ".pdf");
  }

  function sanitizeFilename(name) {
    return name
      .replace(/[^a-zA-Z0-9\s\-]/g, "")
      .replace(/\s+/g, " ")
      .trim()
      .substring(0, 120);
  }

  /* ── Public API ── */

  function generate() {
    var btn = document.querySelector(
      '[onclick="printArticle()"], [data-print-article]'
    );
    var originalText = btn ? btn.textContent : "";

    loadDeps()
      .then(function () {
        if (btn) btn.textContent = "Generating PDF…";
        generatePDF();
      })
      .catch(function (err) {
        console.error("PDF generation failed:", err);
        /* Fallback to browser print */
        window.print();
      })
      .finally(function () {
        if (btn) btn.textContent = originalText;
      });
  }

  /* Called by printArticle() in the post layout when available. */
  window.__zywGenerateArticlePdf = generate;

  /* Also expose printArticle for direct onclick usage. */
  window.printArticle = generate;
})();
