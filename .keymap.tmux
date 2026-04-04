#!/bin/sh

shiftnum='!@#$%^&*()'

# Define variables used in keybindings (arrow keys for pane navigation)
left='Left'; down='Down'; up='Up'; right='Right'; o='o';
S_left='S-Left'; S_down='S-Down'; S_up='S-Up'; S_right='S-Right'; O='O';
s='s'; S='S'; v='v'; V='V'; t='t'; z='f';
d='d'; n='n'; p='p'; r='r';
C='C'; E='E'; w='w';
enter='enter'

bind='bind -n'
mod='M-'

bind_switch() {
	newwincmd="new-window -t :""$2"

	# Bind keys to switch to a workspace. The workspace is created if it
	# doesn't exist, and if we're already there we go back to the last one.
	#
	tmux $bind "$1" \
		if-shell '[ "$(tmux display -p "#I")" != "'"$2"'" ]' \
		"if-shell 'tmux select-window -t :$2' '' '$newwincmd'" \
		"last-window"
}

bind_move() {
	# Bind keys to move panes between workspaces.
	if [ -z "$legacy" ]; then
		tmux $bind "$1" \
			if-shell "tmux join-pane -t :$2" \
			"" \
			"new-window -dt :$2; join-pane -t :$2; select-pane -t top-left; kill-pane" \\\; select-layout -E
	else
		tmux $bind "$1" \
			if-shell "tmux new-window -dt :$2" \
			"join-pane -t :$2; select-pane -t top-left; kill-pane" \
			"send escape; join-pane -t :$2" \\\; select-layout
	fi
}

bind_layout() {
	# Bind keys to switch or refresh layouts.
	if [ "$2" = "zoom" ]; then
		# Invoke the zoom feature.
		tmux $bind "$1" \
			resize-pane -Z
	else
		# Actually switch layout.
		tmux $bind "$1" \
			select-layout "$2" \\\; select-layout -E
	fi
}

char_at() {
	echo $1 | cut -c $2
}

# Switch to workspace via alt + #.
bind_switch "${mod}1" 1
bind_switch "${mod}2" 2
bind_switch "${mod}3" 3
bind_switch "${mod}4" 4
bind_switch "${mod}5" 5
bind_switch "${mod}6" 6
bind_switch "${mod}7" 7
bind_switch "${mod}8" 8
bind_switch "${mod}9" 9

# Move pane to workspace via Alt + Shift + #.
bind_move "${mod}$(char_at $shiftnum 1)" 1
bind_move "${mod}$(char_at $shiftnum 2)" 2
bind_move "${mod}$(char_at $shiftnum 3)" 3
bind_move "${mod}$(char_at $shiftnum 4)" 4
bind_move "${mod}$(char_at $shiftnum 5)" 5
bind_move "${mod}$(char_at $shiftnum 6)" 6
bind_move "${mod}$(char_at $shiftnum 7)" 7
bind_move "${mod}$(char_at $shiftnum 8)" 8
bind_move "${mod}$(char_at $shiftnum 9)" 9

# The mapping of Alt + 0 and Alt + Shift + 0 depends on `base-index`.
# It can either refer to workspace number 0 or workspace number 10.
if [ "$(tmux show-option -gv base-index)" = "1" ]; then
	bind_switch "${mod}0" 10
	bind_move "${mod}$(char_at "$shiftnum" 10)" 10
else
	bind_switch "${mod}0" 0
	bind_move "${mod}$(char_at "$shiftnum" 10)" 0
fi

# Switch layout with Alt + <mnemonic key>. The mnemonics are `s` and `S` for
# layouts Vim would generate with `:split`, and `v` and `V` for `:vsplit`.
# The remaining mappings based on `z` and `t` should be quite obvious.
bind_layout "${mod}${s}" 'main-horizontal'
bind_layout "${mod}${S}" 'even-vertical'
bind_layout "${mod}${v}" 'main-vertical'
bind_layout "${mod}${V}" 'even-horizontal'
bind_layout "${mod}${t}" 'tiled'
bind_layout "${mod}${z}" 'zoom'

# Refresh the current layout (e.g. after deleting a pane).
tmux $bind "${mod}${r}" select-layout -E

# Switch pane via Alt + o or move via Alt + Shift + o.
# (This mirrors Tmux `Ctrl-b o` and Emacs `Ctrl-x o`.)
tmux $bind "${mod}${o}" select-pane -t :.+1
tmux $bind "${mod}${O}" swap-pane -D

# Switch to pane via Alt + arrow keys.
tmux $bind "${mod}${left}" select-pane -L
tmux $bind "${mod}${down}" select-pane -D
tmux $bind "${mod}${up}" select-pane -U
tmux $bind "${mod}${right}" select-pane -R

# Move a pane via Alt + Shift + arrow keys.
tmux $bind "${mod}${S_left}" swap-pane -s '{left-of}'
tmux $bind "${mod}${S_down}" swap-pane -s '{down-of}'
tmux $bind "${mod}${S_up}" swap-pane -s '{up-of}'
tmux $bind "${mod}${S_right}" swap-pane -s '{right-of}'

# Open a terminal with alt + n
tmux $bind "${mod}${n}" \
  run-shell 'cwd=$(tmux display -p "#{pane_current_path}"); \
             w=$(tmux display -p "#{pane_width}"); \
             h=$(tmux display -p "#{pane_height}"); \
             if [ $(( w * 6)) -gt $(( h * 10 )) ]; then \
               tmux split-pane -h -c "$cwd"; \
             else \
               tmux split-pane -v -c "$cwd"; \
             fi'

# Name a window with alt + enter.
tmux $bind "${mod}${enter}" \
	command-prompt -p 'Workspace name:' 'rename-window "%%"'

# Close a window with alt + w.
tmux $bind "${mod}${w}" \
	if-shell \
	'[ "$(tmux display-message -p "#{window_panes}")" -gt 1 ]' \
	'kill-pane;' \
	'kill-pane'

# Close a connection with Alt + Shift + e.
tmux $bind "${mod}${E}" \
	confirm-before -p "Detach from #H:#S? (y/n)" detach-client
