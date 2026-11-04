# atalhos de busca em texto com ripgrep (busca = lista tudo)
# uso: <atalho> PADRÃO [flags extras do rg]   ex: notas docker -t md -C2

# base: smart-case, ocultos, sem .git, linha+coluna, ignora linhas gigantes
_RG_OPTS=(--smart-case --hidden --glob '!.git' --line-number --column
          --max-columns 300 --max-columns-preview)

alias acha='rg "${_RG_OPTS[@]}"'                        # aqui (respeita .gitignore)
alias vasculha='rg "${_RG_OPTS[@]}" -uu'                  # tudo: ignora .gitignore e afins
alias exato='rg "${_RG_OPTS[@]}" -F'                   # texto literal (sem regex)
alias palavra='rg "${_RG_OPTS[@]}" -w'                   # palavra inteira
alias onde='rg "${_RG_OPTS[@]}" -l'                   # só nomes dos arquivos
alias arquivo='rg --hidden --glob "!.git" --files | rg --smart-case'  # busca no NOME do arquivo

# busca PADRÃO em diretórios fixos; extras vão antes dos caminhos
_bdir() { local p=$1; shift; (( $# )) || { echo "uso: PADRÃO [flags]"; return 1; }
  local pat=$1; shift; rg "${_RG_OPTS[@]}" "$@" -- "$pat" ${(s.:.)p}; }

notas()      { _bdir ~/knowledge "$@"; }                      # notas e gists
gists()      { _bdir ~/knowledge/gists "$@"; }                # só gists
projetos()   { _bdir ~/work:~/fun:~/pro:~/code "$@"; }        # projetos
configs()    { _bdir ~/.config:~/.zshrc:~/.zshenv:~/.shellaliases "$@"; }  # configs
documentos() { _bdir ~/Documents:~/Downloads:~/Desktop "$@"; } # documentos soltos

# interativo: digita e filtra ao vivo com fzf; Enter abre no $EDITOR na linha
explora() { local dir=${1:-.}
  : | fzf --ansi --disabled --delimiter : \
      --bind "start:reload:rg ${_RG_OPTS[*]} --color=always -- {q} $dir || true" \
      --bind "change:reload:sleep 0.1; rg ${_RG_OPTS[*]} --color=always -- {q} $dir || true" \
      --preview 'bat --color=always --highlight-line {2} {1} 2>/dev/null || sed -n "{2}p" {1}' \
      --preview-window 'right,55%,+{2}-/2' \
      --bind "enter:become(${EDITOR:-vim} +{2} {1})"
}

# lista os atalhos
busca() { cat <<'EOF2'
🔍 acha PADRÃO   pasta atual          vasculha  tudo, até ignorados
   exato         texto literal        palavra   palavra inteira
   onde          só arquivos          arquivo   pelo nome do arquivo
📁 notas  ~/knowledge   gists  ~/knowledge/gists   projetos  work/fun/pro/code
   configs  ~/.config e rc's          documentos  Documents/Downloads/Desktop
⚡ explora [PASTA]  busca interativa (fzf), Enter abre no editor
   extras do rg em qualquer um: -t md  -g '*.sh'  -C2  -i
EOF2
}
