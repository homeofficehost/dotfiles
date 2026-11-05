# 💡 Atalhos da Lâmpada T120-30W (Home Assistant via https://home.arpa/api/lampada/)
# Carregado pelo ~/.zshrc: [ -f ~/.lampada.zsh ] && source ~/.lampada.zsh

# Fala direto com o Caddy (192.168.18.75): funciona mesmo onde home.arpa não resolve no DNS.
_lampada() {
  local opts=()
  local ca; for ca in ~/.config/infra/ca/rootCA.pem ~/homelab/ca/rootCA.pem; do [ -f "$ca" ] && { opts+=(--cacert "$ca"); break; }; done
  [ "$1" != estado ] && opts+=(-X POST -d "{\"entity_id\":\"light.lampada_t120_30w\"$2}")
  curl -sS --resolve home.arpa:443:192.168.18.75 "${opts[@]}" "https://home.arpa/api/lampada/$1"
}
# Espera a lâmpada confirmar antes de mostrar o estado novo.
_lampada_acao() { _lampada "$1" "$2" >/dev/null && sleep .8 && lampada-estado; }

lampada-estado() {
  _lampada estado | python3 -c 'import sys,json
d=json.load(sys.stdin);a=d["attributes"]
if d["state"]!="on": print("💡 lâmpada:",{"off":"desligada"}.get(d["state"],d["state"]));sys.exit()
cor=f"cor {round(a["hs_color"][0])}°" if a.get("color_mode")=="hs" else f"branca {round(a.get("color_temp_kelvin") or 0)} K"
print(f"💡 lâmpada: ligada · {round((a.get("brightness") or 0)/2.55)}% · {cor}")'
}

alias lampada-ligar='_lampada_acao turn_on'
alias lampada-desligar='_lampada_acao turn_off'
alias lampada-alternar='_lampada_acao toggle'

alias lampada-branca-quente='_lampada_acao turn_on ",\"color_temp_kelvin\":2700"'
alias lampada-branca-neutra='_lampada_acao turn_on ",\"color_temp_kelvin\":4000"'
alias lampada-branca-fria='_lampada_acao turn_on ",\"color_temp_kelvin\":6500"'
alias lampada-vermelha='_lampada_acao turn_on ",\"hs_color\":[0,100]"'
alias lampada-verde='_lampada_acao turn_on ",\"hs_color\":[120,100]"'
alias lampada-azul='_lampada_acao turn_on ",\"hs_color\":[230,100]"'
alias lampada-roxa='_lampada_acao turn_on ",\"hs_color\":[280,100]"'

alias lampada-brilho-baixo='_lampada_acao turn_on ",\"brightness_pct\":15"'
alias lampada-brilho-medio='_lampada_acao turn_on ",\"brightness_pct\":50"'
alias lampada-brilho-maximo='_lampada_acao turn_on ",\"brightness_pct\":100"'

# Pisca em vermelho (vezes, segundos aceso/apagado) e volta exatamente ao estado de antes.
_lampada_piscar() {
  local antes=$(_lampada estado | python3 -c 'import sys,json
d=json.load(sys.stdin);a=d["attributes"]
if d["state"]!="on": print("off")
elif a.get("color_mode")=="hs": print(f",\"brightness\":{a["brightness"]},\"hs_color\":{a["hs_color"]}")
else: print(f",\"brightness\":{a["brightness"]},\"color_temp_kelvin\":{round(a["color_temp_kelvin"])}")')
  [ -z "$antes" ] && { echo "💡 lâmpada indisponível, não pisquei"; return 1; }
  repeat $1 { _lampada turn_on ',"hs_color":[0,100],"brightness_pct":100' >/dev/null; sleep $2
              _lampada turn_off '' >/dev/null; sleep $2 }
  [ "$antes" = off ] && _lampada_acao turn_off '' || _lampada_acao turn_on "$antes"
}
alias lampada-piscar-vermelho='_lampada_piscar 2 .6'   # 2x devagar, igual ao aviso das 02:00
alias lampada-piscar-rapido='_lampada_piscar 3 .25'    # 3x rápido

alias lampada-painel='open https://home.arpa/admin 2>/dev/null || xdg-open https://home.arpa/admin'
alias lampada-ajuda='grep -oE "^(alias )?lampada-[a-z-]+" ~/.lampada.zsh | sed "s/^alias //"'
