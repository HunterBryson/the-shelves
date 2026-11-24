// How each app's thin hook files call the shared core.
// Claude takes plain text on stdout. Antigravity takes exactly one JSON object, always, even when something broke.
import fs from 'node:fs';

function readInput() {
  try {
    if (process.stdin.isTTY) return { raw: '', payload: {} };
    const raw = fs.readFileSync(0, 'utf8');
    let payload = {};
    try { payload = raw.trim() ? JSON.parse(raw) : {}; } catch {}
    return { raw, payload };
  } catch { return { raw: '', payload: {} }; }
}

// A hook never stops the chat: if it breaks, the reason goes to stderr and the chat goes on.
export function claudeHook(fn) {
  const { raw, payload } = readInput();
  try {
    const text = fn(payload, raw);
    if (text) process.stdout.write(text);
  } catch (e) { process.stderr.write(`memory hook: ${e?.stack || e}\n`); }
}

export function antigravityHook(fn) {
  const { raw, payload } = readInput();
  let out = {};
  try {
    const text = fn(payload, raw);
    if (text) out = { injectSteps: [{ systemMessage: { systemMessage: text } }] };
  } catch (e) { process.stderr.write(`memory hook: ${e?.stack || e}\n`); out = {}; }
  process.stdout.write(JSON.stringify(out));
}
