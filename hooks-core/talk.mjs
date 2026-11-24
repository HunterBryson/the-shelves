// Reads a chat file the way a person would, for both apps' formats.
// THEM is what my person typed or said. YOU is my own words. APP is a background job's notice, in one short line.
// Tool results, hook notes, the app's summaries, command output and scheduled-task prompts are left out, so a sleep
// never reads them as something my person said, and they never make a chat look like it needs a sleep.
import fs from 'node:fs';
import { appOfPath } from './lib.mjs';

const APP_PIECE = /^<(task-notification|local-command-stdout|local-command-stderr|local-command-caveat|system-reminder|scheduled-task|user-prompt-submit-hook|bash-stdout|bash-stderr)/;
const isAppPiece = t => APP_PIECE.test(t) || /^\[Request interrupted/.test(t);
// One message stays on one line of the readback, so its line number always leads.
const oneLine = t => JSON.stringify(String(t)).slice(1, -1);
const cut = (s, max) => (s.length > max ? `${s.slice(0, max)} ...(cut here: the rest of this message is at this line of the chat file)` : s);

// A slash command they typed shows as they typed it: /model claude-opus-5-5
function command(t) {
  if (!t.startsWith('<command-name>')) return t;
  const name = /^<command-name>([\s\S]*?)<\/command-name>/.exec(t)?.[1] ?? '';
  const args = /<command-args>([\s\S]*?)<\/command-args>/.exec(t)?.[1] ?? '';
  return name + (args ? ` ${args}` : '');
}

function claudeWords(content, who) {
  if (typeof content === 'string') {
    if (who === 'user' && isAppPiece(content)) return { text: '', pics: 0, app: true };
    return { text: command(content), pics: 0, app: false };
  }
  let pics = 0; let app = false; const out = [];
  for (const p of Array.isArray(content) ? content : []) {
    if (p?.type === 'image') { pics++; continue; }
    if (p?.type !== 'text' || typeof p.text !== 'string') continue;
    if (who === 'user' && isAppPiece(p.text)) { app = true; continue; }
    out.push(command(p.text));
  }
  return { text: out.join(' '), pics, app: out.length ? false : app };
}

function claudePerson(o, raw) {
  if (o.type !== 'user' || o.isMeta || o.isCompactSummary) return '';
  if (raw.includes('"tool_use_id"') || raw.includes('"toolUseResult"')) return '';
  const w = claudeWords(o.message?.content, 'user');
  const text = w.text || (w.pics > 0 && !w.app ? '(no words)' : '');
  return text ? (w.pics > 0 ? '[picture] ' : '') + text : '';
}
function claudeNotice(o, raw) {
  if (o.type !== 'user' || o.isMeta || !raw.includes('<task-notification')) return '';
  if (raw.includes('"tool_use_id"') || raw.includes('"toolUseResult"')) return '';
  const c = o.message?.content;
  const all = typeof c === 'string' ? c : (Array.isArray(c) ? c.map(p => p?.text || '').join(' ') : '');
  let t = /<task-notification>([\s\S]*?)(<\/task-notification>|$)/.exec(all)?.[1] ?? '';
  const summary = /<summary>([\s\S]*?)<\/summary>/.exec(t);
  if (summary) t = summary[1];
  return cut(t.replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim(), 300);
}

// Antigravity wraps what a person typed in <USER_REQUEST>, with its own metadata around it.
export function agWords(content) {
  const s = String(content || '');
  const m = /<USER_REQUEST>\n?([\s\S]*?)\n?<\/USER_REQUEST>/.exec(s);
  if (m) return m[1].trim();
  return s.replace(/<(ADDITIONAL_METADATA|USER_SETTINGS_CHANGE)>[\s\S]*?<\/\1>/g, '').trim();
}

function parse(raw) { try { return JSON.parse(raw); } catch { return null; } }
const fileLines = f => { try { return fs.readFileSync(f, 'utf8').split('\n'); } catch { return []; } };

// What was said from a line on: [{ line, who, text }].
export function talk(file, from = 1) {
  const out = [];
  const ag = appOfPath(file) === 'antigravity';
  fileLines(file).forEach((raw, i) => {
    const line = i + 1;
    if (line < from || !raw.trim()) return;
    if (ag) {
      if (!raw.includes('"USER_INPUT"') && !raw.includes('"PLANNER_RESPONSE"')) return;
      const o = parse(raw); if (!o) return;
      if (o.type === 'USER_INPUT') { const w = agWords(o.content); if (w) out.push({ line, who: 'THEM', text: cut(oneLine(w), 20000) }); }
      else if (o.type === 'PLANNER_RESPONSE' && typeof o.content === 'string' && o.content) out.push({ line, who: 'YOU', text: cut(oneLine(o.content), 3000) });
      return;
    }
    if (!raw.includes('"type":"user"') && !raw.includes('"type":"assistant"')) return;
    const o = parse(raw); if (!o) return;
    let w = claudePerson(o, raw);
    if (w) { out.push({ line, who: 'THEM', text: cut(oneLine(w), 20000) }); return; }
    w = claudeNotice(o, raw);
    if (w) { out.push({ line, who: 'APP (a job of mine, not them)', text: oneLine(w) }); return; }
    if (o.type === 'assistant') {
      w = claudeWords(o.message?.content, 'assistant').text;
      if (w) out.push({ line, who: 'YOU', text: cut(oneLine(w), 3000) });
    }
  });
  return out;
}

// How many messages my person sent from that line on.
export function countThem(file, from = 1) {
  const ag = appOfPath(file) === 'antigravity';
  let n = 0;
  fileLines(file).forEach((raw, i) => {
    if (i + 1 < from || !raw.trim()) return;
    if (ag) {
      if (!raw.includes('"USER_INPUT"')) return;
      const o = parse(raw);
      if (o?.type === 'USER_INPUT' && agWords(o.content)) n++;
    } else {
      if (!raw.includes('"type":"user"')) return;
      const o = parse(raw);
      if (o && claudePerson(o, raw)) n++;
    }
  });
  return n;
}

// A scheduled task opens a chat too, but it isn't a talk with my person.
export function isScheduled(file) {
  for (const raw of fileLines(file)) {
    if (raw.includes('"role":"user"') || raw.includes('"USER_INPUT"')) return raw.includes('<scheduled-task');
  }
  return false;
}

// When I last spoke in this chat (milliseconds), from the end of the file.
export function lastReplyAt(file) {
  const ag = appOfPath(file) === 'antigravity';
  const lines = fileLines(file).slice(-400);
  for (let i = lines.length - 1; i >= 0; i--) {
    if (!lines[i].includes(ag ? '"PLANNER_RESPONSE"' : '"type":"assistant"')) continue;
    const o = parse(lines[i]); if (!o) continue;
    const t = Date.parse(ag ? o.created_at : o.timestamp);
    if (t) return t;
  }
  return 0;
}

// How full the chat really is: the app writes its token count on every reply.
export function chatFullness(file) {
  const ag = appOfPath(file) === 'antigravity';
  const all = fileLines(file);
  const lines = all.slice(-200);
  let tokens = 0;
  for (let i = lines.length - 1; i >= 0; i--) {
    if (!lines[i].includes(ag ? '"PLANNER_RESPONSE"' : '"type":"assistant"')) continue;
    const o = parse(lines[i]); if (!o) continue;
    if (ag) { if (o.input_tokens === undefined) continue; tokens = (o.input_tokens || 0) + (o.cache_read_tokens || 0); break; }
    const u = o.message?.usage; if (!u) continue;
    tokens = (u.input_tokens || 0) + (u.cache_creation_input_tokens || 0) + (u.cache_read_input_tokens || 0);
    break;
  }
  const summarized = !ag && all.some(l => l.includes('"subtype":"compact_boundary"'));
  return { tokens, summarized };
}
