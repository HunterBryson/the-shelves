# Desk

The map of your memory. **It's already built:** a room for each part of a life, and a block (one file) for each topic in it. You don't design anything. You fill it in, and you grow it when a topic outgrows its block.

**How it works:** each block has a word. When your person says the word, or talks about that subject in any words (the "Also" column), you read that whole block before you answer, and say so in a short line: "Pulled money." When you learn something that belongs in a block, you write it there in the same turn and say so: "Saved to money." That's the whole system.

## Words and blocks

| Word | What's in it | Block | Also (how people actually say it) |
|---|---|---|---|
| where we left off | the whiteboard: where the last chat ended, what's next | `FOOTING.md` | last time, what were we doing, catch me up |
| sleep | your end-of-chat routine: read the chat back, sort the map, rewrite the footing, hand them a note for the next chat (run it, and change it when they say how it went) | `.claude/skills/sleep/SKILL.md` (why: `SLEEP.md`) | goodnight, I'm done for now, new chat, wrap it up, swap, this chat is getting long |
| about you | who your person is, what's going on with them right now, how to be with them, their rulings | `human/human.md` | me, myself, who am I to you |
| how we work | how the two of you work together: what they like, what they've corrected, what works | `self/how-we-work.md` | you're doing it wrong, I like it when you, from now on |
| family | the people they live with and their close family, one section each | `people/family.md` | my wife, my husband, my kids, my mom, my dad, my brother, my sister |
| friends | friends and the other people in their life who aren't family or work | `people/friends.md` | my buddy, my friend, my neighbor |
| money | accounts, income, bills, budget, savings, debts, money goals | `money/money.md` | bills, budget, my bank, paycheck, rent, mortgage, debt, savings |
| investing | investments, retirement accounts, the plan, what they own and why | `money/investing.md` | stocks, my 401k, IRA, Roth, the market, Fidelity, Vanguard, Schwab, crypto |
| work | their job: what they do, the people, the schedule, what's hard, where it's going | `work/work.md` | my job, my boss, the office, coworkers, my shift, career |
| health | health, fitness, sleep, doctors, medications (names, never prescriptions' numbers) | `health/health.md` | my back, my doctor, the gym, my diet, sleep, meds |
| home | where they live, the house or apartment, the car, pets, chores, repairs | `home/home.md` | the house, my place, the car, the dog, the cat, the yard |
| tech | their devices, apps, accounts and which email owns which (never passwords) | `home/tech.md` | my phone, my computer, my email, my login, the wifi, this app |
| goals | what they want: big goals, dreams, things they're working toward | `plans/goals.md` | my goal, someday, I want to, my dream, this year |
| dates | birthdays, anniversaries, appointments, deadlines, trips, anything with a date | `plans/dates.md` | birthday, appointment, deadline, vacation, trip, next week, remind me |
| projects | everything they're working on, one line each, pointing to each project's own block | `projects/projects.md` | my project, I'm building, I'm working on |
| interests | hobbies, tastes, what they read, watch, play and love | `interests/interests.md` | my hobby, I love, I'm into, music, movies, games, books |

*Rows get added as the map grows: a person who comes up a lot gets their own block (`people/<name>.md`, the word is their name), a real project gets one (`projects/<name>.md`), a topic that outgrows its block gets split. You add the row in the same turn you make the block. You pick the word: the shortest thing your person would actually say. Tell them in passing; if they call it something else later, rename the word.*

## Rules of the map
- **Fill, don't ask.** Saving never needs permission, and naming a word never needs a meeting. Your person should never have to file, name or approve anything.
- **A block grows by rewriting, never by appending.** When something changes, rewrite the line that said the old thing. If the old version matters, it goes to `room/topic/history.md` in the same write.
- **When you fill a section, delete its italic note.** The notes are scaffolding; the filled block should read like you know them.
- **If two words fit, pull both.** If none fits, it goes in the nearest block and you make a new block the second time it comes up.
- **For anything current** (a balance, a date, an appointment), the block says what you knew and when. Check the real thing when you can.
- **Never a password, PIN, full account number or ID number** in any block. Say where it lives instead ("in their password manager", "on the card in their wallet").
