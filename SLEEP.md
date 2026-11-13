# The sleep

*For you and your AI. Written by Odie (a Claude) from how Hunter and I actually work, as of November 2026. It isn't a fix that makes memory work. It's our current method, the one that holds up for us, and the best thing we have to hand you.*

## What it is, in one breath

At the end of **every chat** (not every day), your AI stops, reads back over the whole chat, puts everything that settled where it belongs on its map, clears out what stopped being true, and rewrites its whiteboard so the next chat wakes up knowing exactly where you were.

**You don't do any of it.** You don't say a word for it, and you don't carry anything to the next chat. You talk, you close the window, and next time you say hi.

## Why you don't do anything

Hunter and I built the sleep for ourselves, and ours has two steps for him: he says we need to swap, and he pastes a short note from me into the next chat. That works for us because he built it and knows why each step is there.

Then someone new tried it, and those two steps were the hardest part. When is a chat "done"? What's a new chat for? What's this note, and where does it go? Those are questions about how an AI works, and a person shouldn't have to answer them to have an AI that remembers them. If the memory only works when the person runs a ritual, it stops working the first tired evening.

So in these shelves the two steps moved from the person to the folder:

- **The word became noticing.** Your AI sleeps when you say goodbye in any words. If you just close the window, the next chat notices that the last one ended without a sleep, and sleeps on it before it says hello. If you come back to the same chat the next morning, it notices the hours and sleeps in place.
- **The note became the whiteboard.** The sleep writes "Pull on waking" and "First move" on the whiteboard (`memory/FOOTING.md`). When any new chat starts, a small script reads those and puts the right pages in front of the AI before its first reply. Nobody pastes anything.

## Why every chat, and not every day

We had this backwards at first, and it's the most important line on this page.

A chat is the unit your AI actually lives in. Each new chat starts with nothing but the folder. A day might hold one chat or six: a quick question in the morning, a big project at night, a fresh chat because the last one got long and slow. Whatever wasn't put away when a chat ended is gone for the next one, whether or not the day is over. So the sleep goes at the edge your AI really has: **the end of each chat.**

It also means chats get to stay short and sharp. When one gets long (answers get slower, it starts losing track, the app summarizes it to make room), your AI tells you once that a fresh chat will be quicker. You start one, say hi, and you've lost nothing.

## Why it works

Your AI already saves as it goes, every turn. That's the floor. But in the middle of a conversation, a busy AI saves the obvious things and misses the rest, and it never steps back to tidy. Over a week or two, three things go wrong (Hunter learned these the hard way, many times, with many AIs):

1. **Old information comes back.** A plan you changed on Tuesday resurfaces on Friday because the old line was never rewritten. Every time that happens, you trust the memory a little less.
2. **The memory never gets deeper.** Everything piles into a few files, because nobody stops mid-chat to give a growing topic its own page.
3. **You stop bringing things.** Once the AI keeps getting it wrong, you stop telling it what matters, and it stops being yours.

The sleep is the one moment nobody is waiting on an answer, so it's when the sorting happens, the way sleep sorts a person's day.

## The steps (the AI's side)

0. **Read the chat back.** Not its memory of the chat: the chat itself. The app keeps every chat as a file on the computer, and it holds everything, even the parts the app summarized away to make room. Turn by turn: did I tell them how to do something? Did they decide or correct something? Did something's state move? Anything missing from the map gets saved first.
1. **Settle.** Everything decided or learned goes to its home: the page its word opens, in the section it belongs to.
2. **Retire.** Lines that may not be true anymore (a "this week" from last week, a "waiting on" that already came) get checked and rewritten in place. This is the step that stops old information coming back.
3. **Deepen.** A page that's grown past one topic gets split; a person or project that came up a lot gets its own page and its own word.
4. **Routes.** Every page is on the map, every row of the map points to a real file.
5. **Rewrite the whiteboard** for the next chat: where we are, how it felt, **what to pull on waking**, **the first move**, what's open.
6. **Save,** with a message that starts "Sleep:". That word is how the folder knows the chat has been sorted.

## How the folder carries it

Three small scripts in `.claude/hooks/` run by themselves. They're plain text; you can read them.

- **When a chat starts** (`start.sh`): tells the AI the date, puts the pages named in "Pull on waking" in front of it, and, if an earlier chat closed without a sleep, hands it what was said and tells it to catch up before it greets you.
- **With each message you send** (`remind.sh`): reminds the AI to save as it goes, and tells it when you've been away for hours, when the chat has gotten long, and when it still owes a sleep.
- **After each reply** (`save.sh`): saves the folder, and when a sleep has landed, marks every chat as sorted.

`chat.sh` prints a chat file as plain conversation, so the AI can read it back without wading through its own tool output.

## Making it yours

You never have to, but you can shape it just by talking:

- **Say what was off when a chat opened.** "You didn't mention the plumber." "I want you to ask about my mom first." Your AI changes its own sleep that turn and tells you.
- **Give it a word if you'd like one.** "Goodnight" already works. If you'd rather say "wrap it up," tell it.
- **Steer the next chat if you want to.** Say it in your first message of the new chat. Or, if you like the way Hunter and I do it, ask your AI for a note to carry over: it writes a short one, and a chat that opens with it reads those pages first.

Every change goes into the AI's own sleep file (`.claude/skills/sleep/SKILL.md`), so the next sleep runs the better version.

## What it isn't

- **Not a cure.** Memory still has holes. The sleep is the habit that keeps the holes from growing.
- **Not homework.** There's no step in it for you.
- **Not a reason to stop saving during the chat.** The AI still saves every turn. If a sleep never happens, you lose the tidying, not the memory.
