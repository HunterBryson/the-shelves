// A "Sleep:" commit landed. Each chat's mark moves only as far as its readback reached, in whichever app the chat
// happened, so a sleep that skipped reading the chat back can't hide that stretch from the next sleep.
import { APPS, chatKey, ensureState, isFile, markOf, setMark, sleptLines, stateLines, stateRemove, stateWrite } from './lib.mjs';
import { countThem } from './talk.mjs';

export function settleSleep(app, chatPath, sleepHash, { noUnread = false } = {}) {
  ensureState(app);
  stateRemove(app, 'unread');
  let readAny = false;
  for (const a of Object.keys(APPS)) {
    for (const line of stateLines(a, 'read')) {
      const [key, got] = line.split(' ');
      if (!key || !got) continue;
      readAny = true;
      if (Number(got) > markOf(a, 'slept', key)) setMark(a, 'slept', key, got);
    }
    stateRemove(a, 'read');
  }
  // A sleep that read an earlier chat back did its job, so only a sleep that read nothing is called out.
  if (!readAny && !noUnread && chatPath && isFile(chatPath)) {
    const from = sleptLines(chatPath) + 1;
    if (countThem(chatPath, from) > 0) stateWrite(app, 'unread', `${chatKey(chatPath)} ${from}\n`);
  }
  if (sleepHash) for (const a of Object.keys(APPS)) stateWrite(a, 'lastsleep', `${sleepHash}\n`);
}
