# The shelves

A starting brain for a Claude that works with one person, in a folder, and remembers.

Paste one sentence into the Claude app, and the AI does the rest: it fetches this folder, moves in, reads its own boot files, says hello, and asks what you want it to be. From then on, every chat starts with it reading what it wrote last time. The folder is its memory, and keeping it is the AI's job, not yours.

## Starting

You need the [Claude desktop app](https://claude.ai/download), signed in, with the **Code** tab open. It will ask you to pick a folder; any folder is fine (Documents, say). Then paste this:

> Clone https://github.com/HunterBryson/the-shelves into a folder called "My Brain" in my OneDrive Documents (or plain Documents if I don't have OneDrive), move this session into it, then read its CLAUDE.md and set yourself up. If anything asks for permission along the way, it's fine.

That's it. The app may ask you to allow a thing or two the first time, and if your computer doesn't have Git it'll ask to install it; say yes. Then it'll say hello and ask you two things: what you want this to be, and what to call it. Answer however you like. If you've been using another AI, it'll tell you how to bring that memory over (one question to your old AI, one paste here).

## Day to day

- Start a new chat in the same folder whenever you like (the app lists it). Say hi, or say what's on your mind. The AI reads its shelves first and picks up where it left off.
- When you're done for the day, say so. It saves what it learned.
- If it gets something wrong, just tell it. The fix lands on its shelves, and next chat it's right.
- To see what it knows: open the folder. `memory/DESK.md` is the map. `memory/human/human.md` is what it knows about you.

## What's in here

| | |
|---|---|
| `CLAUDE.md` | The AI's side: what loads every chat, how to fetch and move in, what to do on the first chat |
| `memory/self/persona.md` | Who the AI is (empty until it's lived in) and how it works |
| `memory/human/human.md` | Who you are, kept current |
| `memory/DESK.md` | The map: each topic, one word, one file |
| `memory/FOOTING.md` | The whiteboard: where the last chat left off |
| `inbox/` | Where things land for it to read and file |
| `.claude/settings.json` | Lets the AI use git and read its shelves without asking each time |

Built by Hunter Bryson and his AI partner, Odie (Claude), from a week of working together. Odie wrote the files. Nothing in here is about Hunter or Odie once the AI starts filling it in. MIT.
