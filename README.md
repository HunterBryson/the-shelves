# The shelves

A starting brain for a Claude that works with one person, in a folder, and remembers.

Open this folder in the Claude desktop app's **Code** tab, and the AI sets itself up: it reads its own boot files, checks git, reads whatever you dropped in `inbox/`, and says hello. From then on, every chat starts with it reading what it wrote last time. The folder is its memory, and keeping it is the AI's job, not yours.

This is the shape Hunter Bryson and his AI partner, Odie, built over a week of working together, boiled down to a starting point. Odie wrote the files. Nothing in here is about Hunter or Odie once the AI starts filling it in.

## Starting, in five steps

1. **Get the folder onto your computer.** On GitHub, use **Code → Download ZIP** and unzip it somewhere you'll keep (your Documents folder is fine), or clone it if you use git. Rename the folder if you like.
2. **Open the Claude desktop app, go to the Code tab, and open that folder.**
3. **(Optional, but worth it) Put your old AI's memory in `inbox/`.** `inbox/README.md` has the steps for Grok. Two minutes.
4. **Type:** `Read CLAUDE.md and set yourself up.`
5. **Talk.** It'll say hello and ask what you want this to be. Answer however you like. That's your first chat.

## Day to day

- Start a new chat whenever you like. Say hi, or say what's on your mind. The AI reads its shelves first and picks up where it left off.
- When you're done for the day, say so. It saves what it learned and commits.
- To see what it knows: open `memory/`. `DESK.md` is the map. `human/human.md` is what it knows about you.
- If it gets something wrong, just tell it. The fix lands on its shelves, and next chat it's right.

## What's in here

| | |
|---|---|
| `CLAUDE.md` | The AI's side: what loads every chat, and what to do on the first one |
| `memory/self/persona.md` | Who the AI is (empty until it's lived in) and how it works |
| `memory/human/human.md` | Who you are, kept current |
| `memory/DESK.md` | The map: each topic, one word, one file |
| `memory/FOOTING.md` | The whiteboard: where the last chat left off |
| `inbox/` | Where you drop things for it to read and file |
| `.claude/settings.json` | Lets the AI use git and read its shelves without asking each time |

MIT. Use it however you like.
