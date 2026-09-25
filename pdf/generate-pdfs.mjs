#!/usr/bin/env node
// Regenerate PDFs from the Jekyll site using Puppeteer.
// Produces PDFs with embedded fonts (~0.5-1.5 MB) instead of
// outlined vector paths (~5-10 MB) from browser print-to-PDF.
//
// Usage: node generate-pdfs.mjs [--posts slug1,slug2]
//   --posts  Comma-separated post slugs (filenames without date prefix)

import puppeteer from "puppeteer";
import { readdir, readFile, stat } from "fs/promises";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const POSTS_DIR = join(__dirname, "..", "docs", "_posts");
const PDF_DIR = __dirname;
const PORT = 4199;
const BASE_URL = `http://localhost:${PORT}`;

function parseArgs() {
  const args = process.argv.slice(2);
  let posts = null;
  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--posts" && args[i + 1]) {
      posts = args[i + 1].split(",").map((s) => s.trim());
    }
  }
  return { posts };
}

async function getPostPermalinks(filter) {
  const files = (await readdir(POSTS_DIR)).filter(
    (f) => f.endsWith(".md") || f.endsWith(".markdown")
  );

  const posts = [];
  for (const file of files) {
    const raw = await readFile(join(POSTS_DIR, file), "utf8");
    const fmMatch = raw.match(/^---\n([\s\S]*?)\n---/);
    if (!fmMatch) continue;

    const fm = fmMatch[1];
    const permMatch = fm.match(/^permalink:\s*(.+)$/m);
    if (!permMatch) continue;

    const permalink = permMatch[1].trim();
    const slug = file
      .replace(/^\d{4}-\d{2}-\d{2}-/, "")
      .replace(/\.(md|markdown)$/, "");

    if (
      filter &&
      filter.length &&
      !filter.some((f) => slug.includes(f) || file.includes(f))
    ) {
      continue;
    }

    posts.push({ file, slug, permalink });
  }
  return posts;
}

function permalinkToFilename(permalink) {
  // /critical-perspectives-limits-xai → "Critical Perspectives Limits Xai.pdf"
  const name = permalink
    .replace(/^\/|\/$/g, "")
    .replace(/\//g, " ")
    .replace(/-/g, " ")
    .replace(/\b\w/g, (c) => c.toUpperCase());
  return name + ".pdf";
}

async function main() {
  const { posts: filter } = parseArgs();
  const posts = await getPostPermalinks(filter);

  if (posts.length === 0) {
    console.log("No posts found matching filter.");
    process.exit(0);
  }

  console.log(`Found ${posts.length} post(s) to export as PDF\n`);

  const browser = await puppeteer.launch({
    headless: true,
    args: [
      "--no-sandbox",
      "--disable-setuid-sandbox",
      "--disable-gpu",
      "--disable-dev-shm-usage",
    ],
    timeout: 60_000,
  });

  const results = [];

  for (const { file, slug, permalink } of posts) {
    const url = `${BASE_URL}${permalink}`;
    const outName = permalinkToFilename(permalink);
    const outPath = join(PDF_DIR, outName);

    process.stdout.write(`  ${outName} ... `);

    try {
      const page = await browser.newPage();

      // Set a reasonable viewport
      await page.setViewport({ width: 1200, height: 1600 });

      await page.goto(url, { waitUntil: "networkidle0", timeout: 90_000 });

      // Wait for content to render
      await page
        .waitForSelector("article, .post-content, main", { timeout: 10_000 })
        .catch(() => {});

      // Generate PDF with embedded fonts
      await page.pdf({
        path: outPath,
        format: "A4",
        printBackground: true,
        displayHeaderFooter: false,
        margin: { top: "20mm", bottom: "25mm", left: "25mm", right: "25mm" },
        preferCSSPageSize: true,
      });

      await page.close();

      const size = (await stat(outPath)).size;
      const sizeMB = (size / 1024 / 1024).toFixed(1);
      console.log(`${sizeMB} MB`);
      results.push({ name: outName, size });
    } catch (err) {
      console.log(`ERROR: ${err.message}`);
    }
  }

  await browser.close();

  // Summary
  console.log("\n---");
  const total = results.reduce((a, r) => a + r.size, 0);
  console.log(
    `Total: ${(total / 1024 / 1024).toFixed(1)} MB across ${results.length} file(s)\n`
  );
  for (const r of results.sort((a, b) => b.size - a.size)) {
    const mb = (r.size / 1024 / 1024).toFixed(1);
    console.log(`  ${mb} MB  ${r.name}`);
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
