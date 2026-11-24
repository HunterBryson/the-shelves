// After every reply. Commits whatever changed, so every version of my memory is kept and a bad rewrite can be undone.
// (Git is the undo, not a backup: it lives on this same computer.)
// It never fails quietly: if the commit doesn't land, git's own words go to save-failed and the next message hands them to me.
// It doesn't keep files that aren't memory: anything in drop/ (gitignored), and any new file over 5 MB or a document,
// archive or program outside memory/, is left out and named once in save-skipped.
import fs from 'node:fs';
import { bestTranscript, ensureState, git, gitTry, inRepo, inRoot, stateAppend, stateLines, stateRead, stateRemove, stateWrite } from './lib.mjs';
import { settleSleep } from './settle.mjs';

const NOT_MEMORY = /\.(pdf|doc|docx|xls|xlsx|ppt|pptx|zip|7z|rar|tar|gz|exe|msi|dmg|iso|key|pem|p12|kdbx)$/i;
const stamp = () => { const d = new Date(); const p = n => String(n).padStart(2, '0'); return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}`; };
const errText = e => String(e?.stderr || e?.message || e).trim();

function leaveOut(app) {
  const added = gitTry(['diff', '--cached', '--name-only', '--diff-filter=A', '-z']).split('\0').filter(Boolean);
  for (const f of added) {
    let big = false;
    try { big = fs.statSync(inRoot(f)).size > 5242880; } catch {}
    if (!big && (f.startsWith('memory/') || !NOT_MEMORY.test(f))) continue;
    gitTry(['reset', '-q', '--', f]);
    if (!stateLines(app, 'skipped-told').includes(f)) { stateAppend(app, 'save-skipped', `${f}\n`); stateAppend(app, 'skipped-told', `${f}\n`); }
  }
}

function label() {
  const names = list => list.slice(0, 5).join(', ');
  const mem = gitTry(['diff', '--cached', '--name-only', '--', 'memory']).split('\n').filter(Boolean);
  if (mem.length) return names(mem.map(f => f.replace(/^memory\//, '').replace(/\.md$/, '')));
  const all = gitTry(['diff', '--cached', '--name-only']).split('\n').filter(Boolean);
  return names(all.map(f => f.replace(/^\.claude\//, '').replace(/\.md$/, '').replace(/\.mjs$/, '').replace(/\/SKILL$/, ''))) || 'memory';
}

export function save(app, p) {
  if (!inRepo()) return;
  ensureState(app);
  try { git(['add', '-A']); }
  catch (e) { stateWrite(app, 'save-failed', `${stamp()}  git add: ${errText(e)}\n`); return; }
  // App scratch never reaches history, even in a brain whose .gitignore predates it.
  gitTry(['reset', '-q', '--', '.claude/state', '.agents/state']);
  leaveOut(app);

  if (gitTry(['diff', '--cached', '--name-only'])) {
    try {
      const name = process.env.GIT_AUTHOR_NAME || gitTry(['config', 'user.name']) || 'Claude';
      const email = gitTry(['config', 'user.email']) || 'claude@shelves.local';
      git(['-c', `user.name=${name}`, '-c', `user.email=${email}`, 'commit', '-q', '-m', `Saved ${label()}`]);
      stateRemove(app, 'save-failed');
    } catch (e) { stateWrite(app, 'save-failed', `${stamp()}  git commit: ${errText(e)}\n`); }
  } else stateRemove(app, 'save-failed');

  // A sleep just landed: each chat's mark moves only as far as its readback reached.
  const head = gitTry(['log', '-1', '--format=%H', '--grep=^Sleep:']);
  if (head && head !== stateRead(app, 'lastsleep').trim()) {
    // The chat that made this sleep: the app names it, since another window may have spoken last.
    settleSleep(app, bestTranscript(p.transcript_path || p.transcriptPath) || stateRead(app, 'current').trim(), head);
  }
}
