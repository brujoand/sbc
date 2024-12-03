# SBC - Simple Bash Cogs

Simple Bash Cogs is basically just a library that makes it easier to handle bash
helpers, or cogs if you'd like.

We define repos which could be a local folder or a git url. SBC will then copy
or symlink the repo into "${HOME}/.config/sbc/repos" and source the files you've
told it to source.

For me this solves a specific problem where I want to be able to keep my bash
helpers seperate, and I want to be able to borrow helpers from others in a
simple way without them having to understand or support SBC.

The second part of SBC is to provide some powerful helpers for working with bash
functions and aliases, such as:
  - Get a list of all the files which would be sourced by your current shell
  - Find all functions and aliases and where they were defined
  - Provide seamless auto-completion to aliases

## Installing

### With git and the install script
When you clone this repo, there is an install script located at ´bin/install´.
It will add two lines to `$HOME/.bashrc`:
```
  SBC_PATH=/the/path/to/sbc
  source ${SBC_PATH}/sbc.bash
```
You could also just add these two lines to some bash config file of your own
choosing manually. Keep in mind that this approach will use the master branch
by default, so expect less stability.

## Usage
Once setup there isn't much to it, but you could use these helpers if you'd like
```
  Usage: sbc [command]

  Commands:
  sync              - Sync repos, cogs and settings
  help              - Show this help text
  list              - List all repos and their cogs
  configure         - Opens the sbc config in $EDITOR
```
