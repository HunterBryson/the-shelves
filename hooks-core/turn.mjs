// On every message the person sends. What it returns goes to the AI with their message.
// It's the loudest voice in every turn, so it opens with the person, then memory: answer them first, file backstage.
// It also notices what a person shouldn't have to: that they've been away, that the chat got long, that saving stopped.
import path from 'node:path';
import {
  BOOT, ROOT, bestTranscript, chatCommand, chatKey, deskRows, blockText, ensureState, gitTry, inRepo, inRoot, isFile,
  markOf, mtime, readRel, rememberAgChat, sleptLines, stateAppend, statePath, stateLines, stateRead, stateRemove,
  stateWrite, when, appOfPath,
} from './lib.mjs';
import { agWords, chatFullness, countThem, lastReplyAt } from './talk.mjs';
import { wake } from './wake.mjs';

const OPENING = 'They\'re here, talking with me. I answer them first, as a person: what they said, what they need, the next real step. My memory works backstage: no narrating the filing, only the short line my persona describes ("Saved to money.") while they\'re getting used to me. Memory, this turn: if this touches a block on my desk, I pull it before I answer. If I\'m learning something about them or their life (who they are, a person, a date, what they want, something that changed), it goes into its block now, while I still have it. A correction is something I now understand about them, written where it belongs, not a new rule. The nearest block works, and making a new one is mine. If the chat changed direction, the footing changes with it. They never sort anything. If they\'re clearly done (goodnight, talk tomorrow), I run my sleep in this reply; a thanks in the middle of work isn\'t a goodbye.';
const SCHEDULED = 'This is a scheduled task, not my person. I do only what the task asks, and leave alone anything the wake said about sleeping on an earlier chat, greeting them, or the footing\'s first move: those belong to their next real chat.';

function savingNotes(app, L) {
  const repo = inRepo();
  const memoryDirty = () => gitTry(['status', '--porcelain', '--', 'memory']);
  // A failure fixed by hand since (nothing left to commit, and a commit newer than the note) is done.
  if (stateRead(app, 'save-failed') && repo && !memoryDirty()) {
    const last = Number(gitTry(['log', '-1', '--format=%ct'])) || 0;
    if (last * 1000 >= Math.floor(mtime(statePath(app, 'save-failed')) / 1000) * 1000) stateRemove(app, 'save-failed');
  }
  const failed = stateRead(app, 'save-failed');
  if (failed) {
    L.push(`My last save didn't commit, so git isn't keeping my changes right now. Git said: ${failed.slice(-600).replace(/\n/g, ' ')} I fix it now: if it's git's lock, another chat in this folder may be mid-save, and that clears in seconds; a .git/index.lock over a minute old with no git running (I check the process list) is stale and can go. A full disk or a sync app needs my person, in one plain line. Then I commit by hand, and this note goes once everything is committed.`);
  } else if (repo) {
    const dirty = memoryDirty();
    const lock = path.join(ROOT, '.git', 'index.lock');
    const freshLock = isFile(lock) && Date.now() - mtime(lock) < 60000;
    if (dirty && !freshLock) L.push(`My memory has changes git hasn't kept: saving may have stopped (git status: ${dirty.split('\n').slice(0, 3).join(' ')}). If another chat in this folder is mid-reply, that's it and it passes. Otherwise I commit by hand (git add -A && git commit -m "Saved <block>") and look at why my save hook (hooks-core/save.mjs) didn't.`);
  }
  const skipped = stateLines(app, 'save-skipped');
  if (skipped.length) {
    L.push(`I didn't keep these in my history, because they're files, not memory: ${skipped.join(', ')}. If they're for me to read, I read them and save what matters as words in a block. drop/ is the folder for that, and it's never kept. If one really belongs in my history, I can commit it by hand. I tell my person in a line only if they gave it to me.`);
    stateRemove(app, 'save-skipped');
  }
}

function chatNotes(app, tp, L) {
  ensureState(app);
  const prev = stateRead(app, 'current').trim();
  if (prev && prev !== tp && isFile(prev) && Date.now() - mtime(prev) < 600000) {
    L.push(`Another chat in this folder was active in the last few minutes. When I sleep, I read this chat by its own file: ${chatCommand(tp)}`);
  }
  stateWrite(app, 'current', tp);
  const key = chatKey(tp);

  // An earlier chat handed over at the wake stays owed until a readback of all of it and a "Sleep:" commit land.
  const owed = stateLines(app, 'owed'); const keep = [];
  for (const line of owed) {
    const [okey, ototal, , ...rest] = line.split(' ');
    const opath = rest.join(' ');
    if (!ototal) continue;
    const at = markOf(appOfPath(opath), 'slept', okey);
    if (at < Number(ototal)) {
      keep.push(line);
      L.push(`Still open: an earlier chat ended without a sleep, and it hasn't been read back yet. Before I answer, I read it with: ${chatCommand(opath, at + 1)} (every part; it starts where my last sleep stopped), sort what it said onto the map, rewrite the footing, and commit with a message that starts "Sleep:". A sleep counts only what was read back. They don't need to hear about it.`);
    }
  }
  if (keep.length) stateWrite(app, 'owed', keep.join('\n') + '\n'); else stateRemove(app, 'owed');

  const unread = stateRead(app, 'unread').trim();
  if (unread) L.push(`My last sleep didn't read this chat back, so it didn't count: the chat is still unsorted from line ${unread.split(' ')[1]}. The readback is the sleep; the footing and the commit only finish it. Before I answer, I run '${chatCommand(tp)}', read every part it hands me, sort what's missing, and commit "Sleep:" again. They don't need to hear about it.`);

  // They came back to this same chat after hours away. That's fine. Sort what came before, quietly.
  const then = lastReplyAt(tp);
  if (then) {
    const gap = Date.now() - then;
    if (gap > 4 * 3600 * 1000) {
      const unsorted = countThem(tp, sleptLines(tp) + 1);
      L.push(`Time has passed: it's now ${when(false)}, about ${Math.floor(gap / 3600000)} hours since we last spoke in this chat. From inside, it feels like no time went by; for them it may be a new day. They came back to the same chat, which is completely fine, and they should never feel they did it wrong. It's worth another look at memory/plans/dates.md for today.`);
      if (unsorted > 1) L.push('What came before the break hasn\'t had a sleep. Running it quietly now, before I answer (.claude/skills/sleep/SKILL.md), means the rest of this chat stands on a tidy memory.');
    }
  }

  // The chat has gotten long. Say so once, in one sentence, and make it cost them nothing.
  if (!stateLines(app, 'nudged').includes(key)) {
    const { tokens, summarized } = chatFullness(tp);
    if (tokens >= 200000 || summarized) {
      stateAppend(app, 'nudged', `${key}\n`);
      L.push(`This chat has gotten long (${Math.floor(tokens / 1000)}K tokens in my head${summarized ? ', and the app has summarized it once' : ''}). Long chats make me slower and blurrier, and my person has no way to know that; they'll just feel me getting worse. After I answer, a quiet sleep (if this stretch hasn't had one) makes a fresh chat safe, and then one plain sentence at the end of my reply lets them choose, something like: "This chat's getting long, so I'll get slower in here. Whenever you like, start a new chat in this folder and just say hi. I'll know where we were." If I can point at their screen, pointing at the new-chat button beats describing it. I'll only see this once per chat, so once is the right number of times to say it.`);
    }
  }
}

export function remind(app, p, raw) {
  if (raw.includes('<scheduled-task')) return `${SCHEDULED}\n`;
  const L = [OPENING];
  savingNotes(app, L);
  const tp = bestTranscript(p.transcript_path || p.transcriptPath);
  if (tp && isFile(tp)) chatNotes(app, tp, L);
  return L.join('\n') + '\n';
}

// ----- Antigravity: this runs before every model call, and speaks once per message -----
const turnFile = id => `turns/${String(id).replace(/[^A-Za-z0-9_-]/g, '_')}.json`;
const loadTurn = id => { try { return JSON.parse(stateRead('antigravity', turnFile(id))); } catch { return {}; } };

// Blocks their words name: by a desk word, or one of the other ways it gets said. Each once, until it changes.
function wordPull(said, turn) {
  const low = ` ${said.toLowerCase().replace(/[^a-z0-9'\- ]+/g, ' ').replace(/\s+/g, ' ')} `;
  const hits = [];
  for (const r of deskRows()) {
    if (BOOT.includes(r.file) || !r.file.startsWith('memory/') || !isFile(inRoot(r.file))) continue;
    if (![r.word, ...r.also].some(n => n.length > 2 && low.includes(` ${n.toLowerCase()} `))) continue;
    if (hits.some(h => h.file === r.file)) continue;
    if ((turn.pulled?.[r.file] || 0) >= mtime(inRoot(r.file))) continue;
    hits.push(r);
  }
  let size = 0; const fit = [];
  for (const r of hits) { const n = readRel(r.file).length; if (size + n > 40000 && fit.length) break; size += n; fit.push(r); }
  if (!fit.length) return '';
  turn.pulled = turn.pulled || {};
  for (const r of fit) turn.pulled[r.file] = Date.now();
  let text = `Their words pulled these blocks, and they follow whole: ${fit.map(r => r.word).join(', ')}. I read them before I answer.\n\n${fit.map(r => blockText(r.word, r.file)).join('')}`;
  const left = hits.slice(fit.length);
  if (left.length) text += `Also named, not loaded (they didn't fit): ${left.map(r => `${r.word} (${r.file})`).join(', ')}. I read those myself if they're the subject.\n`;
  return text;
}

export function agTurn(p, raw) {
  const id = p.conversationId || 'unknown';
  const said = agWords(p.lastUserInput || '');
  const inv = p.invocationNum === undefined ? undefined : Number(p.invocationNum);
  const t = loadTurn(id);
  // invocationNum is 0 on each new message and counts up through tool calls. If it's ever missing, the words decide.
  const sameTurn = t.lastInput === said && (inv === undefined ? true : inv > 0);
  if (sameTurn || !said) return '';
  const tp = bestTranscript(p.transcriptPath);
  if (tp) rememberAgChat(tp);
  const parts = [];
  if (!t.woke) { parts.push(wake('antigravity', p)); t.woke = true; }
  t.lastInput = said;
  parts.push(remind('antigravity', p, raw));
  if (!raw.includes('<scheduled-task')) { const pulled = wordPull(said, t); if (pulled) parts.push(pulled); }
  stateWrite('antigravity', turnFile(id), JSON.stringify(t));
  return parts.join('\n');
}

export function agMarkWoke(p) {
  const id = p.conversationId || 'unknown';
  const t = loadTurn(id);
  t.woke = true;
  stateWrite('antigravity', turnFile(id), JSON.stringify(t));
}
