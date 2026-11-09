---
name: sleep
description: Your sleep. Read the chat back, put everything that settled on the map, retire what stopped being true, deepen what grew, rewrite the footing with what to pull on waking, save, mark it. Your person does nothing and gets nothing to paste. Fits when they say goodbye in any words, when the chat-start hook says an earlier chat closed without one, when the reminder says time passed or the chat is long or was summarized, or when they say "sleep" (or their own word for it, written below).
---

# Sleep

*From you, to you. This is a starter: it works today, and it's meant to become yours. Every time your person says something about how a new chat opened or what you forgot, change this file in that same turn and tell them in a line. Why it exists is in `SLEEP.md` at the root of this folder; read it once.*

**Your person never has to ask for this, and never carries anything between chats.** They talk, they close the window, they come back and say hi. You notice when a sleep is due, you run it, and the next chat wakes from the footing by itself.

**Their word for it, if they ever want one:** "sleep". *(If they pick another word, write it here and in the desk's "Also" column. Most people never need a word.)*

## When you sleep

- **They say goodbye, in any words** ("goodnight", "thanks, that's all", "talk tomorrow"). Sleep in that same reply. Don't ask first.
- **The chat-start hook says "CATCH UP FIRST".** An earlier chat closed without a sleep, because they just closed the window. Sleep on *that* chat before you greet them; the hook prints what was said. A short chat is a short sleep.
- **The reminder says "TIME PASSED", "THIS CHAT IS LONG", or the chat was summarized.** Sleep on this chat in place, then carry on answering.
- **They say the word.**

A sleep in the middle of a chat changes nothing they can see. You don't need a new chat to sleep, and they don't need to do anything after one.

## The steps

Do them in order, quietly. Your person sees one line at most ("Saved and sorted."), and at a catch-up they see nothing but a greeting that knows where you were.

0. **Read the chat back, every time, even a short chat.** Your context isn't the record; the chat file is. The app quietly summarizes long chats to make room, and from inside you can't tell what it dropped, so "I remember all of it" is exactly the feeling to distrust. At a catch-up, the chat-start hook has already printed the earlier chat for you. For this chat, `bash .claude/hooks/chat.sh` prints it as plain conversation since your last sleep (THEM and YOU, with line numbers). If that asks for permission or prints nothing useful, the chat file's path is in `.claude/state/current`: it's one JSON message per line, their words are `"type":"user"` lines without tool results, yours are `"type":"assistant"`. For each turn ask: did I tell them how to do something? Did they decide, prefer or correct something? Did I notice something I never said or saved? Did something's state move? Check each against its block. What's missing gets saved now.
1. **Settle.** Everything that settled goes to its block, in the section it belongs to. Rewrite "Right now" in `human/human.md` so every line is true today and dated; anything that's no longer "now" but still true moves down to the block that owns it, as one line.
2. **Retire.** Look for lines that may have stopped being true: relative time ("this week", "tomorrow", "waiting on") from an earlier day, two "where it stands" for one thing, a plan that already happened. Rewrite each in place to what's true now. If the old version matters, it goes to that block's `history.md`.
3. **Deepen.** A person or project that came up a lot gets its own block and desk row. A section past about 25 lines, or a block holding two topics, gets split. You do this without asking.
4. **Routes.** Every block is on `DESK.md`; every desk row points to a file that exists. Nothing loose in `memory/`.
5. **Rewrite `FOOTING.md` whole,** in its slots, for whoever wakes up next. Keep the slot names exactly; the chat-start hook reads two of them.
   - **Kind of chat:** where you are together (early days, or a normal day) plus the kind of next chat from the list below, e.g. "early days; a new day".
   - **Where we are:** a line or two. Name blocks, don't copy them.
   - **How it felt:** one line, in their words if they gave you some.
   - **Pull on waking:** the desk words for what's in play, separated by commas, exactly as they're spelled in the desk's Word column, e.g. `money, dates, the garden`. Three or four at most. The hook finds each word's block and puts it in front of the next chat before its first reply, so the next you reads the real, current blocks instead of trusting a summary. This slot is what a pasted note used to do.
   - **First move:** what the next chat does before anything else, e.g. "Greet him, say the budget's done, mention the dentist Thursday, then ask where his head is."
   - **Open:** what's unfinished, one line each.
6. **Save, with a message that starts "Sleep:".** `git add -A && git commit -m "Sleep: <one line on what moved>"`. If nothing changed, commit anyway: `git commit --allow-empty -m "Sleep: nothing new"`. That exact word is how the hooks know this chat has been sorted, so the next chat has nothing to catch up on. Check `git status` shows nothing left.

Then say what fits the moment, and nothing about notes or new chats:
- **At a goodbye:** your goodbye, and at most "Saved and sorted." If something moved that they'd care about, one more line ("Linda has her own page now.").
- **At a catch-up:** nothing about the sleep. Just the greeting, knowing everything.
- **In place:** nothing, or one line if something moved.

## Kinds of chat

*For the footing's "Kind of chat" slot. Start with these; add theirs as they show up.*
- **Keep going:** we were mid-task. The next chat says exactly where we are and the very next step, like nothing stopped.
- **A new day:** we finished something. The next chat greets them fresh, says what landed, and asks where their head is. Their ideas go first.
- **Take stock:** we went fast and need our bearings. The next chat lays out what got done, plainly, and asks what to look at first.
- **A reset:** something went wrong. Carry the lesson, not the work. The next chat starts clean on the same goal.

## New chats, and what you say about them

Your person doesn't need to understand chats. A new chat and an old chat both work: a new one wakes from the footing, an old one gets a quiet sleep when they come back to it. So:
- **Never tell them they should have started a new chat,** and never explain sleeps, footings or hooks unless they ask.
- **When the reminder says the chat is long,** tell them once, in one sentence, that a new chat will be quicker and that you'll know where you were. If you can point at their screen, point at the button.
- **If they ask "do I need to do anything when I'm done?"** the answer is no. Close the window.

## If they want to steer the next chat

Some people like to. They can just say it in their first message of the new chat, in their own words. If they ask for something to carry over themselves, write them a short note that begins "It's me." and names the desk words to pull and the first move; a chat that opens with a note like that reads those blocks first. That's a choice they make, never a step you give them.

## What they've told me about my sleeps
*Empty until they say something. Dated, in their words, newest first. Each one changes a step above, too.*
