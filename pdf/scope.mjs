import puppeteer from "puppeteer";
import http from "http";
import { createReadStream, statSync } from "fs";
import { join, extname } from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";
const __dirname = dirname(fileURLToPath(import.meta.url));
const SITE = join(__dirname, "..", "docs", "_site");
const PORT = 4314;
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
const browser = await puppeteer.launch({
  headless: true,
  args: ["--no-sandbox"],
});
const page = await browser.newPage();
await page.goto(
  `http://localhost:${PORT}/xai20-open-challenges-future-directions`,
  { waitUntil: "networkidle0", timeout: 90000 }
);
await new Promise((r) => setTimeout(r, 1000));
const out = await page.evaluate(() => {
  const pmArticle = document.querySelector(".post-main article");
  const pc = pmArticle ? pmArticle.querySelector(".post-content") : null;
  const pm = document.querySelector(".post-main");
  const has = (el, s) => (el ? el.querySelector(s) !== null : false);
  return {
    pmArticleExists: !!pmArticle,
    pcExists: !!pc,
    pmHasBio: has(
      document.querySelector(".post-main"),
      "[aria-label='About the author']"
    ),
    pmHasReferences: has(
      document.querySelector(".post-main"),
      ".post-references, #references"
    ),
    articleHasBio: has(pmArticle, "[aria-label='About the author']"),
    articleHasRefs: has(pmArticle, ".post-references, #references"),
    pcHasBio: has(pc, "[aria-label='About the author']"),
    pcHasRefs: has(pc, ".post-references, #references"),
    pcHasArticleBody: has(pc, ".post-content"),
    bioSel: !!document.querySelector("[aria-label='About the author']"),
    introInsidePc: !!pc && /The XAI 2.0 manifesto/.test(pc.textContent || ""),
    header: (document.querySelector(".post-print-header h2") || {}).textContent,
  };
});
console.log(JSON.stringify(out, null, 2));
await browser.close();
server.close();
