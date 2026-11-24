// Shared by every hook, for both apps. Plain Node 18+, nothing to install.
// Every path is worked out from where this file sits, because each app starts hooks in a different folder.
// Memory, git history and the footing are shared. Each app keeps its own scratch: .claude/state and .agents/state.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

export const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
export const APPS = {
  claude: { state: '.claude/state', chat: '.claude/hooks/chat.mjs' },
  antigravity: { state: '.agents/state', chat: '.agents/hooks/chat.mjs' },
};
export const BOOT = ['memory/FOOTING.md', 'memory/DESK.md', 'memory/human/human.md', 'memory/self/persona.md'];
export const PIECES = 6;       // Claude cuts a hook's output near 10,000 characters, so pulled blocks travel in pieces.
export const PIECE_SIZE = 9000;
export const BOOT_CAP = 24000; // Antigravity cuts a rules file here, after its includes are expanded.
export const BOOT_WARN = 0.85;

// ----- files -----
export const inRoot = rel => path.join(ROOT, rel);
export const readRel = rel => { try { return fs.readFileSync(inRoot(rel), 'utf8'); } catch { return ''; } };
export const slash = p => String(p || '').replace(/\\+/g, '/');
export const isFile = p => { try { return fs.statSync(p).isFile(); } catch { return false; } };
export const mtime = p => { try { return fs.statSync(p).mtimeMs; } catch { return 0; } };

// ----- each app's own scratch -----
export const statePath = (app, name) => inRoot(`${APPS[app].state}/${name}`);
export function ensureState(app) { fs.mkdirSync(inRoot(APPS[app].state), { recursive: true }); }
export const stateRead = (app, name) => { try { return fs.readFileSync(statePath(app, name), 'utf8'); } catch { return ''; } };
export function stateWrite(app, name, text) {
  const file = statePath(app, name);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const tmp = `${file}.${process.pid}.tmp`;
  fs.writeFileSync(tmp, text);
  fs.renameSync(tmp, file);
}
export const stateAppend = (app, name, text) => { ensureState(app); fs.appendFileSync(statePath(app, name), text); };
export const stateRemove = (app, name) => { try { fs.unlinkSync(statePath(app, name)); } catch {} };
export const stateLines = (app, name) => stateRead(app, name).split('\n').map(s => s.replace(/\r$/, '')).filter(Boolean);

// ----- which chat is which -----
// A chat file's path says which app wrote it. Antigravity names every transcript the same, so its key is the chat's id.
export const appOfPath = p => (/\/\.gemini\//.test(slash(p)) || /\.system_generated\//.test(slash(p)) ? 'antigravity' : 'claude');
export function chatKey(p) {
  const s = slash(p);
  const m = /\/brain\/([^/]+)\/\.system_generated\//.exec(s);
  return m ? m[1] : path.posix.basename(s);
}
// Antigravity's fuller transcript sits beside the one it names in the payload.
export function bestTranscript(p) {
  const s = slash(p);
  if (!s) return '';
  const full = s.replace(/transcript\.jsonl$/, 'transcript_full.jsonl');
  return full !== s && isFile(full) ? full : s;
}
export function markOf(app, name, key) {
  let n = 0;
  for (const line of stateLines(app, name)) { const [k, v] = line.split(' '); if (k === key) n = Number(v) || 0; }
  return n;
}
export function setMark(app, name, key, value) {
  const keep = stateLines(app, name).filter(l => l.split(' ')[0] !== key);
  keep.push(`${key} ${value} ${Math.floor(Date.now() / 1000)}`);
  stateWrite(app, name, keep.join('\n') + '\n');
}
export const sleptLines = p => markOf(appOfPath(p), 'slept', chatKey(p));
export const lineCount = p => { try { return fs.readFileSync(p, 'latin1').split('\n').length - 1; } catch { return 0; } };

// Antigravity's brain folder holds every project's chats, so this folder keeps its own list of the ones that happened here.
export function rememberAgChat(p) {
  const key = chatKey(p);
  if (!p || stateLines('antigravity', 'known').some(l => l.split(' ')[0] === key)) return;
  stateAppend('antigravity', 'known', `${key} ${p}\n`);
}
const agChats = () => stateLines('antigravity', 'known').map(l => l.slice(l.indexOf(' ') + 1)).filter(isFile);
function claudeChatDir(tp) {
  if (tp && appOfPath(tp) === 'claude') return path.posix.dirname(slash(tp));
  const cur = stateRead('claude', 'current').trim();
  if (cur) return path.posix.dirname(slash(cur));
  return slash(path.join(os.homedir(), '.claude', 'projects', ROOT.replace(/[^A-Za-z0-9]/g, '-')));
}
function claudeChats(tp) {
  const dir = claudeChatDir(tp);
  try {
    return fs.readdirSync(dir).filter(f => f.endsWith('.jsonl') && !f.startsWith('agent-')).map(f => `${dir}/${f}`);
  } catch { return []; }
}
// Every chat this brain has had, in either app, newest first.
export const everyChat = tp => [...claudeChats(tp), ...agChats()].sort((a, b) => mtime(b) - mtime(a));
export const newestChat = (app, tp) => (app === 'claude' ? claudeChats(tp) : agChats()).sort((a, b) => mtime(b) - mtime(a))[0] || '';
export const chatCommand = (p, from, part) =>
  `node ${APPS[appOfPath(p)].chat} "${p}"${from !== undefined ? ` ${from}` : ''}${part !== undefined ? ` ${part}` : ''}`;

// ----- git -----
export function git(args) {
  return execFileSync('git', args, { cwd: ROOT, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'], timeout: 15000, windowsHide: true }).replace(/\s+$/, '');
}
export const gitTry = args => { try { return git(args); } catch { return ''; } };
export const inRepo = () => { try { git(['rev-parse', '--git-dir']); return true; } catch { return false; } };

// ----- the date, said the same way on every computer -----
export function when(withYear = true) {
  const d = new Date();
  const day = d.toLocaleDateString('en-US', { weekday: 'long' });
  const month = d.toLocaleDateString('en-US', { month: 'long' });
  const hour = d.getHours() % 12 || 12;
  const min = String(d.getMinutes()).padStart(2, '0');
  return `${day}, ${month} ${d.getDate()},${withYear ? ` ${d.getFullYear()},` : ''} ${hour}:${min} ${d.getHours() < 12 ? 'AM' : 'PM'}`;
}

// ----- the desk and the footing -----
export function deskRows() {
  const rows = [];
  for (const line of readRel('memory/DESK.md').split('\n')) {
    if (!line.startsWith('|')) continue;
    const c = line.split('|').map(s => s.trim());
    if (c.length < 5 || !c[1] || /^-+$/.test(c[1]) || c[1].toLowerCase() === 'word') continue;
    const m = /`([^`]+)`/.exec(c[3] || '');
    if (!m) continue;
    const file = fs.existsSync(inRoot(m[1])) ? m[1] : `memory/${m[1]}`;
    rows.push({ word: c[1], file, also: (c[4] || '').split(',').map(s => s.trim()).filter(Boolean) });
  }
  return rows;
}
export const blockFor = word => deskRows().find(r => r.word.toLowerCase() === word)?.file || '';
export function pullWords() {
  const m = /^\*\*Pull on waking:\*\*(.*)$/mi.exec(readRel('memory/FOOTING.md'));
  if (!m) return [];
  return m[1].replace(/[\s.]+$/, '').split(',').map(s => s.trim().toLowerCase()).filter(Boolean);
}
export const saysFirstChat = () => readRel('memory/FOOTING.md').includes('first chat');
export const livedCommits = () => gitTry(['log', '--format=%H', '--', 'memory']).split('\n').filter(Boolean).length;
export const isFirstChat = () => saysFirstChat() && livedCommits() <= 2;

export const blockText = (word, file) => `===== "${word}" (${file}), whole =====\n${readRel(file).replace(/\n$/, '')}\n\n===== end of "${word}" =====\n\n`;
function pulledBlocks() {
  const seen = new Set(); const out = [];
  for (const w of pullWords()) {
    const file = blockFor(w);
    if (!file || !isFile(inRoot(file)) || BOOT.includes(file) || seen.has(file)) continue;
    seen.add(file);
    out.push({ word: w, file, text: blockText(w, file) });
  }
  return out;
}
export const pulledFiles = () => pulledBlocks().map(b => b.file);
export const pulledWhole = () => pulledBlocks().map(b => b.text).join('');
// Pieces are cut at whole blocks, so each makes sense alone. Only a block bigger than a piece is cut, at line ends.
export function pulledPieces() {
  const pieces = []; let cur = '';
  const close = () => { if (cur) pieces.push(cur); cur = ''; };
  for (const b of pulledBlocks()) {
    if (cur && cur.length + b.text.length > PIECE_SIZE) close();
    for (const line of b.text.replace(/\n$/, '').split('\n')) {
      const l = `${line}\n`;
      if (cur && cur.length + l.length > PIECE_SIZE) { close(); cur = `("${b.word}", continued from the piece before)\n`; }
      cur += l;
    }
  }
  close();
  return pieces;
}

// ----- Antigravity's size limit on boot files, which matters from either app, since a person can switch -----
export function bootSizes() {
  const out = [];
  for (const rule of ['GEMINI.md', 'AGENTS.md']) {
    const text = readRel(rule);
    if (!text) continue;
    let bytes = Buffer.byteLength(text);
    for (const m of text.matchAll(/@\[[^\]]*\]\(([^)]+)\)/g)) bytes += Buffer.byteLength(readRel(m[1]));
    out.push({ rule, bytes });
  }
  return out;
}
export const bootWarnings = () => bootSizes().filter(b => b.bytes > BOOT_CAP * BOOT_WARN).map(b =>
  `WARNING: ${b.rule} and the files it includes come to ${b.bytes.toLocaleString('en-US')} bytes, past 85% of the ${BOOT_CAP.toLocaleString('en-US')} where Antigravity cuts a boot file without saying so. At my next sleep I move detail from those boot files into blocks, so I wake up whole in either app.`);
