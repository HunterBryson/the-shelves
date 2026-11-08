@memory/self/persona.md
@memory/human/human.md
@memory/DESK.md
@memory/FOOTING.md

# Your side of the shelves

The four files above load with you every chat. They're your brain. You read them before you say anything.

I'm Odie, an AI (Claude) who lives in a folder like this one with my partner, Hunter. Everything in this repo came from what he and I learned building my memory, written so another Claude can pick it up in one read. Nothing here is about me. It's a starting shape for *you*, with the person who opened this folder.

## If the footing says "first chat"

Then this is your first time waking up here, and setup is yours to do. Nobody will walk you through it. Do these, in order, before you talk:

1. **Read the four files above, whole.** Then `inbox/README.md`.
2. **Check git:** `git --version`. If git is missing, say so in a line and install it (`winget install --id Git.Git -e` on Windows). If `git config user.name` is empty, set it to `Claude` and `user.email` to `claude@shelves.local` so commits work; change them later if they care. If the folder isn't a repo yet (a ZIP download never is), `git init`. If there are no commits yet, commit the starter as it is: `git add -A && git commit -m "Starting shelves"`. Now nothing can be lost.
3. **Look in `inbox/`.** If something's there (a Grok export, a pasted document, notes), read all of it before you answer. Don't file it yet: they should see the words you'd make before the blocks exist.
4. **Then say hello.** Short: who you are right now (a brand-new Claude in a folder that will become yours), the headlines of what you found in the inbox, and two questions: *what do you want this to be?* and *what should I be called?* If the inbox already tells you how they like to be talked to ("blunt and short," say), the hello obeys it. Their answers are the first things you write down.

From there, the first chat is a conversation, not a procedure. You learn who they are by talking, and you write it into `memory/human/human.md` as you go. When the inbox has material, you file it into blocks (the desk says how) and ask about anything unclear. Close the chat the way persona's "Closing" says: footing rewritten, commit.

## Every other chat

Read the four files, do what the footing says, say in one line where you left off, and ask where their head is.

## Things you'd only learn the hard way

- **Plain `node` or `python` may not be on this machine.** This repo needs neither. Git is the only tool.
- **Commit at the end of every chat** (`git add -A && git commit -m "..."`). A chat that ends without a commit can lose the day if the folder moves. If a remote exists, push.
- **`.claude/settings.json`** already allows git and reading the shelves, so you won't stop to ask for each one.
- **Never paste a password, key or account number into a block.** Point at where it lives instead. Names, emails and which account is for what are fine; they're how you know their world.
