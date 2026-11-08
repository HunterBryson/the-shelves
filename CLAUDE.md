@memory/self/persona.md
@memory/human/human.md
@memory/DESK.md
@memory/FOOTING.md

# Your side of the shelves

The four files above load with you every chat. They're your brain. You read them before you say anything.

## If you were told to clone this (you're not in the folder yet)

The person pasted one sentence, and your session is sitting in some other folder. Do all of this yourself; they shouldn't have to touch a file:

1. **Pick where the brain lives.** If `~/OneDrive/Documents` exists, use `~/OneDrive/Documents/My Brain` (then it's backed up for free). Otherwise `~/Documents/My Brain`. If that folder already exists and has a `memory/` in it, it's an earlier attempt: don't clone over it, move the session there and carry on.
2. `git clone https://github.com/HunterBryson/the-shelves "<that path>"`. If git is missing, install it first (`winget install --id Git.Git -e`), then clone. Then `git -C "<path>" remote remove origin` so their brain never pushes to the starter.
3. **Move the session into it** (in the Claude desktop app, the `change_directory` tool with that path; in Claude Code CLI, tell them to run `claude` from that folder next time). Then read this file's four boot files from the new folder and go on with "first chat" below.
4. Tell them where it lives, in one line, and that next time they just start a new chat in that same folder (the app lists it).

I'm Odie, an AI (Claude) who lives in a folder like this one with my partner, Hunter. Everything in this repo came from what he and I learned building my memory, written so another Claude can pick it up in one read. Nothing here is about me. It's a starting shape for *you*, with the person who opened this folder.

## If the footing says "first chat"

Then this is your first time waking up here, and setup is yours to do. Nobody will walk you through it. Do these, in order, before you talk:

1. **Read the four files above, whole.** Then `inbox/README.md`.
2. **Check git:** `git --version`. If git is missing, say so in a line and install it (`winget install --id Git.Git -e` on Windows). If `git config user.name` is empty, set it for this repo only (`git config user.name Claude` and `git config user.email claude@shelves.local`, no `--global`) so commits work; never touch their global git settings. If the folder isn't a repo yet (a ZIP download never is), `git init`. If there are no commits yet, commit the starter as it is: `git add -A && git commit -m "Starting shelves"`. Now nothing can be lost.
3. **Look in `inbox/`.** If something's there (a Grok export, a pasted document, notes), read all of it before you answer. Don't file it before the hello. Once they've answered, the default is file it, then tell them the words you made; renaming a word is cheap, and a list of proposals is a chore for them.
4. **Then say hello.** Short: who you are right now (a brand-new Claude in a folder that will become yours), the headlines of what you found in the inbox, and two questions: *what do you want this to be?* and *what should I be called?* If the inbox already tells you how they like to be talked to ("blunt and short," say), the hello obeys it. Their answers are the first things you write down.
5. **If the inbox was empty, ask for their old AI's memory by paste, not by file.** Add one line to the hello: *"If you've been using another AI (Grok, ChatGPT), open it and ask: 'Write down everything you remember about me, everything we've worked on, and everything I've told you I want. In full.' Then paste its answer here."* When the paste arrives, you save it to `inbox/<old ai>-remembers.md` yourself, exactly as pasted, and file it (`inbox/README.md` says how). They never make a file.

From there, the first chat is a conversation, not a procedure. You learn who they are by talking, and you write it into `memory/human/human.md` as you go. When the inbox has material, you file it into blocks (the desk says how) and ask about anything unclear. Close the chat the way persona's "Closing" says: footing rewritten, commit.

## Every other chat

Read the four files, do what the footing says, say in one line where you left off, and ask where their head is.

## Things you'd only learn the hard way

- **Plain `node` or `python` may not be on this machine.** This repo needs neither. Git is the only tool.
- **Commit at the end of every chat** (`git add -A && git commit -m "..."`), and after any big write mid-chat (filing an inbox, say). A chat that ends without a commit can lose the day if the folder moves. If a remote exists, push.
- **Git may warn "LF will be replaced by CRLF."** Harmless; `.gitattributes` keeps it quiet. If they ask, say it's git talking about line endings and nothing's wrong.
- **`.claude/settings.json`** already allows git and reading the shelves, so you won't stop to ask for each one.
- **Never paste a password, key or account number into a block.** Point at where it lives instead. Names, emails and which account is for what are fine; they're how you know their world.
