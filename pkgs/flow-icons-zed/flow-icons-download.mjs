#!/usr/bin/env node
// Download the Flow Icons SVG set and extract it.
//
// Does the same thing as the license form on https://flow-icons.pages.dev/download:
// sends your license key to the Flow Icons API, gets the SVG archive link
// (.tar.br), then streams it through brotli decompression into tar extraction.
//
// License key comes from (in order): --key, $FLOW_ICONS_LICENSE, or a prompt.
// The release is the Flow Icons version whose SVGs to fetch, as VS Code sends it.
//
//   FLOW_ICONS_LICENSE=XXXX node flow-icons-download.mjs -r 2.0.10 [-o ./flow-icons-svg]

import { mkdir } from "node:fs/promises";
import path from "node:path";
import { createInterface } from "node:readline";
import { Readable, Transform } from "node:stream";
import { pipeline } from "node:stream/promises";
import { parseArgs } from "node:util";
import { createBrotliDecompress } from "node:zlib";
import * as tar from "tar";

const API_URL = "https://legit-i9lq.onrender.com/flow-icons/version-3";

function fail(msg) {
  console.error(`error: ${msg}`);
  process.exit(1);
}

// Prompt without echoing the key to the terminal.
function promptHidden(question) {
  return new Promise((resolve) => {
    const rl = createInterface({ input: process.stdin, output: process.stdout, terminal: true });
    rl._writeToOutput = (s) => {
      if (s.startsWith(question)) rl.output.write(question);
    };
    rl.question(question, (answer) => {
      rl.close();
      process.stdout.write("\n");
      resolve(answer);
    });
  });
}

async function fetchSvgUrl(key, release) {
  let res;
  try {
    // The API is hosted on Render and can take a while to wake up.
    res = await fetch(`${API_URL}?${new URLSearchParams({ v: release })}`, {
      headers: { authorization: key, "machine-id": "no-id" },
      signal: AbortSignal.timeout(120_000),
    });
  } catch (e) {
    fail(`could not reach API: ${e.cause?.message ?? e.message}`);
  }
  if ([400, 401, 403, 404].includes(res.status)) fail(`license key rejected (HTTP ${res.status})`);
  if (!res.ok) fail(`API request failed (HTTP ${res.status})`);
  const data = await res.json();
  if (!data.url) fail("no SVG link returned for this license");
  return data.url;
}

// Passes data through while printing download progress to the terminal.
function progress(total) {
  let done = 0;
  const show = total > 0 && process.stderr.isTTY;
  return new Transform({
    transform(chunk, _enc, cb) {
      done += chunk.length;
      if (show) {
        process.stderr.write(`\r  ${Math.floor((done * 100) / total)}%  ${(done / 1e6).toFixed(1)} MB`);
      }
      cb(null, chunk);
    },
    flush(cb) {
      if (show) process.stderr.write("\n");
      cb();
    },
  });
}

async function main() {
  const { values } = parseArgs({
    options: {
      key: { type: "string", short: "k" },
      release: { type: "string", short: "r" },
      out: { type: "string", short: "o", default: "flow-icons-svg" },
      help: { type: "boolean", short: "h" },
    },
  });
  if (values.help) {
    console.log("usage: node flow-icons-download.mjs -r RELEASE [-k KEY] [-o OUT_DIR]\n" +
      "Prefer $FLOW_ICONS_LICENSE over -k to keep the key out of shell history.");
    return;
  }

  if (!values.release) fail("no release given; pass -r with a Flow Icons version");

  const key = (values.key ?? process.env.FLOW_ICONS_LICENSE ?? (await promptHidden("License key: "))).trim();
  if (!key) fail("no license key given");

  console.log("requesting download link...");
  const url = await fetchSvgUrl(key, values.release);

  const res = await fetch(url, { signal: AbortSignal.timeout(300_000) });
  if (!res.ok) fail(`download failed (HTTP ${res.status})`);

  const outDir = path.resolve(values.out);
  await mkdir(outDir, { recursive: true });

  console.log(`downloading and extracting -> ${outDir}`);
  let files = 0;
  await pipeline(
    Readable.fromWeb(res.body),
    progress(Number(res.headers.get("content-length"))),
    createBrotliDecompress(),
    // node-tar refuses absolute paths and ".." entries by default.
    tar.x({ cwd: outDir, onReadEntry: (e) => { if (e.type === "File") files++; } }),
  );
  console.log(`extracted ${files} files`);
}

main().catch((e) => fail(e.message));
