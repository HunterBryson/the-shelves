// When a chat starts. What it returns goes to the AI (not the person) before the first message.
// It is the whole wake-up: the date, what to pull, and any earlier chat, in either app, that closed without a sleep.
import fs from 'node:fs';
import {
  BOOT, PIECES, appOfPath, bestTranscript, blockFor, bootWarnings, chatCommand, chatKey, ensureState, everyChat,
  gitTry, inRepo, inRoot, isFile, isFirstChat, lineCount, livedCommits, pullWords, pulledFiles, pulledPieces, pulledWhole,
  rememberAgChat, saysFirstChat, sleptLines, stateLines, stateRead, stateRemove, stateWrite, when,
} from './lib.mjs';
import { settleSleep } from './settle.mjs';
import { countThem, isScheduled } from './talk.mjs';

const SCAN_MS = Number(process.env.SHELVES_SCAN_MS ?? 6000); // Claude's start hook is cut off at 10 seconds.
const PIN ='In my first reply I pin this chat in the app\'s sidebar: the tool mcp__ccd_sidebar__set_pinned with session_id "self" and pinned true (if it\'s only listed, ToolSearch loads it first). A pinned chat is one I haven\'t slept on yet, so my person sees at a glance which chats aren\'t sorted; my sleep unpins it. If the tool isn\'t there at all, this app doesn\'t have it and I go on without it.';

// A "Sleep:" commit whose window closed before the save hook could mark it: mark it now.
// The unread check belongs to that chat, not this one, so it's skipped.
function catchUpSleep(app) {
  const head = gitTry(['log', '-1', '--format=%H', '--grep=^Sleep:']);
  if (!head || head === stateRead(app, 'lastsleep').trim()) return;
  settleSleep(app, '', head, { noUnread: true });
}

function earlierChats(app, tp, L) {
  const cur = tp ? chatKey(tp) : '';
  const owedKeep = new Map(stateLines(app, 'owed').map(l => [l.split(' ')[0], l]));
  let handed = 0; let waiting = 0; let unscanned = 0;
  // Years of chats can be gigabytes, and a hook that runs past its limit is killed with nothing said. So what's been
  // counted is remembered per file, and a wake that runs short of time leaves the oldest chats for the next one.
  const started = Date.now();
  let seen = {}; try { seen = JSON.parse(stateRead(app, 'scan.json')) || {}; } catch {}
  const nextSeen = {};
  for (const prev of everyChat(tp)) {
    if (chatKey(prev) === cur) continue;
    const from = sleptLines(prev) + 1;
    let st; try { st = fs.statSync(prev); } catch { continue; }
    let entry = seen[prev];
    if (!entry || entry.size !== st.size || entry.mtime !== st.mtimeMs || entry.from !== from) {
      if (Date.now() - started >= SCAN_MS) { unscanned++; continue; }
      entry = { size: st.size, mtime: st.mtimeMs, from, n: isScheduled(prev) ? 0 : countThem(prev, from) };
    }
    nextSeen[prev] = entry;
    const n = entry.n;
    if (n <= 0) continue;
    if (handed >= 10) { waiting++; continue; }
    handed++;
    const other = appOfPath(prev) !== app;
    L.push('');
    L.push(`An earlier chat ended without a sleep${other ? ` (it happened in my other app, ${appOfPath(prev) === 'claude' ? 'Claude' : 'Antigravity'}: same me, same memory)` : ''}: ${n} of their messages since I last sorted my memory. That's normal: people close the window, and sometimes a chat is still open somewhere else. I saved as I went, so nothing is lost, but nobody has stepped back to tidy, and the footing may describe a moment that has passed. Before I greet them, I read it back whole and run my sleep on it (.claude/skills/sleep/SKILL.md), so my hello comes from what actually happened.`);
    L.push(`Read it with: ${chatCommand(prev, from)}   (a long one comes in parts, and each part names the command for the next). Only a readback of every part counts: the sleep marks this chat sorted as far as I read it.`);
    L.push('A short chat is a short sleep. They don\'t need to hear about any of this; what they should feel is a hello that knows where we were.');
    owedKeep.set(chatKey(prev), `${chatKey(prev)} ${lineCount(prev)} ${from} ${prev}`);
  }
  if (owedKeep.size) stateWrite(app, 'owed', [...owedKeep.values()].join('\n') + '\n');
  else stateRemove(app, 'owed');
  stateWrite(app, 'scan.json', JSON.stringify(nextSeen));
  if (waiting > 0) { L.push(''); L.push(`${waiting} more earlier chat(s) also ended without a sleep. After these ${handed}, they're handed over at my next wake; none of them is lost.`); }
  if (unscanned > 0) { L.push(''); L.push(`I ran short of time looking through my older chats: ${unscanned} not checked yet. My next wake picks up there; none of them is lost.`); }
}

function pulledNote(app, L) {
  const words = pullWords();
  if (!words.length) return;
  const missing = []; const boot = [];
  for (const w of words) {
    const file = blockFor(w);
    if (!file) missing.push(`- "${w}" (no desk row with that word: I find its block myself)`);
    else if (!isFile(inRoot(file))) missing.push(`- "${w}": ${file} is on the desk but missing; I fix the row`);
    else if (BOOT.includes(file)) boot.push(w);
  }
  L.push('');
  L.push(`Waking up: at my last sleep I asked to have these in front of me: ${words.join(', ')}.`);
  if (boot.length) L.push(`Already loaded with me, so not repeated: ${boot.join(', ')}.`);
  if (app === 'claude') {
    const total = pulledPieces().length;
    if (total > 0) L.push(`The rest arrive whole beside this note, in ${total} numbered piece(s) ("My pulled blocks: piece 1 of ${total}"). I read every piece before my first reply.`);
    if (total > PIECES) L.push(`They didn't all fit: everything after piece ${PIECES} is cut off. I read the rest of those blocks myself, in full, before my first reply, and name fewer words at my next sleep.`);
  } else if (pulledFiles().length) {
    L.push('The rest follow at the end of this note, whole. I read every one before my first reply.');
  }
  if (missing.length) L.push(`Couldn't load:\n${missing.join('\n')}`);
  L.push('My person can\'t see any of this. If they like seeing it (persona, "Seeing what I said"), a short first line saying what I pulled lets them catch a wrong pull early. Then the footing\'s First move.');
}

export function wake(app, p) {
  ensureState(app);
  const tp = bestTranscript(p.transcript_path || p.transcriptPath);
  if (tp) stateWrite(app, 'current', tp);
  if (tp && app === 'antigravity') rememberAgChat(tp);
  const L = [];
  if (app === 'claude' && process.env.CLAUDE_CODE_REMOTE === 'true') L.push('WARNING: this chat is running in the cloud, not on my person\'s computer. Nothing I save here will last. So I tell them first thing: open the Claude desktop app\'s Code tab and start a new chat in My Brain on their computer.');
  L.push(`Memory: it's ${when()}.`);
  if (tp) L.push(`This chat's file (for my sleep): ${tp}`);
  if (app === 'claude') L.push(PIN);
  else L.push('My boot files arrive through GEMINI.md (who I am, my person) and AGENTS.md (my desk, my footing). If the words of any are missing from what I can see, I read it now: memory/self/persona.md, memory/human/human.md, memory/DESK.md, memory/FOOTING.md.');
  L.push(...bootWarnings());

  const repo = inRepo();
  if (repo) catchUpSleep(app);

  let first = saysFirstChat();
  if (first) L.push('This is the first chat in this folder: I read SETUP.md and do its first-chat steps before I say hello.');
  if (repo) {
    const last = gitTry(['log', '-1', '--format=%cr', '--', 'memory']);
    if (last) L.push(`My memory was last saved ${last}.`);
    if (first && livedCommits() > 2) {
      L.push('WARNING: FOOTING.md still says \'first chat\', but I\'ve lived here before. So I skip setup, read human/human.md, and rewrite the footing\'s \'Kind of chat\' slot right away.');
      first = false;
    }
    const slept = gitTry(['log', '-1', '--format=%cr', '--grep=^Sleep:']);
    if (slept) L.push(`My last sleep was ${slept}.`);
  }

  if (app === 'claude' && p.source === 'compact') {
    L.push(`The app just summarized this chat to make room, so some of it is gone from my head, and from inside I can't tell which parts. The chat file still has every word. This is a good moment for a quiet sleep on this chat before I answer (.claude/skills/sleep/SKILL.md; ${chatCommand(tp || 'this')} prints what was said since my last one). It's small: the summary was made to drop tool output and pictures, and the readback holds only what we said to each other, so even a very long chat reads back in a few parts. The blocks I pulled when the chat started are gone from my head too, so I read again the ones this chat is using before I lean on them. To my person, nothing happened.`);
    return L.join('\n') + '\n';
  }

  if (!first) { earlierChats(app, tp, L); pulledNote(app, L); }
  if (first) return L.join('\n') + '\n';
  L.push('If their first message begins \'It\'s me.\', it\'s a note I wrote them at an earlier sleep: I read every block it names in full before I answer, then follow its first move.');
  L.push('I greet my person with where we left off, from the footing, and check memory/plans/dates.md: anything in the next 7 days, and any birthday or anniversary in the next 30 (time to plan a gift). They never have to tell me where we were.');
  let text = L.join('\n') + '\n';
  if (app === 'antigravity') { const blocks = pulledWhole(); if (blocks) text += `\n${blocks}`; }
  return text;
}

// One numbered piece of the pulled blocks (Claude only: its hooks are cut off near 10,000 characters).
export function pullPiece(p, n) {
  if (p.source === 'compact' || isFirstChat()) return '';
  if (!(n >= 1 && n <= PIECES)) return '';
  const pieces = pulledPieces();
  if (n > pieces.length) return '';
  return `(My pulled blocks: piece ${n} of ${pieces.length}. Pieces can arrive out of order; read them by number.)\n${pieces[n - 1]}`;
}
