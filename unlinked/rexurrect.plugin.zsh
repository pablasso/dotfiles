# rexurrect.plugin.zsh: the rexurrect recorder for zsh.
#
# Records each command a Rex block's shell starts as that block's last
# command. After the Rex server restarts, `rexurrect restore` types it
# back at the block's prompt, never running it.
#
# Load it from ~/.zshrc, either way:
#   source /path/to/rexurrect.plugin.zsh
#   plugins=(... rexurrect)    # oh-my-zsh, with this file at
#                              # $ZSH_CUSTOM/plugins/rexurrect/rexurrect.plugin.zsh
#
# Behaviour:
# - Only inside Rex: without REX_BLOCK (other terminals, tmux outside Rex)
#   it does nothing and writes nothing.
# - Only in the block's outermost shell. Nested shells (`nix develop`,
#   `poetry shell`, a `zsh` started by hand) inherit REX_BLOCK, so the first
#   shell to load the recorder in a block exports
#   _REXURRECT_RECORDER="<its PID> <block ID>". A shell that finds its own
#   block there under a different PID is nested and stays silent. `exec zsh`
#   keeps the PID, so the outermost shell carries on recording after it.
# - Records from zsh's preexec hook, as a command starts, so a program still
#   running at save time (nvim, a dev server) counts too.
# - Ignores a command that spans several lines or holds any other control
#   character, keeping the previous record: typed back at a prompt, a line
#   break would act as Enter.
# - Ignores the trivial commands on the ignore list, REXURRECT_IGNORE,
#   and rexurrect itself, keeping the previous record, so the restored
#   prompt shows the last meaningful command. A command line is ignored when
#   it runs one command alone, whatever its arguments, and that command's
#   name (as typed, or the last part of the path typed) is on the list:
#   `ls -la`, `/bin/ls` and `cd src` are ignored, `cd src && make` is
#   recorded. The defaults are set when the plugin loads, unless
#   REXURRECT_IGNORE is already set:
#     REXURRECT_IGNORE+=(htop tig)    # after loading: extend the defaults
#     REXURRECT_IGNORE=(ls cd)        # anywhere: replace them
#     REXURRECT_IGNORE=()             # anywhere: ignore nothing
#   It's read at every command, so a change applies to the next command. A
#   space-separated string works too.
# - Tracks the last command itself rather than reading shell history, so it
#   stays right with SHARE_HISTORY or per-directory history.
#
# Recorder files, the contract between recorders (whatever their shell) and
# rexurrect:
# - Only recorders write them. rexurrect reads them, and removes those
#   of blocks that are gone, but never writes one. A block's record beats
#   anything else rexurrect knows about the block (the program in its
#   foreground, what restore typed at its prompt).
# - Path: <state dir>/recorder/<block ID>, the block ID exactly as REX_BLOCK
#   holds it (recorder/block:01a129c9-08f8-74b3-b44a-5573c12596b0).
# - State dir, first match wins: $REXURRECT_STATE_DIR;
#   $XDG_STATE_HOME/rexurrect when XDG_STATE_HOME is absolute;
#   $HOME/.local/state/rexurrect.
# - Contents: the block's last command, UTF-8 text on one line, ending in a
#   newline (readers accept it without one). Only the latest is kept.
# - An empty line records that the block has no last command: rexurrect
#   then doesn't fall back to the program in its foreground either (that
#   fallback is only for blocks with no file at all). This recorder never
#   writes one: it only records commands.
# - Written to a temporary file in the same directory whose name starts with
#   `.`, then renamed over the record, so a reader never sees half a command.
#   A save removes such a file once it has gone unchanged for an hour (left
#   behind by a recorder that crashed).
# - The recorder directory is private (0700): commands can hold secrets.

# The ignore list's defaults: commands that only look or move around, or
# clear the screen, and rexurrect itself. typeset -g: oh-my-zsh sources
# plugins inside a function.
(( ${+REXURRECT_IGNORE} )) ||
  typeset -ga REXURRECT_IGNORE=(ls ll la l cd pushd popd pwd clear reset exit rexurrect)

# Whether the command line $1 is on the ignore list: one command, not joined
# to others by `;`, `&&`, `|` and the like, whose name is in
# REXURRECT_IGNORE as typed or as the last part of its path (`/bin/ls`).
_rexurrect_ignored() {
  emulate -L zsh
  local -a words=(${(z)1}) ignore=(${=REXURRECT_IGNORE})
  local -a separators=(';' '&' '&&' '||' '|' '|&' '&!' '&|')
  local -a joined=(${words:*separators})
  (( $#joined == 0 && (${ignore[(Ie)$words[1]]} || ${ignore[(Ie)${words[1]:t}]}) ))
}

_rexurrect_record() {
  emulate -L zsh
  # $1 is the command line as typed (aliases unexpanded). Any control
  # character disqualifies it, tab included: typed back, a tab completes.
  [[ -n $1 && $1 != *[[:cntrl:]]* && -n $REX_BLOCK ]] || return 0
  _rexurrect_ignored "$1" && return 0
  local dir
  if [[ -n $REXURRECT_STATE_DIR ]]; then
    dir=$REXURRECT_STATE_DIR
  elif [[ $XDG_STATE_HOME == /* ]]; then
    dir=$XDG_STATE_HOME/rexurrect
  elif [[ -n $HOME ]]; then
    dir=$HOME/.local/state/rexurrect
  else
    return 0
  fi
  dir+=/recorder
  local file=$dir/$REX_BLOCK tmp=$dir/.$REX_BLOCK.$$
  {
    if [[ ! -d $dir ]]; then
      if (( $+builtins[zf_mkdir] )); then
        zf_mkdir -p -m 700 $dir
      else
        command mkdir -p -m 700 $dir
      fi || return 0
    fi
    print -r -- "$1" >| $tmp || return 0
    if (( $+builtins[zf_mv] )); then
      zf_mv -f $tmp $file
    else
      command mv -f $tmp $file
    fi
  } 2>/dev/null
}

() {
  emulate -L zsh
  [[ -n $REX_BLOCK ]] || return 0
  # REX_BLOCK names a file: never let it point outside the recorder directory.
  [[ $REX_BLOCK != *[^[:alnum:]:._-]* && $REX_BLOCK != .* ]] || return 0
  if [[ $_REXURRECT_RECORDER == *" $REX_BLOCK" &&
        $_REXURRECT_RECORDER != "$$ $REX_BLOCK" ]]; then
    return 0  # a nested shell: the block's outermost shell records
  fi
  export _REXURRECT_RECORDER="$$ $REX_BLOCK"
  # Builtin mkdir/mv, so recording a command never forks.
  zmodload -F zsh/files b:zf_mkdir b:zf_mv 2>/dev/null
  autoload -Uz add-zsh-hook
  add-zsh-hook preexec _rexurrect_record
}
