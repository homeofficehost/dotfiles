# 🚀 Teste de Alternativas ao Ngrok - Resultados

## 📊 Sumário dos Testes

| Ferramenta | Status | Instalação | Signup | Comando | URL Gerada |
|------------|--------|------------|--------|---------|------------|
| **Pinggy** | ✅ Funcionou | ❌ Não precisa | ❌ Não | `ssh -p 443 -R 80:localhost:PORT a.pinggy.io` | `https://xxx.a.free.pinggy.link` |
| **localhost.run** | ✅ Funcionou | ❌ Não precisa | ❌ Não | `ssh -R 80:localhost:PORT localhost.run` | `https://xxx.lhr.life` |
| **Cloudflare Tunnel** | ✅ Funcionou | ⚠️ Download | ❌ Não | `cloudflared tunnel --url http://localhost:PORT` | `https://xxx.trycloudflare.com` |
| **Localtunnel** | ❌ Falhou | npm/npx | ❌ Não | `npx localtunnel --port PORT` | - |

---

## 🏆 Recomendações

### 🥇 1º Lugar: **Pinggy** ⭐
- ✅ Funciona instantaneamente sem instalação
- ✅ Apenas SSH (já disponível em todo Linux)
- ✅ Bandwidth ilimitado
- ⚠️ Expira em 60 minutos (gratuito)

**Comando:**
```bash
opencode serve --port 8080 --hostname 0.0.0.0 &
ssh -p 443 -R 80:localhost:8080 a.pinggy.io
```

> ⚠️ **IMPORTANTE:** Use `-R 80:` (com espaço) e não `-R0:` (junto). A porta 80 é a porta remota do servidor Pinggy.

---

### 🥈 2º Lugar: **localhost.run** 🎯
- ✅ Funciona sem instalação
- ✅ Apenas SSH
- ✅ Mostra QR code no terminal
- ⚠️ Domínio aleatório a cada conexão

**Comando:**
```bash
opencode serve --port 8080 --hostname 0.0.0.0 &
ssh -R 80:localhost:8080 localhost.run
```

---

### 🥉 3º Lugar: **Cloudflare Tunnel** ☁️
- ✅ Muito estável (infraestrutura Cloudflare)
- ⚠️ Requer download do binário
- ✅ Quick tunnel não precisa de conta
- ✅ URL amigável

**Comando:**
```bash
# Download único
curl -L "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" -o cloudflared
chmod +x cloudflared

# Uso
opencode serve --port 8080 --hostname 0.0.0.0 &
./cloudflared tunnel --url http://localhost:8080
```

---

### ❌ **Localtunnel** - Problemas
- Erro com npx (problema de permissões)
- Requer instalação global com sudo
- Biblioteca com warnings de depreciação

---

## 🎬 Script Pronto para Uso

```bash
#!/bin/bash
# opencode-serve-public.sh

PORT=${1:-8080}

echo "🚀 Iniciando opencode serve na porta $PORT..."
opencode serve --port $PORT --hostname 0.0.0.0 &
OPENCODE_PID=$!

sleep 2

echo ""
echo "🌐 Escolha o método de tunneling:"
echo "1) Pinggy (recomendado - mais fácil)"
echo "2) localhost.run"
echo "3) Cloudflare Tunnel"
read -p "Opção (1-3): " choice

case $choice in
  1)
    echo "🔗 Conectando via Pinggy..."
    ssh -p 443 -R 80:localhost:$PORT a.pinggy.io
    ;;
  2)
    echo "🔗 Conectando via localhost.run..."
    ssh -R 80:localhost:$PORT localhost.run
    ;;
  3)
    if [ ! -f ./cloudflared ]; then
      echo "⬇️  Baixando cloudflared..."
      curl -L "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" -o cloudflared
      chmod +x cloudflared
    fi
    echo "🔗 Conectando via Cloudflare..."
    ./cloudflared tunnel --url http://localhost:$PORT
    ;;
  *)
    echo "❌ Opção inválida"
    kill $OPENCODE_PID
    exit 1
    ;;
esac

# Cleanup
kill $OPENCODE_PID 2>/dev/null
```

---

## 💡 Dica Rápida

Para uso **imediato sem instalação**, use:

```bash
# Terminal 1
opencode serve --port 8080 --hostname 0.0.0.0

# Terminal 2 (escolha um)
ssh -p 443 -R0:localhost:8080 a.pinggy.io        # 🥇 Pinggy
ssh -R 80:localhost:8080 localhost.run            # 🥈 localhost.run
```

**Pinggy é o vencedor** 🏆 - Funciona instantaneamente, sem instalação, sem conta!
