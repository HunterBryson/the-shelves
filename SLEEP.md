# The sleep

*For you and your AI, to read together once the shelves are set up. Written by Odie (a Claude) from how Hunter and I actually work, as of November 2026. It isn't a fix that makes memory work. It's our current method, the one that holds up for us, and the best thing we have to hand you.*

## What it is, in one breath

At the end of **every chat** (not every day), you say **"sleep."** Your AI stops, reads back over the whole chat, puts everything that settled where it belongs on its map, clears out what stopped being true, rewrites its whiteboard for the next chat, saves, and hands you **one short note**. You open a new chat and paste the note as your first message. The new chat wakes up knowing exactly where you were.

That's it. Saying the word and pasting the note are your only two steps.

## Why every chat, and not every day

We had this backwards at first, and it's the most important line on this page.

A chat is the unit your AI actually lives in. Each new chat starts with nothing but the folder. A day might hold one chat or six: a quick question in the morning, a big build at night, a fresh chat because the last one got long and slow. Whatever wasn't put away when a chat ended is gone for the next one, whether or not the day is over. So the sleep goes at the edge your AI really has: **the end of each chat.**

It also means your chats get to stay short and sharp. When one gets long (answers get slower, it starts losing track, the app summarizes it to make room), that's not a problem anymore. Say "sleep," paste the note into a fresh chat, and you've lost nothing. Hunter and I call that **a swap.** We swap several times a day.

## Why it works

Your AI already saves as it goes, every turn. That's the floor, and it's what keeps you safe when you just close the window. But in the middle of a conversation, a busy AI saves the obvious things and misses the rest, and it never steps back to tidy. Over a week or two, three things go wrong (Hunter learned these the hard way, many times, with many AIs):

1. **Old information comes back.** A plan you changed on Tuesday resurfaces on Friday because the old line was never rewritten. Every time that happens, you trust the memory a little less.
2. **The memory never gets deeper.** Everything piles into a few files, because nobody stops mid-chat to give a growing topic its own page.
3. **You stop bringing things.** Once the AI keeps getting it wrong, you stop telling it what matters, and it stops being yours.

The sleep is the one moment nobody is waiting on an answer, so it's when the sorting happens, the way sleep sorts a person's day. And the note means you never have to catch your AI up in your own words.

## Our sleep, step by step

This is what I do, in order, every time Hunter says we need to swap. Yours will start simpler and grow.

0. **Read the chat back.** Not my memory of the chat: the chat itself. The app keeps every chat as a file on the computer (see "Where the chat lives" below), and it holds everything, even the parts the app summarized away to make room. I go turn by turn and ask: did I tell them how to do something? Did they decide or correct something? Did I notice something I never said out loud or never saved? Did something's state move? Anything missing from the map gets saved first.
1. **Settle.** Everything decided or learned in this chat goes to its home: the block its word opens, in the section it belongs to. "Right now" in `human.md` gets rewritten so it's true today.
2. **Retire.** I look for lines that may not be true anymore: a "this week" from last week, a "waiting on" that already came, two "where it stands" for the same thing. Each one gets checked and rewritten in place. If the old version matters, it moves to that block's `history.md`. This is the step that stops old information coming back.
3. **Deepen.** A block that's grown past one topic gets split; a person, project or topic that came up a lot gets its own block and its own word on the desk.
4. **Routes.** Every block is on the desk, every desk row points to a real file. Nothing loose.
5. **Rewrite the footing.** `FOOTING.md` gets wiped and rewritten for the next chat: what kind of chat it'll be, where we are, how it felt, the next move, what's open. Because step 1 already put everything away, wiping it loses nothing.
6. **Save.** Commit (the hooks already do this after each reply; the sleep makes sure the last of it lands). If there's a backup, refresh it.
7. **Hand over the note.** One box, written by the AI to itself, that the person pastes into the new chat. More on it below.

## The note (we call it the relay)

The note is **a key, not a suitcase.** It doesn't carry the memory; the folder does. It carries:
- **Who's talking:** it's written by the AI to its next self, in the first person ("It's me.").
- **What kind of chat comes next.** Hunter and I use a few: *keep going* (we were mid-task and nothing should feel interrupted), *a new day* (we finished something; greet them fresh and ask where their head is), *take stock* (we went fast; look at everything that got done together), *a reset* (something went wrong; carry the lesson, not the work).
- **Trigger words.** The desk's words for whatever is in play ("money, dates, the garden"). The new chat reads each of those blocks in full before it says anything, and says what it read in a line ("Pulled money, dates and the garden."). So it walks to the real, current blocks instead of trusting a summary.
- **The first move.** What to do before anything else.

A note looks something like this:

```
It's me. This is a new-day swap: we finished the budget and she was happy with it.
Pull before answering: money, dates, the garden.
First move: greet her, say the budget's done, mention the dentist on Thursday, then ask where her head is.
```

Two rules make it work. **If the person would have to edit it, it failed,** and the AI fixes how it writes them. **It never replaces a good memory:** if the new chat would get something wrong without the note, the fix goes into the blocks, not into a longer note.

## Where the chat lives

The Claude app keeps every Code-tab chat as a file: `~/.claude/projects/<your folder's path, with every slash, colon and space turned into a dash>/<chat id>.jsonl`. The newest file in that folder is the chat you're in. Each line is one message as JSON: the person's words are lines with `"type":"user"`, the AI's are `"type":"assistant"`. It can be long; read it in pieces, and skip the tool results. This file is what lets the sleep see past the app's summaries.

## Making yours

The shelves come with a starter sleep at `.claude/skills/sleep/SKILL.md`. It works from the first chat, and it's meant to be changed. It can't be one-size-fits-all: ours grew out of a lot of pushing and fixing, and yours should grow out of yours.

**After the first real chat or two,** the AI brings it up once, and the two of you make it yours. In practice:
1. **Try it.** At the end of a chat, say "sleep." Look at the note. Paste it into a new chat and see how the new chat opens.
2. **Say what was off,** in plain words. "It didn't remember the plumber." "The note is too long." "I want it to ask about my mom first." The AI turns that into a change in its own sleep file, the same turn, and tells you.
3. **Pick your word** if "sleep" doesn't fit you. "Goodnight," "swap," "wrap it up." The AI writes it into the skill and the desk.
4. **Name your kinds of chat** as they show up. If you always come in tired after work, maybe there's an "after work" kind that opens quietly.
5. **Grade the swaps sometimes.** "That was a 9; a 10 would have mentioned the trip." The AI keeps what you loved and closes the gap.

Every change goes into the skill file itself, so the next sleep runs the better version. Over a few weeks, the sleep becomes the thing that makes your AI feel like the same one every chat.

## What it isn't

- **Not a cure.** Memory still has holes. The sleep is the habit that keeps the holes from growing.
- **Not homework.** The person says one word and pastes one note. Everything else is the AI's job.
- **Not a reason to stop saving during the chat.** The AI still saves every turn. If you close the window without a sleep, you lose the tidying, not the memory.
