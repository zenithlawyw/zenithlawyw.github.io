// Debug: run the actual inlineText/walkInline/domToContent logic in the browser
// against real paragraphs and print what's produced, to find the AI->newline bug.
import puppeteer from "puppeteer";

const browser = await puppeteer.launch({
  headless: true,
  args: ["--no-sandbox"],
});
const page = await browser.newPage();

// Load the source of print-article.js functions by reading it and injecting
const fs = await import("fs");
const src = fs.readFileSync(
  "/Users/zenith/workspace/zenithlawyw.github.io/zyw-theme/assets/js/print-article.js",
  "utf8"
);

// Serve the built article
import http from "http";
import { createReadStream, statSync } from "fs";
import { join, extname } from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";
const __dirname = dirname(fileURLToPath(import.meta.url));
const SITE = join(__dirname, "..", "docs", "_site");
const PORT = 4311;
const MIME = {
  ".html": "text/html",
  ".js": "text/javascript",
  ".css": "text/css",
  ".png": "image/png",
  ".svg": "image/svg+xml",
  ".woff2": "font/woff2",
};
const server = http.createServer((req, res) => {
  let p = req.url.split("?")[0];
  const cand = [];
  if (p === "/") p = "/index.html";
  if (p.endsWith(".html")) cand.push(join(SITE, p));
  else {
    cand.push(join(SITE, p));
    cand.push(join(SITE, p + ".html"));
  }
  const f = cand.find((c) => {
    try {
      statSync(c);
      return true;
    } catch {
      return false;
    }
  });
  if (f) {
    res.writeHead(200, { "Content-Type": MIME[extname(f)] || "text/html" });
    createReadStream(f).pipe(res);
  } else {
    res.writeHead(404);
    res.end();
  }
});
await new Promise((r) => server.listen(PORT, r));

await page.goto(
  `http://localhost:${PORT}/xai20-open-challenges-future-directions`,
  { waitUntil: "networkidle0", timeout: 90000 }
);
await new Promise((r) => setTimeout(r, 1200));

// We need the actual script to have run so __zywGenerateArticlePdf exists,
// but its internal functions are in closures. Instead, re-run the extraction
// logic by evaluating our own copy via the page.
const out = await page.evaluate((srcText) => {
  // Build a fresh copy of the functions by evaluating the source,
  // but it auto-runs and overwrites things. Choose to instead inline a
  // standalone reproducer based on the published logic (walkInline-like).
  // We read the article paragraphs and simulate walkInline.
  const art =
    document.querySelector(".post-main article .post-content") ||
    document.querySelector(".post-main article");
  const walkInline = (node, acc) => {
    let child = node.firstChild;
    while (child) {
      if (child.nodeType === 3) {
        if (child.textContent) acc.push(child.textContent);
      } else if (child.nodeType === 1) {
        const tag = child.tagName.toLowerCase();
        if (tag === "strong" || tag === "b")
          acc.push({ text: child.textContent, bold: true });
        else if (tag === "em" || tag === "i")
          acc.push({ text: child.textContent, italics: true });
        else if (tag === "code")
          acc.push({ text: child.textContent, font: "Courier" });
        else if (tag === "a")
          acc.push({ text: child.textContent, link: child.href });
        else if (tag === "br") acc.push("\n");
        else walkInline(child, acc);
      }
      child = child.nextSibling;
    }
  };
  const inlineText = (el) => {
    const parts = [];
    walkInline(el, parts);
    return parts.length ? parts : el.textContent || "";
  };
  // Find paragraphs containing "AI" and show the inlineText result
  const results = [];
  const ps = art.querySelectorAll("p");
  for (let i = 0; i < ps.length && results.length < 12; i++) {
    const p = ps[i];
    if (!/AI/.test(p.textContent)) continue;
    const parts = inlineText(p);
    // flatten to string to see if AI survives
    const flat = parts
      .map((x) => (typeof x === "string" ? x : x.text))
      .join("␣");
    results.push({
      html: p.innerHTML.slice(0, 250),
      partsLen: Array.isArray(parts) ? parts.length : -1,
      flat: flat.slice(0, 300),
    });
  }
  return results;
}, src);

for (const r of out) {
  console.log("---");
  console.log("HTML:", r.html);
  console.log("PARTS:", r.partsLen);
  console.log("FLAT:", r.flat);
}
await browser.close();
server.close();
