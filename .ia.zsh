# Atalhos de IA local (opencode run com um modelo fixo). Uso: unask "sua pergunta"
# Os argumentos vão direto para o opencode (alias já repassa tudo; não precisa de $@).
# Ver todos: ias

_oc_local='opencode run --pure --agent local -m'

alias unask="$_oc_local 'ollama-devws/hf.co/HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive:Q4_K_M'"  # 🔥 Qwen3.6 35B uncensored · 51 tok/s
alias rapido="$_oc_local 'ollama-devws/qwen38-9b-heretic-q5km-32k'"                                             # ⚡ Qwen3.8 9B heretic · 48 tok/s
alias gemma="$_oc_local 'ollama-devws/hf.co/HauhauCS/Gemma4-12B-QAT-Uncensored-HauhauCS-Balanced:Q4_K_M'"      # 💎 Gemma4 12B uncensored · 37 tok/s
alias q14="$_oc_local 'ollama-devws/qwen3-14b-heretic-16k'"                                                     # 🧠 Qwen3 14B heretic · 29 tok/s
alias coder="$_oc_local 'ollama-devws/qwen3-coder:30b'"                                                         # 👨‍💻 Qwen3 Coder 30B · 36 tok/s
alias oss="$_oc_local 'ollama-devws/gpt-oss:20b'"                                                               # 🎯 gpt-oss 20B · 40 tok/s
alias q27="$_oc_local 'ollama-devws/hf.co/HauhauCS/Qwen3.8-27B-Uncensored-HauhauCS-Aggressive-MTP-GGUF:IQ4_XS'" # 🐢 Qwen3.8 27B uncensored · 4 tok/s
alias colibri='opencode run --pure --agent colibri'                                                             # 🐦 LFM3-VL 2B no colibri · 170 tok/s, sem ferramentas

unset _oc_local

# Variação interativa: oc-<atalho> abre o OpenCode (TUI) com o mesmo modelo, sem "run".
# Ex.: oc-unask  ·  oc-coder --prompt "revise isso"
for _a in ${(k)aliases}; do
  [[ ${aliases[$_a]} == 'opencode run '* ]] && alias "oc-$_a"="opencode ${aliases[$_a]#opencode run }"
done
unset _a

ias() {
  print -P '%BAtalhos de IA local%b  (uso: atalho "pergunta" · oc-atalho abre o OpenCode)'
  local linha
  for linha in ${(f)"$(grep -E '^alias ' ~/.ia.zsh)"}; do
    printf '  %-8s %s\n' ${${linha#alias }%%=*} ${linha##*\# }
  done
}
