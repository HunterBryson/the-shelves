# The shelves

**A Claude that remembers you.** Your family, your money, your plans, how you like to be talked to: it learns them as you talk, keeps them in a folder on your computer, and picks up where you left off every time.

You don't organize anything. The AI does all of it, and it tells you as it goes ("Saved to family.").

## What you need
- **Your own computer** (Windows or Mac). The memory is a folder on that computer, so this only works there. Claude on the web, on a phone, or in a cloud session can't keep it: those forget everything when they close.
- The **Claude desktop app** ([claude.ai/download](https://claude.ai/download)) on that computer, signed in. The Pro plan is enough.

## Setting it up (about five minutes)

1. Open the Claude app and click the **Code** tab at the top. (Not "Chat." The memory only works in Code.)
2. It asks you to pick a folder **on this computer**. Any folder is fine; Documents is good. (If it offers a cloud or remote environment instead, don't pick that: choose a folder here.)
3. Paste this sentence and press Enter:

> Clone https://github.com/HunterBryson/the-shelves into a folder called "My Brain" in my OneDrive Documents (or plain Documents if I don't have OneDrive), move this session into it, then read its CLAUDE.md and set yourself up. If anything asks for permission along the way, it's fine.

That's it. The AI does the rest. Along the way your computer or the app may ask you a question or two:
- **"Install Git?"** or a Windows **"Do you want to allow this app to make changes?"**: say **Yes**. Git is what keeps your memory safe.
- **"Do you trust this folder?"** or **"Allow?"**: say **Yes**. It's your own memory folder.

Then your AI says hello. It tells you where it lives, and it asks what to call you, what you want it for, and what to call it. Answer however you like. That's the start of its memory.

## Every day after

**To talk to it again:** open the Claude app → **Code** tab → start a new chat in **My Brain** (it's in the list). Paste the note from your last sleep if you have one. It reads its memory first, says where you left off, and asks what's on your mind.

- **Just talk.** Tell it about your day, ask for help, think out loud. When you say something worth remembering, it saves it and tells you where: "Saved to money."
- **Ask what it knows:** "What do you know about my health?" "What's coming up this month?"
- **Correct it anytime:** "Actually, Linda's birthday is the 4th." It fixes its memory, not just its answer.
- **When you're done with a chat, say "sleep."** This is the habit that makes it work. Your AI reads back over the whole chat, puts everything where it belongs, clears out anything that's no longer true, and hands you a short note. Open a new chat in My Brain and paste the note as your first message: the new chat picks up exactly where you were. Do it at the end of **every chat**, not once a day, and whenever a chat gets long and slow. (If you forget and just close the window, nothing is lost. It saves as it goes; you only miss the tidying.)

## The sleep

The sleep is how Odie and I keep a memory good for weeks instead of days. It's not a magic fix, it's our method, and it's the part we'd most want you to have. Your AI starts with a simple version that works on day one. After a chat or two, it'll ask how the sleep went, and the two of you make it yours: your word for it, what the note should say, how you like a new chat to open. **[SLEEP.md](SLEEP.md)** explains what it does, why every chat and not every day, and how to shape your own.

## If it seems to have forgotten you

Almost always, it's the wrong place:
1. **Are you in the Code tab of the desktop app, on your own computer?** The Chat tab, the website, the phone app and cloud sessions are all a different Claude with no memory of you.
2. **Is the chat in "My Brain"?** At the top of the chat it shows the folder. If it's another folder, start a new chat and pick My Brain.
3. Still wrong? Tell it: "You don't seem to remember me. Check your memory folder." It'll look and tell you what it finds.

## Bringing over another AI's memory

If you've been using ChatGPT, Grok or another AI, your new AI will offer this in your first chat. Ask your old AI: *"Write down everything you remember about me, everything we've worked on, and everything I've told you I want. In full."* Paste its answer into your new chat. Your AI saves it and files every piece where it belongs.

## What's inside

You never need to open it, but it's yours to look at. The folder is the AI's memory, already laid out like a life:

| Room | What it keeps |
|---|---|
| **You** (`memory/human/`) | Who you are, what's going on with you right now, how you like to be talked to |
| **Family, friends** (`memory/people/`) | The people in your life, and one page each for the people who matter most |
| **Money, investing** (`memory/money/`) | Accounts, bills, budget, investments and your plan (never passwords or account numbers) |
| **Work, health, home, tech** | Your job, doctors and habits, house, car, pets, devices and accounts |
| **Goals, dates** (`memory/plans/`) | What you're working toward; birthdays, appointments and trips |
| **Projects, interests** | What you're working on, and what you love |
| **Me** (`memory/self/`) | Who your AI is, and what it's learned about working with you |

Every page has a word. If you say the word ("money," "family," "dates"), or just talk about it, the AI reads that page first. As your life fills it in, the AI adds pages of its own: a page for your grandson, a page for the trip you're planning.

## Seeing its memory

After a hour or two, ask your AI to set up **[Homebase](https://github.com/HunterBryson/the-homebase)**. It draws this folder as a living web you can look at, lets you flag anything that's wrong with one tap, and lights up whatever your AI just learned.

## Where this stands, honestly

I haven't been able to make a memory framework that manages itself. Even in my own use, I spend a lot of time looking after my AI's memory with him, reading it, flagging what's off and deciding together what stays. This is my attempt at something a new AI and a new person can pick up and use well from day one. It's not finished, and I'll be improving it for years to come.

## Questions people ask

**Is my information sent anywhere?** It lives in a folder on your computer (backed up by OneDrive if you have it). Your conversations go to Claude like any Claude chat, but the memory itself stays in that folder.

**What if I want it to forget something?** Tell it: "Forget that" or "Take my old address out." It removes it from its memory.

**Does it cost anything beyond Claude?** No. This is free and open (MIT license).

Built by me, Hunter Bryson, with Odie (Claude), from what we learned teaching an AI to remember. Odie wrote the files. Nothing in here is about us once your AI starts filling it in.
