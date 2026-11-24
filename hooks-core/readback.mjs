// Prints a chat as plain conversation, so a sleep can read it back without the tool noise. Works on either app's chats.
//   node .claude/hooks/chat.mjs "<this chat's file>"     (the wake note names it; since its last sleep)
//   node .claude/hooks/chat.mjs "<file>" [line]          (from that line on)
//   node .claude/hooks/chat.mjs                          (the chat that last sent a message here)
//   a part number at the end reads the next part of a long readback: chat.mjs "<file>" <line> 2
// (In Antigravity the same command is node .agents/hooks/chat.mjs.)
// A long readback comes in parts. As each is read, the readback's reach moves to the end of the parts read so far, in
// order; a sleep counts only that, so a chat too long for one sleep is finished by the next, from where this one stopped.
import path from 'node:path';
import { appOfPath, bestTranscript, chatCommand, chatKey, isFile, lineCount, newestChat, setMark, sleptLines, stateRead, stateWrite } from './lib.mjs';
import { talk } from './talk.mjs';

const PART_SIZE = 24000;

export function readback(app, args) {
  const preview = !!process.env.PREVIEW;
  let f = args[0];
  if (!f || f === 'this') f = stateRead(app, 'current').trim();
  if (!f) f = newestChat(app, '');
  f = bestTranscript(f);
  if (!f || !isFile(f)) return `Couldn't find the chat file: ${f || ''}\n`;

  // The chat's own app keeps its marks, so either app can read the other's chat and the sleep still counts.
  const owner = appOfPath(f);
  const dir = preview ? 'preview/' : '';
  const key = chatKey(f);
  const from = args[1] ? Number(args[1]) : sleptLines(f) + 1;
  let part = Number(args[2] || 1);
  const stamp = `${key} ${from}`;
  const kept = stateRead(owner, `${dir}readback.key`).split('\n');

  if (part === 1 || kept[0] !== stamp) {
    part = 1;
    let n = 1; let len = 0; const out = [];
    for (const t of talk(f, from)) {
      const line = `[${t.line}] ${t.who}: ${t.text}`;
      if (len > 0 && len + line.length + 1 > PART_SIZE) { n++; len = 0; }
      out.push(`${n}\t${line}`);
      len += line.length + 1;
    }
    stateWrite(owner, `${dir}readback.txt`, out.length ? `${out.join('\n')}\n` : '');
    stateWrite(owner, `${dir}readback.key`, `${stamp}\n${lineCount(f)}\n`);
    stateWrite(owner, `${dir}readback.seen`, '');
  }

  const total = Number(stateRead(owner, `${dir}readback.key`).split('\n')[1]) || 0;
  const rows = stateRead(owner, `${dir}readback.txt`).split('\n').filter(Boolean).map(l => {
    const tab = l.indexOf('\t');
    return { part: Number(l.slice(0, tab)), text: l.slice(tab + 1) };
  });
  const parts = rows.length ? rows[rows.length - 1].part : 1;
  const L = [];
  if (!rows.length) L.push(`(nothing they or I said since line ${from}: only tools and the app)`);
  for (const r of rows) if (r.part === part) L.push(r.text);

  const seen = new Set(stateRead(owner, `${dir}readback.seen`).split('\n').filter(Boolean).map(Number));
  seen.add(part);
  stateWrite(owner, `${dir}readback.seen`, `${[...seen].join('\n')}\n`);
  let doneTo = 0;
  while (seen.has(doneTo + 1)) doneTo++;

  if (doneTo >= parts) {
    if (!preview) setMark(owner, 'read', key, total);
    L.push(`(end of ${path.basename(f)}: read from line ${from} to ${total}, all of it)`);
  } else {
    if (doneTo > 0 && !preview) {
      const next = rows.find(r => r.part === doneTo + 1);
      const at = next && /^\[(\d+)\]/.exec(next.text);
      if (at) setMark(owner, 'read', key, Number(at[1]) - 1);
    }
    L.push(`(part ${part} of ${parts}. Next: ${chatCommand(f, from, part + 1)}. A sleep counts what's been read so far, in order; the rest waits for the next part, or the next sleep.)`);
  }
  return `${L.join('\n')}\n`;
}
