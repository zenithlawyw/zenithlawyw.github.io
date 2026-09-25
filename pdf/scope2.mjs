import puppeteer from "puppeteer";
import http from "http";
import { createReadStream, statSync } from "fs";
import { join, extname } from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";
const __dirname = dirname(fileURLToPath(import.meta.url));
const SITE = join(__dirname, "..", "docs", "_site");
const PORT = 4315;
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
  const pc = document.querySelector(".post-main article .post-content");
  const txt = pc ? pc.textContent : "";
  return {
    hasBio: txt.includes("Engineering strategist"),
    hasReferencesWords: /Acknowledgements|References|cross-referen/i.test(txt),
    hasZenithBio: txt.includes("Strategist | Engineer"),
    length: txt.length,
    // Are references in a sibling AFTER article inside post-main?
    pmChildren: (() => {
      const r = [];
      const kids = document.querySelector(".post-main").childNodes;
      for (const k of kids)
        if (k.nodeType === 1)
          r.push(
            k.tagName +
              (k.className ? "." + String(k.className).split(" ")[0] : "") +
              " hasBio=" +
              /Engineering strategist/.test(k.textContent)
          );
      return r;
    })(),
  };
});
console.log(JSON.stringify(out, null, 2));
await browser.close();
server.close();
