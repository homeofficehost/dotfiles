# # startx if on tty1 and tmux on tty2
# if [[ -z "$DISPLAY" ]] && [[ $(tty) = /dev/tty1 ]]; then
#     exec xinit -- :0 -novtswitch &>/dev/null &
#     logout
# elif [[ $(tty) = /dev/tty2 ]]; then
#     tmux -f $HOME/.tmux.conf new -s secured
# fi

export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
# export QT_DEVICE_PIXEL_RATIO=1.2

source ~/.shellvars
source ~/.shellfn
source ~/.shellpaths
source ~/.shellaliases
