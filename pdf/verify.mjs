// Comprehensive verification: metadata present, no bio/footer, text intact.
import puppeteer from "puppeteer";
import http from "http";
import { createReadStream, statSync, readdirSync, readFileSync } from "fs";
import { join, extname } from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";
import { execSync } from "child_process";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SITE = join(__dirname, "..", "docs", "_site");
const PORT = 4313;
const DOWNLOAD_DIR = join(__dirname, "verify-dl");
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
const errors = [];
page.on("pageerror", (e) => errors.push(e.message));
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
await new Promise((r) => setTimeout(r, 5000));
console.log("downloaded:", name);
console.log("page errors:", errors.length ? errors : "none");

const files = readdirSync(DOWNLOAD_DIR);
const pdfPath = join(DOWNLOAD_DIR, files[0]);
execSync(`pdftotext -layout "${pdfPath}" ${DOWNLOAD_DIR}/out.txt`);
const txt = readFileSync(join(DOWNLOAD_DIR, "out.txt"), "utf8");

console.log("\n=== HEAD (metadata + intro) ===");
console.log(txt.slice(0, 900));

console.log("\n=== CHECKS ===");
console.log(
  "contains title 'XAI 2.0 and the Road Ahead':",
  txt.includes("XAI 2.0 and the Road Ahead")
);
console.log("contains date '14 July 2026':", txt.includes("14 July 2026"));
console.log("contains author 'Zenith Law':", txt.includes("Zenith Law"));
console.log(
  "contains URL 'zenithlaw.com/xai20':",
  txt.includes("zenithlaw.com/xai20")
);
console.log(
  "contains category 'Artificial Intelligence':",
  txt.includes("Artificial Intelligence")
);
console.log(
  "contains 'XAI' intact:",
  (txt.match(/XAI/g) || []).length,
  "occurrences"
);
console.log(
  "Bio text present (should be FALSE):",
  txt.includes("Engineering strategist Zenith Law publishes")
);
console.log(
  "Shares tag 'Strategist | Engineer':",
  txt.includes("Strategist | Engineer")
);
console.log(
  "'X' followed by newline (broken XAI):",
  /\bX\n/.test(txt) || /^X$/m.test(txt)
);
console.log("\n=== TAIL (should be article end, no bio) ===");
console.log(txt.slice(-500));

await browser.close();
server.close();
