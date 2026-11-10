#!/usr/bin/env bats
# Checks your toolkit (toolkit/bash_aliases) and your answers in answers.txt.
# Each job is tried for real: the check loads your toolkit into a fresh bash that reads no
# startup files, in a throwaway folder, and runs your shortcuts there. Nothing outside that
# folder is touched, and your own ~/.bashrc is never read or changed.
# Run it from this folder with:  bats check.bats
# You don't need to change this file.

setup() {
  cd "$BATS_TEST_DIRNAME"
  toolkit="$BATS_TEST_DIRNAME/toolkit/bash_aliases"
  dir="$BATS_TEST_TMPDIR/practice"
  mkdir -p "$dir"
}

# Runs the lines given in a fresh bash that has loaded your toolkit and nothing else.
# Each line is read after the one before has run, so aliases work as they do at a prompt.
with_toolkit() {
  bash --norc --noprofile -O expand_aliases -c "source '$toolkit'
$1"
}

# What kind of name your toolkit made: alias, function, or nothing.
kind_of() {
  with_toolkit "type -t $1" 2>/dev/null
}

# The answer written after "N)" in answers.txt, without spaces or quotes at either end,
# and with each run of spaces made one.
answer() {
  grep -E "^$1\)" answers.txt | head -n 1 | sed -E "s/^$1\)[[:space:]]*//; s/[[:space:]]+\$//; s/^[\"'\`]//; s/[\"'\`]\$//; s/[[:space:]]+/ /g"
}

# Fails with a message when question N has no answer yet.
need() {
  if [[ -z "$(answer "$1")" ]]; then
    echo "Question $1 has no answer yet. Write it after \"$1)\" in answers.txt."
    return 1
  fi
}

@test "the toolkit file is here" {
  if [[ ! -f "$toolkit" ]]; then
    echo "toolkit/bash_aliases is missing. Download the exercise again to get it back, or make it with nano."
    return 1
  fi
}

@test "the toolkit loads without errors" {
  errors="$(bash --norc --noprofile -c "source '$toolkit'" 2>&1 >/dev/null || true)"
  if [[ -n "$errors" ]]; then
    echo "Loading toolkit/bash_aliases printed an error. Its first line:"
    echo "$errors" | head -n 1
    echo "Look at the line number it names. Common causes: a space around = in an alias, a missing quote, or a missing } at the end of a function."
    return 1
  fi
}

@test "1) ll lists everything, with sizes people can read" {
  if [[ -z "$(kind_of ll)" ]]; then
    echo "There's no ll in your toolkit yet. Make it an alias for ls with three options: a long list, all the files, and human-readable sizes."
    return 1
  fi
  head -c 2048 /dev/zero > "$dir/photo.jpg"
  touch "$dir/.hidden-notes.txt"
  out="$(with_toolkit "cd '$dir'
ll" 2>&1)"
  if ! grep -q -- '-rw' <<< "$out"; then
    echo "ll should print one line per file, with its details. That's ls's long-list option, -l."
    return 1
  fi
  if ! grep -q '\.hidden-notes\.txt' <<< "$out"; then
    echo "ll didn't show the hidden file .hidden-notes.txt. Hidden files need ls's -a."
    return 1
  fi
  if ! grep -q '2\.0K' <<< "$out"; then
    echo "ll showed a 2048-byte file without 2.0K. Sizes people can read need ls's -h."
    return 1
  fi
}

@test "2) .. goes up one folder" {
  if [[ -z "$(kind_of ..)" ]]; then
    echo "There's no .. in your toolkit yet. Make it an alias for cd and the folder above it."
    return 1
  fi
  mkdir -p "$dir/trip/day-1"
  where="$(with_toolkit "cd '$dir/trip/day-1'
..
pwd" 2>/dev/null)"
  if [[ "$where" != "$dir/trip" ]]; then
    echo "From trip/day-1, .. should land in trip, but it landed in: $where"
    return 1
  fi
}

@test "3) rm asks before deleting" {
  if [[ "$(kind_of rm)" != "alias" && "$(kind_of rm)" != "function" ]]; then
    echo "rm in your toolkit is still the plain rm, which deletes without asking. Make rm an alias for rm with the option that asks about each file."
    return 1
  fi
  touch "$dir/keep-me.txt"
  with_toolkit "cd '$dir'
echo n | rm keep-me.txt" >/dev/null 2>&1 || true
  if [[ ! -f "$dir/keep-me.txt" ]]; then
    echo "rm deleted keep-me.txt without asking, even though the answer was n. Use rm -i, which asks about every file (-I asks only about big jobs)."
    return 1
  fi
}

@test "4) mkcd makes a folder and goes into it" {
  if [[ "$(kind_of mkcd)" != "function" ]]; then
    echo "There's no mkcd function in your toolkit yet. It needs two lines between { and }: mkdir -p, then cd, each with \"\$1\"."
    return 1
  fi
  where="$(with_toolkit "cd '$dir'
mkcd 'trip photos/day 1'
pwd" 2>/dev/null)"
  if [[ ! -d "$dir/trip photos/day 1" ]]; then
    echo "mkcd 'trip photos/day 1' didn't make that folder. Use mkdir -p, which makes the folders on the way too, and put \$1 in double quotes, \"\$1\", so spaces stay part of the name."
    return 1
  fi
  if [[ "$where" != "$dir/trip photos/day 1" ]]; then
    echo "mkcd made the folder but didn't go into it (it ended in: $where). Add cd \"\$1\" after the mkdir line, with the quotes."
    return 1
  fi
}

@test "5) bak keeps a copy with .bak on the end" {
  if [[ "$(kind_of bak)" != "function" ]]; then
    echo "There's no bak function in your toolkit yet. One line between { and } is enough: cp, the file, then the same name with .bak on the end."
    return 1
  fi
  printf 'sunscreen\nhiking boots\n' > "$dir/packing list.txt"
  with_toolkit "cd '$dir'
bak 'packing list.txt'" >/dev/null 2>&1 || true
  if [[ ! -f "$dir/packing list.txt.bak" ]]; then
    echo "bak 'packing list.txt' should make 'packing list.txt.bak'. Copy \"\$1\" to \"\$1.bak\", with the quotes, so a name with spaces works."
    return 1
  fi
  if [[ "$(cat "$dir/packing list.txt.bak")" != "$(printf 'sunscreen\nhiking boots')" || ! -f "$dir/packing list.txt" ]]; then
    echo "The .bak file should be an exact copy, and the original should stay. Use cp, not mv."
    return 1
  fi
}

@test "6) the prompt shows the folder, in color" {
  ps1="$(bash --norc --noprofile -c "source '$toolkit'; printf '%s' \"\$PS1\"" 2>/dev/null)"
  if [[ -z "$ps1" ]]; then
    echo "Your toolkit doesn't set PS1 yet. Add a line such as PS1='...', in single quotes."
    return 1
  fi
  if [[ "$ps1" != *'\w'* && "$ps1" != *'\W'* ]]; then
    echo "Your prompt doesn't show the folder you're in. Add \\w (the whole path) or \\W (the folder's name)."
    return 1
  fi
  if [[ "$ps1" != *'\$ ' && "$ps1" != *'\$' ]]; then
    echo "Your prompt should end with \\\$ and a space, so it shows \$ when it's ready."
    return 1
  fi
  colors="$(grep -oE '\\(e|E|033)\[[0-9;]*m' <<< "$ps1" | wc -l | tr -d ' ')"
  wrapped="$(grep -oE '\\\[\\(e|E|033)\[[0-9;]*m\\\]' <<< "$ps1" | wc -l | tr -d ' ')"
  if [[ "$colors" -eq 0 ]]; then
    echo "Your prompt has no color yet. A color code looks like \\e[1;36m (bold cyan)."
    return 1
  fi
  if [[ "$colors" -ne "$wrapped" ]]; then
    echo "Every color code needs \\[ before it and \\] after it, like \\[\\e[1;36m\\], so bash knows it takes up no room."
    return 1
  fi
  if ! grep -qE '\\(e|E|033)\[0*m' <<< "$ps1"; then
    echo "Set the color back to normal after the colored part, with \\[\\e[0m\\], or what you type comes out in color too."
    return 1
  fi
}

@test "answer 1) the file bash reads when a terminal opens" {
  need 1
  if ! [[ "$(answer 1)" =~ ^(~/|\$HOME/|/home/[^/]+/)?\.bashrc$ ]]; then
    echo "Question 1: \"$(answer 1)\" isn't it yet. It's the hidden file in your home folder that bash reads before its first prompt (Startup Files: .bashrc, .zshrc and source)."
    return 1
  fi
}

@test "answer 2) the command that loads the toolkit into this shell" {
  need 2
  if ! [[ "$(answer 2)" =~ ^(source|\.)\ (\./)?toolkit/bash_aliases$ ]]; then
    echo "Question 2: \"$(answer 2)\" isn't it yet. Running the file with bash loads it into a separate shell that forgets it. Which command reads a file in the shell you're in?"
    return 1
  fi
}

@test "answer 3) checking whether jq is installed" {
  need 3
  if ! [[ "$(answer 3)" =~ ^(apt-cache|apt)\ policy\ jq$ ]]; then
    echo "Question 3: \"$(answer 3)\" isn't it yet. It's the apt-cache command that shows the Installed and Candidate lines, with jq after it."
    return 1
  fi
}

@test "answer 4) one command that installs all four tools" {
  need 4
  read -r -a words <<< "$(answer 4)"
  if [[ "${words[0]}" == brew ]]; then
    start="${words[*]:0:2}"
    rest=("${words[@]:2}")
  else
    start="${words[*]:0:3}"
    rest=("${words[@]:3}")
  fi
  case "$start" in
    "sudo apt install" | "sudo apt-get install" | "brew install") ;;
    *)
      echo "Question 4: \"$(answer 4)\" doesn't start the way an install does: sudo apt install on Ubuntu, or brew install on a Mac (with no sudo)."
      return 1
      ;;
  esac
  packages="$(printf '%s\n' "${rest[@]}" | grep -v '^-' | sort | tr '\n' ' ')"
  if [[ " $packages" == *" tldr "* ]]; then
    echo "Question 4: tldr's package has a name of its own. Installing Tools: Homebrew and apt gives it."
    return 1
  fi
  if [[ "$packages" != "htop jq tealdeer tree " ]]; then
    echo "Question 4: the command should name four packages once each: tree, htop, jq and tldr's package (it named: $packages)."
    return 1
  fi
}
