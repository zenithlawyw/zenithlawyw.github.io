// Capture the generated PDF and run pdftotext to check if "AI" is lost.
import puppeteer from "puppeteer";
import http from "http";
import { createReadStream, statSync, readdirSync } from "fs";
import { join, extname } from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";
import { execSync } from "child_process";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SITE = join(__dirname, "..", "docs", "_site");
const PORT = 4312;
const DOWNLOAD_DIR = join(__dirname, "ai-dl");
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
const cdp = await page.createCDPSession();
await cdp.send("Browser.setDownloadBehavior", {
  behavior: "allow",
  downloadPath: DOWNLOAD_DIR,
  eventsEnabled: true,
});
const dw = new Promise((resolve) =>
  cdp.on("Browser.downloadWillBegin", (e) => resolve(e.suggestedFilename))
);
await page.goto(
  `http://localhost:${PORT}/xai20-open-challenges-future-directions`,
  { waitUntil: "networkidle0", timeout: 90000 }
);
await new Promise((r) => setTimeout(r, 1000));
await page.evaluate(() => window.printArticle());
const name = await Promise.race([
  dw,
  new Promise((r) => setTimeout(() => r("TIMEOUT"), 20000)),
]);
await new Promise((r) => setTimeout(r, 4000));
console.log("downloaded:", name);
const files = readdirSync(DOWNLOAD_DIR);
const pdfPath = join(DOWNLOAD_DIR, files[0]);
// Extract text
try {
  execSync(`pdftotext -layout "${pdfPath}" ${DOWNLOAD_DIR}/out.txt`);
  const fs = await import("fs");
  const txt = fs.readFileSync(join(DOWNLOAD_DIR, "out.txt"), "utf8");
  console.log("=== TEXT LENGTH:", txt.length, "===");
  // Check for XAI presence
  const xai = txt.match(/XAI/g);
  console.log("XAI count:", xai ? xai.length : 0);
  // Find suspicious: 'X' followed by newline
  const lines = txt.split("\n");
  for (let i = 0; i < lines.length; i++) {
    if (/^X\s*$/.test(lines[i]) || /X$/.test(lines[i])) {
      console.log(
        "suspicious X line",
        i,
        ":",
        JSON.stringify(lines.slice(Math.max(0, i - 1), i + 2))
      );
    }
  }
  // Show first 800 chars
  console.log("=== HEAD ===");
  console.log(txt.slice(0, 800));
} catch (e) {
  console.log("pdftotext err:", e.message);
}
await browser.close();
server.close();
