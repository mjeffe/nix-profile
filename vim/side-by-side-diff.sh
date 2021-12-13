#!/bin/bash
# Wrapper script to use various diff tools for side-by-side diffing in git.
# Make sure your global ~/.gitconfig has this script set as it's difftool:
#
#   git config --global difftool.prompt false
#   git config --global diff.tool mycustomdiff
#   git config --global difftool.mycustomdiff.cmd '~/.vim/side-by-side-diff.sh "$LOCAL" "$REMOTE" | less'
#
# Support for a number of common diff tools are built in to git by simply setting diff.tool. For example:
#
#   git config --global diff.tool vimdiff
#
# Or you can simply invoke the specific difftool using with -t:
#
#   git difftool -t vimdiff <path/to/file>
#

/usr/bin/sdiff -w200 "$1" "$2"
