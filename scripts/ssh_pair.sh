#!/usr/bin/env sh

source ../lib_sh/echos.sh
source ../lib_sh/requirers.sh

usage () {
  echo "Opens a tunnel to a tmux session for pairing"
  echo "    Usage: pair GITHUB_USERNAMES TMUX_SESSION"
  echo "    Example: "
  return 0
}

pair () {
  local session=$1

  if [ -z $session ]; then
    usage
    return 1
  fi

  require_brew ngrok
  require_gem gh-auth
  sudo systemsetup -setremotelogin on # enable SSH server
  touch $HOME/.ssh/authorized_keys

  for user in ${@:2}
  do
    gh-auth add --users $user --command="TERM=screen-256color-bce $(which tmux) -2 attach -t $session"
  done

  local ssh_user=$USER
  ngrok --log stdout --proto=tcp 22 | copy

  for user in ${@:2}
  do
    gh-auth remove --users $user
  done

  yes "yes" | sudo systemsetup -setremotelogin off 1> /dev/null # disable SSH server
  return 0
}

copy () {
  while read ngrok_out
  do
    echo "$ngrok_out"
    echo "$ngrok_out" | grep "Tunnel established at" > /dev/null 2>&1
    if [ "$?" -eq "0" ]; then
      local port=$(echo "$ngrok_out" | sed 's/^.*Tunnel established at tcp:\/\/ngrok.com:\([0-9][0-9]*\)$/\1/')
      local pair_cmd="ssh -p $port -A $ssh_user@ngrok.com"
      echo "$pair_cmd" | ~/$MY_DOTFILES/scripts/pair.cmd
      chmod +x ~/$MY_DOTFILES/scripts/pair.cmd
      # echo "$pair_cmd" | pbcopy
      echo "Pairing tunnel established"
      port

      continue
    fi
  done
}

pair $@