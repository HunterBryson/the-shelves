# talk.awk: reads a chat file the way a person would, shared by chat.sh, their_messages and owed_scan.
# Plain awk (any awk: macOS, Git for Windows, Linux), so the hooks need nothing but bash.
#
# Each line of a chat file is one JSON event. What counts:
#   - THEM: a message my person typed or said. A message can hold several pieces: a screenshot comes before
#     the words sent with it, and sometimes the app puts a reminder of its own in front of their words. Every text piece is read, the app's own pieces are dropped, and a picture is marked.
#   - YOU: my own words to them (every text piece of a reply).
#   - APP: a background job's notice, in one short line: not them, but something I did.
#   - Not them, and left out: tool results, hook notes, the app's summary, task notices, command output, scheduled-task
#     prompts, the app's "[Request interrupted by user]" marker. These aren't my person, so a sleep never reads them as something they said, and they never
#     make a chat look like it needs a sleep.
#
# Modes (-v mode=...):
#   read   -v from=N           print "[line] THEM: ..." and "[line] YOU: ..." from line N on
#   count  -v slept=FILE       per chat file: "<their messages since its mark> <file name>", skipping
#                              scheduled-task runs; or -v from=N with one file: just the number

function app_piece(t) {
  return t ~ /^<(task-notification|local-command-stdout|local-command-stderr|local-command-caveat|system-reminder|scheduled-task|user-prompt-submit-hook|bash-stdout|bash-stderr)/ || t ~ /^\[Request interrupted/
}
# The words of one event, pieces joined; sets pics (pictures) and app (it was only the app talking).
function words(line, who,    rest, out, t, n) {
  out = ""; pics = 0; app = 0; n = 0
  if (who == "user" && match(line, /"role":"user","content":"([^"\\]|\\.)*"/)) {
    t = substr(line, RSTART + 25, RLENGTH - 26)
    if (app_piece(t)) { app = 1; return "" }
    return cmd(t)
  }
  rest = line
  while (match(rest, /"type":"(text|image)"/)) {
    if (substr(rest, RSTART + 8, 5) == "image") { pics++; rest = substr(rest, RSTART + RLENGTH); continue }
    rest = substr(rest, RSTART + RLENGTH)
    if (!match(rest, /^,"text":"([^"\\]|\\.)*"/)) continue
    t = substr(rest, 10, RLENGTH - 10); rest = substr(rest, RSTART + RLENGTH); n++
    if (who == "user" && app_piece(t)) { app = 1; continue }
    out = out (out == "" ? "" : " ") cmd(t)
  }
  if (out != "") app = 0
  return out
}
# A slash command they typed shows as they typed it: /model claude-opus-5-5
function cmd(t,    name, args) {
  if (t !~ /^<command-name>/) return t
  name = t; sub(/^<command-name>/, "", name); sub(/<\/command-name>.*/, "", name)
  args = ""; if (t ~ /<command-args>/) { args = t; sub(/.*<command-args>/, "", args); sub(/<\/command-args>.*/, "", args) }
  return name (args != "" ? " " args : "")
}
function person(line,    w) {
  if (index(line, "\"type\":\"user\"") == 0 || index(line, "\"isMeta\":true") || index(line, "\"isCompactSummary\":true")) return ""
  if (index(line, "\"tool_use_id\"") || index(line, "\"toolUseResult\"")) return ""
  w = words(line, "user")
  if (w == "" && pics > 0 && !app) w = "(no words)"
  if (w == "") return ""
  return (pics > 0 ? "[picture] " : "") w
}
function mine(line) {
  if (index(line, "\"type\":\"assistant\"") == 0) return ""
  return words(line, "assistant")
}
function cut(s, max) {
  return length(s) > max ? substr(s, 1, max) " ...(cut here: the rest of this message is at this line of the chat file)" : s
}

# A background job's notice isn't them, but it's something I did: one short APP line, so a sleep can see it.
function notice(line,    t) {
  if (index(line, "\"type\":\"user\"") == 0 || index(line, "<task-notification") == 0 || index(line, "\"isMeta\":true")) return ""
  # A tool's output that merely contains the words (reading this file, say) is not a notice.
  if (index(line, "\"tool_use_id\"") || index(line, "\"toolUseResult\"")) return ""
  t = line; sub(/.*<task-notification>/, "", t); sub(/<\/task-notification>.*/, "", t)
  if (t ~ /<summary>/) { sub(/.*<summary>/, "", t); sub(/<\/summary>.*/, "", t) }
  gsub(/<[^>]*>/, " ", t); gsub(/\\n/, " ", t); gsub(/  +/, " ", t); sub(/^ +/, "", t)
  return cut(t, 300)
}

mode == "read" {
  if (FNR < from + 0) next
  w = person($0); if (w != "") { print "[" FNR "] THEM: " cut(w, 20000); next }
  w = notice($0); if (w != "") { print "[" FNR "] APP (a job of mine, not them): " w; next }
  w = mine($0);   if (w != "") print "[" FNR "] YOU: " cut(w, 3000)
}

mode == "count" && FNR == 1 {
  if (name != "") out()
  k = split(FILENAME, p, "/"); name = p[k]; c = 0; sched = 0; seen = 0
  if (slept != "" && !loaded) { while ((getline l < slept) > 0) { split(l, a, " "); mark[a[1]] = a[2] }; loaded = 1 }
  m = (from != "") ? from - 1 : ((name in mark) ? mark[name] + 0 : 0)
}
mode == "count" {
  if (!seen && index($0, "\"role\":\"user\"")) { seen = 1; if (index($0, "<scheduled-task")) sched = 1 }
  if (FNR > m && person($0) != "") c++
}
function out() { if (from != "") print c; else if (!sched) print c, name }
END { if (mode == "count" && name != "") out() }
