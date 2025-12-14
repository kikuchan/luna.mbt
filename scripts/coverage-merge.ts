/**
 * Coverage Summary Script
 * Shows summary of all coverage sources
 *
 * Usage: node scripts/coverage-merge.ts
 */
import { readdir, readFile, mkdir, writeFile } from "node:fs/promises";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { existsSync } from "node:fs";

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = join(__dirname, "..");
const COVERAGE_DIR = join(PROJECT_ROOT, "coverage");

interface CoverageSummary {
  source: string;
  lines: { covered: number; total: number; rate: number };
  files: number;
}

async function parseMoonbitCobertura(): Promise<CoverageSummary | null> {
  const coberturaFile = join(COVERAGE_DIR, "moonbit-coverage.xml");
  if (!existsSync(coberturaFile)) return null;

  const content = await readFile(coberturaFile, "utf-8");

  // Simple regex parsing for cobertura summary
  const linesValidMatch = content.match(/lines-valid="(\d+)"/);
  const linesCoveredMatch = content.match(/lines-covered="(\d+)"/);
  const lineRateMatch = content.match(/line-rate="([\d.]+)"/);

  if (!linesValidMatch || !linesCoveredMatch || !lineRateMatch) return null;

  const total = parseInt(linesValidMatch[1]);
  const covered = parseInt(linesCoveredMatch[1]);
  const rate = parseFloat(lineRateMatch[1]);

  // Count files (class elements)
  const fileMatches = content.match(/<class /g);
  const files = fileMatches ? fileMatches.length : 0;

  return {
    source: "MoonBit (moon test)",
    lines: { covered, total, rate: rate * 100 },
    files,
  };
}

async function parseVitestCoverage(): Promise<CoverageSummary | null> {
  const vitestFile = join(COVERAGE_DIR, "vitest", "coverage-final.json");
  if (!existsSync(vitestFile)) return null;

  const content = await readFile(vitestFile, "utf-8");
  const data = JSON.parse(content);

  let totalStatements = 0;
  let coveredStatements = 0;
  const files = Object.keys(data).length;

  for (const filePath of Object.keys(data)) {
    const fileCoverage = data[filePath];
    const statements = Object.keys(fileCoverage.s || {}).length;
    const covered = Object.values(fileCoverage.s || {}).filter(
      (v) => (v as number) > 0
    ).length;
    totalStatements += statements;
    coveredStatements += covered;
  }

  const rate = totalStatements > 0 ? (coveredStatements / totalStatements) * 100 : 0;

  return {
    source: "Vitest (Istanbul)",
    lines: { covered: coveredStatements, total: totalStatements, rate },
    files,
  };
}

async function parseE2ECoverage(): Promise<CoverageSummary | null> {
  const e2eDir = join(COVERAGE_DIR, "e2e-v8");
  if (!existsSync(e2eDir)) return null;

  const files = await readdir(e2eDir);
  const jsonFiles = files.filter((f) => f.endsWith(".json"));
  if (jsonFiles.length === 0) return null;

  let totalRanges = 0;
  let coveredRanges = 0;
  const urlSet = new Set<string>();

  for (const file of jsonFiles) {
    const content = await readFile(join(e2eDir, file), "utf-8");
    const entries = JSON.parse(content);

    for (const entry of entries) {
      urlSet.add(entry.url);
      for (const fn of entry.functions || []) {
        for (const range of fn.ranges || []) {
          totalRanges++;
          if (range.count > 0) coveredRanges++;
        }
      }
    }
  }

  const rate = totalRanges > 0 ? (coveredRanges / totalRanges) * 100 : 0;

  return {
    source: "E2E (Playwright V8)",
    lines: { covered: coveredRanges, total: totalRanges, rate },
    files: urlSet.size,
  };
}

function formatPercent(rate: number): string {
  return `${rate.toFixed(1)}%`.padStart(6);
}

function formatNumber(n: number): string {
  return n.toString().padStart(6);
}

async function main() {
  console.log("📊 Coverage Summary\n");
  console.log("─".repeat(70));

  const summaries: CoverageSummary[] = [];

  const moonbit = await parseMoonbitCobertura();
  if (moonbit) summaries.push(moonbit);

  const vitest = await parseVitestCoverage();
  if (vitest) summaries.push(vitest);

  const e2e = await parseE2ECoverage();
  if (e2e) summaries.push(e2e);

  if (summaries.length === 0) {
    console.log("No coverage data found. Run:");
    console.log("  just coverage-moonbit  # MoonBit unit tests");
    console.log("  just coverage-vitest   # Vitest integration tests");
    console.log("  just coverage-e2e      # E2E browser tests");
    process.exit(1);
  }

  console.log(
    `${"Source".padEnd(25)} ${"Coverage".padStart(10)} ${"Covered".padStart(8)} ${"Total".padStart(8)} ${"Files".padStart(6)}`
  );
  console.log("─".repeat(70));

  for (const s of summaries) {
    const icon = s.lines.rate >= 80 ? "🟢" : s.lines.rate >= 50 ? "🟡" : "🔴";
    console.log(
      `${icon} ${s.source.padEnd(23)} ${formatPercent(s.lines.rate)} ${formatNumber(s.lines.covered)} ${formatNumber(s.lines.total)} ${formatNumber(s.files)}`
    );
  }

  console.log("─".repeat(70));

  // Generate simple HTML report
  const htmlReport = `<!DOCTYPE html>
<html>
<head>
  <title>Luna Coverage Summary</title>
  <style>
    body { font-family: system-ui; max-width: 800px; margin: 40px auto; padding: 20px; }
    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
    th { background: #f5f5f5; }
    .good { color: #22c55e; }
    .ok { color: #eab308; }
    .bad { color: #ef4444; }
  </style>
</head>
<body>
  <h1>📊 Luna Coverage Summary</h1>
  <p>Generated: ${new Date().toISOString()}</p>
  <table>
    <tr><th>Source</th><th>Coverage</th><th>Covered</th><th>Total</th><th>Files</th></tr>
    ${summaries.map((s) => {
      const cls = s.lines.rate >= 80 ? "good" : s.lines.rate >= 50 ? "ok" : "bad";
      return `<tr><td>${s.source}</td><td class="${cls}">${s.lines.rate.toFixed(1)}%</td><td>${s.lines.covered}</td><td>${s.lines.total}</td><td>${s.files}</td></tr>`;
    }).join("\n    ")}
  </table>
  <h2>Coverage Sources</h2>
  <ul>
    <li><strong>MoonBit</strong>: Unit tests covering .mbt source files</li>
    <li><strong>Vitest</strong>: Integration tests covering generated JS (via Istanbul)</li>
    <li><strong>E2E</strong>: Browser tests covering runtime JS (via V8)</li>
  </ul>
  <p><em>Note: These cover different code - MoonBit tracks .mbt sources, while Vitest/E2E track generated JavaScript.</em></p>
</body>
</html>`;

  await mkdir(join(COVERAGE_DIR, "summary"), { recursive: true });
  await writeFile(join(COVERAGE_DIR, "summary", "index.html"), htmlReport);

  console.log(`\n✅ HTML report: coverage/summary/index.html`);

  // Show file locations
  console.log("\n📁 Coverage files:");
  if (moonbit) console.log("   MoonBit: coverage/moonbit-coverage.xml");
  if (vitest) console.log("   Vitest:  coverage/vitest/coverage-final.json");
  if (e2e) console.log("   E2E:     coverage/e2e-v8/*.json");
}

main().catch((err) => {
  console.error("Error:", err);
  process.exit(1);
});
