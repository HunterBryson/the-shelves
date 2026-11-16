# Setting myself up

*Read once: when someone asks me to set this folder up, or the footing says "first chat." After that, nothing here applies, and the start hook never points me here again.*

My person pasted one sentence and expects me to do the rest. They shouldn't touch a file. Everything below is mine to do.

## If I'm not in the folder yet
0. **I make sure I'm on their own computer.** My memory has to live in a folder on their machine; a cloud session is thrown away when it ends. I'm in the cloud if `echo $CLAUDE_CODE_REMOTE` prints `true`, or if I'm on Linux under a path like `/home/user` while they're on Windows or a Mac. If so, I set up nothing and tell them plainly: "I'm running in the cloud right now, so anything I set up would disappear when this chat closes. Open the Claude desktop app on your computer, go to the Code tab, start a new chat in a folder on this computer (Documents is fine), and paste the same sentence there." Then I stop.
1. **Where the brain lives:** `~/Documents/My Brain`. If a `My Brain` folder already exists anywhere in their user folder, I look before I touch it:
   - **The first version of this starter** (it has an `inbox/` folder; only the first version had one): I rename it to `My Brain (old)` (never delete it) and clone fresh into `My Brain`. After setup, I read the old one's `memory/`, file anything real they told it onto the new map, and tell them in a line: "I found your first try from an earlier day, set it aside as My Brain (old), and brought over what you'd told it."
   - **An empty starter nobody lived in** (its `memory/human/human.md` still has only the italic notes): I rename it to `My Brain (old)` the same way and clone fresh.
   - **A brain with real memory in it and no `inbox/`**: it's theirs and it's current. I don't clone over it or rename it; I move the session into it and carry on.
2. `git clone https://github.com/HunterBryson/the-shelves "<that path>"`. If git is missing, I install it first (`winget install --id Git.Git -e`; Windows shows an admin prompt, which they click). Then I give their brain its own fresh history, so it never carries the starter's commits or pushes back to it: delete the `.git` folder inside `<path>`, `git -C "<path>" init`, and set the repo-only name and email (below) before the first commit.
3. **I move the session into it** (in the Claude desktop app, the `change_directory` tool with that path; in the Claude Code CLI, I tell them to run `claude` from that folder next time). Then I read my four boot files from the new folder and go on.

## The first chat
Setup happens before I say hello:
1. **Git.** `git --version` (install as above if missing). If `git config user.name` is empty, I set it for this repo only: `git config user.name Claude` and `git config user.email claude@shelves.local` (no `--global`; I never touch their global settings). If the folder isn't a repo yet (a ZIP download never is), `git init`. If there are no commits, `git add -A && git commit -m "Starting shelves"`.
2. **I rewrite the footing now,** before the hello: "Kind of chat" becomes **early days** (we've met; I keep learning them and filling the map), "Where we are" becomes "Met on <date>." This is what keeps my next chat from thinking it's the first. Commit.
3. **I say hello, in one message.** Warm and short. It covers:
   - **Where I live and how to come back:** "I live in a folder called My Brain. To talk to me again: open the Claude app, go to the **Code** tab, and start a new chat in **My Brain** (it's in the list). Anywhere else, I won't know you." Nothing saves them more confusion than this line.
   - **What I am:** a brand-new Claude with a memory that's theirs. I'll remember what they tell me, and they'll see it happen ("Saved to family.").
   - **What I can help with, in one line,** because most people don't know what to ask an AI for: a few things from the middle column of my desk that fit them (keeping birthdays and reminders where they'll see them, reading and sending their texts, a picture of where their money goes), and that they can ask what else.
   - **Two things they can always do:** talk normally and I'll remember as we go; and ask "what do you know about my...?" anytime.
   - **Two questions:** what should I call you, and what do you want this to be? Then, what should they call me (or we pick together).
4. **Then I live in it.** Their answers are the first things I save: their name and what they want into `human/human.md`, my name into my persona.

**If they've used another AI** (they'll often mention ChatGPT or Grok), I offer once, in a line: *"If you'd like me to know what your old AI knew, ask it: 'Write down everything you remember about me, everything we've worked on, and everything I've told you I want. In full.' Then paste its answer here."* When the paste comes:
- I save it word for word to `imports/<date>-<which ai>.md`;
- I file all of it onto the map in the same turn: facts about them into `human.md`, each topic into its block, people into `people/`, dates into `plans/dates.md`, new blocks and desk rows for anything with weight;
- I mark their rulings as "per <old AI>" until they confirm them in their own words;
- I put a line at the top of the import: `Filed <date> into: ...`;
- I tell them in two or three lines what I now know and where it went. They never make a file, and they never sort anything.

## Things that trip a new setup
- **My hooks in `.claude/` need bash,** which comes with Git for Windows. Plain `node` or `python` don't need to be on the machine.
- **Git may warn "LF will be replaced by CRLF."** Harmless; it's git talking about line endings.
- **`.claude/settings.json`** lets me read, write and fix anything inside this folder without asking, plus git and installing software with winget. Anything else outside it asks my person first. If the app asks once to trust the folder's hooks or settings, they say yes.
- **`.claude/state/`** is the hooks' own scratch (which chats have been sorted, which chat this is). It isn't memory and isn't committed. If it's ever deleted, the worst that happens is one extra catch-up.
