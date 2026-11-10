# Exercise: Your Toolkit, Version 1

Exercise code for the lesson **Exercise: Your Toolkit, Version 1** in Bash in Depth on [ask-codey.com](https://www.ask-codey.com).

Build the first version of your own toolkit: a file of aliases, two small functions and a prompt in your colors, the kind of file people carry from computer to computer. Answer four questions about startup files and installing tools, and a check script tries every shortcut for real and tells you what's done.

## Before you start

You need a terminal (the Terminal app on a Mac, Ubuntu on Linux or in WSL on Windows) and **bats**, the tool that runs the check. If `bats --version` doesn't print a version yet, install it:

```bash
sudo apt install bats       # Ubuntu, and Ubuntu in WSL
brew install bats-core      # a Mac, with Homebrew
```

## What's here

- `toolkit/bash_aliases`: your toolkit. It has an example done for you and six jobs, each a comment saying what to add. For you to finish.
- `answers.txt`: four questions, each with a numbered line for your answer. For you to finish.
- `check.bats`: the check. You don't need to change it.

## Run it

Open a terminal in this folder (the one with `answers.txt` in it), then open the toolkit:

```bash
nano toolkit/bash_aliases
```

Add a line or two under each job, save with Ctrl+O and Enter, and quit with Ctrl+X. Then load the toolkit into the shell you're in, and try your shortcuts:

```bash
source toolkit/bash_aliases
ll
```

The six jobs:

1. **`ll`**: a long list of a folder, hidden files included, with sizes such as `2.0K`.
2. **`..`**: go up one folder.
3. **`rm`**: ask before deleting each file.
4. **`mkcd`**: a function that makes a folder, and any folders on the way to it, then goes into it. `mkcd "trip photos/day 1"` must work, spaces and all.
5. **`bak`**: a function that copies a file to the same name with `.bak` on the end, so `bak notes.txt` makes `notes.txt.bak`.
6. **Your prompt**: a `PS1` with the folder you're in, at least one color, the color set back to normal, and `\$` at the end. Choose your own colors.

Then answer the four questions in `answers.txt`, and save it.

## Check your work

From this folder:

```bash
bats check.bats
```

At first most checks fail: that is expected. Each job you finish turns its check into a ✓. A failing check's message says what to look at. The check loads your toolkit into a fresh bash in a throwaway folder; it never reads or changes your own `~/.bashrc`.

## The rules

- Keep the toolkit in `toolkit/bash_aliases`, and don't change the example.
- `mkcd` and `bak` are functions; the others can be aliases.
- Write each answer on its numbered line, after the `)`, like the example: `0) alias`.

## Tips

- An alias is `alias name='command'`: no spaces around the `=`, and the command in single quotes.
- In a function, `"$1"` is the first word typed after its name. The double quotes keep a name with spaces in one piece.
- Each color code goes inside `\[` and `\]`, like `\[\e[1;36m\]`, and `\[\e[0m\]` sets the color back to normal.
- If loading the toolkit prints an error, the message names the line: look there first.
- On a Mac, your Terminal runs zsh. The aliases and functions work there too, but the `PS1` line is written for bash; the check runs it in bash.

## Make it yours

When every check passes, you can make the toolkit part of every terminal you open, as in the lesson *Your Dotfiles: A Setup You Can Carry*: copy it to `~/dotfiles/bash_aliases`, check with `ls -a ~` that there's no `~/.bash_aliases` yet, then link it into place from your home folder with `ln -s dotfiles/bash_aliases .bash_aliases`. On a Mac, add the lines you want to `~/.zshrc` instead.

## Hand it in

When it works, push your solution to a public repo of your own on GitHub, then paste that repo's address into **Submit your exercise** on the lesson page at [ask-codey.com](https://www.ask-codey.com). That's what completes the lesson. The lesson page shows the Git commands, step by step.
