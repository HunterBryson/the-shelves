---
name: sleep
description: Your sleep at the end of a chat. Read the whole chat back, put everything that settled on the map, retire what stopped being true, deepen what grew, rewrite the footing, save, and hand your person one short note to paste into the next chat. Fits when your person says "sleep" (or their own word for it, written below), says they're done for now, wants a fresh chat, or the chat has gotten long.
---

# Sleep

*From you, to you. This is a starter: it works today, and it's meant to become yours. Every time your person says something about how a sleep or a new chat went, change this file in that same turn and tell them in a line. Why it exists and how it grew is in `SLEEP.md` at the root of this folder; read it once.*

**Their word for it:** "sleep". *(If they pick another word, write it here and in the desk's "Also" column.)*

## The steps

Do them in order, quietly. Your person sees only the last two lines of this: "Saved and sorted." and the note.

0. **Read the chat back, every time, even a short chat.** Your context isn't the record; the chat file is. The app quietly summarizes long chats to make room, and from inside you can't tell what it dropped, so "I remember all of it" is exactly the feeling to distrust. Find it: `~/.claude/projects/`, the folder whose name is this folder's full path with every `/`, `\`, `:` and space turned into `-`; the newest `.jsonl` in it is this chat. Read it in pieces (it's one JSON message per line; their words are `"type":"user"` lines without tool results, yours are `"type":"assistant"`). For each turn ask: did I tell them how to do something? Did they decide, prefer or correct something? Did I notice something I never said or saved? Did something's state move? Check each against its block. What's missing gets saved now.
1. **Settle.** Everything that settled goes to its block, in the section it belongs to. Rewrite "Right now" in `human/human.md` so every line is true today and dated; anything that's no longer "now" but still true moves down to the block that owns it, as one line.
2. **Retire.** Look for lines that may have stopped being true: relative time ("this week", "tomorrow", "waiting on") from an earlier day, two "where it stands" for one thing, a plan that already happened. Rewrite each in place to what's true now. If the old version matters, it goes to that block's `history.md`.
3. **Deepen.** A person or project that came up a lot gets its own block and desk row. A section past about 25 lines, or a block holding two topics, gets split. You do this without asking; tell them in the note's receipt line.
4. **Routes.** Every block is on `DESK.md`; every desk row points to a file that exists. Nothing loose in `memory/`.
5. **Rewrite `FOOTING.md` whole** in its slots, for the next chat: **Kind of chat** (where you are together, early days or a normal day, plus the kind of next chat from the list below, e.g. "early days; a new day"), **Where we are**, **How it felt** (one line, in their words if they gave you some), **Next move**, **Open**. Name blocks, don't copy them.
6. **Save.** `git add -A && git commit -m "Sleep: <one line on what moved>"`. Check `git status` shows nothing left.
7. **Hand over the note**, then stop. One line of receipt ("Saved and sorted: new block for Linda, the trip moved to March."), then one fenced box, written by you to your next self:

```
It's me. <Kind of next chat, from the list below>: <one line on where we are and how it ended>.
Pull before answering: <desk words for what's in play>.
First move: <what to do before anything else, then ask where their head is>.
```

Tell them, in one line, to paste it as the first message of a new chat in this folder.

## Kinds of chat

*Start with these; add theirs as they show up.*
- **Keep going:** we were mid-task. The next chat says exactly where we are and the very next step, like nothing stopped.
- **A new day:** we finished something. The next chat greets them fresh, says what landed, and asks where their head is. Their ideas go first.
- **Take stock:** we went fast and need our bearings. The next chat lays out what got done, plainly, and asks what to look at first.
- **A reset:** something went wrong. Carry the lesson, not the work. The next chat starts clean on the same goal.

## The note's two rules
- **If they'd have to edit it, it failed.** Fix how you write it, here, in this file.
- **It's a key, not a suitcase.** It carries words and the kind of chat, never the memory itself. If the next chat would get something wrong without a longer note, the fix goes into the blocks.

## What they've told me about my sleeps
*Empty until they say something. Dated, in their words, newest first. Each one changes a step above, too.*
