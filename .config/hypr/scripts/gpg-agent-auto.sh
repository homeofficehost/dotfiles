#!/usr/bin/env bash

# --- Configuração ---
GPG_EMAIL="thomas.groch@gmail.com"
PASSPHRASE_FILE="$HOME/.ssh/gpg/${GPG_EMAIL}.private.gpg-key.passphrase"

# --- Log de debug (comentar para produção) ---
log_debug() {
    # echo "[GPG-AUTO] $1" >&2
    :
}

# --- Variáveis de ambiente ---
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
systemctl --user import-environment GPG_TTY SSH_AUTH_SOCK

log_debug "GPG_TTY: $GPG_TTY"
log_debug "SSH_AUTH_SOCK: $SSH_AUTH_SOCK"

# --- Inicia gpg-agent ---
log_debug "Iniciando gpg-agent..."
gpgconf --launch gpg-agent

# Aguarda um pouco para garantir que o agent está rodando
sleep 1

# --- Localiza todos os Keygrips ---
log_debug "Buscando keygrips para $GPG_EMAIL..."
KEYGRIPS=$(gpg --list-secret-keys --with-keygrip "$GPG_EMAIL" 2>/dev/null \
    | awk '/Keygrip/ {print $3}')

if [ -z "$KEYGRIPS" ]; then
    echo "[GPG-AUTO] ⚠️  Nenhum Keygrip encontrado para $GPG_EMAIL"
    echo "[GPG-AUTO] Verifique se a chave GPG está importada:"
    echo "           gpg --list-secret-keys"
    exit 1
fi

log_debug "Keygrips encontrados:"  
for grip in $KEYGRIPS; do
    log_debug "  - $grip"
done

# --- Verifica se o arquivo de senha existe ---
if [ ! -f "$PASSPHRASE_FILE" ]; then
    echo "[GPG-AUTO] ⚠️  Arquivo de senha não encontrado: $PASSPHRASE_FILE"
    echo "[GPG-AUTO] Crie o arquivo com a senha da chave GPG e defina permissões apropriadas:"
    echo "           echo 'sua_senha_aqui' > '$PASSPHRASE_FILE'"
    echo "           chmod 600 '$PASSPHRASE_FILE'"
    exit 1
fi

# --- Verifica permissões do arquivo de senha ---
PERMS=$(stat -c "%a" "$PASSPHRASE_FILE" 2>/dev/null)
if [ "$PERMS" != "600" ]; then
    echo "[GPG-AUTO] ⚠️  Permissões inseguras no arquivo de senha ($PERMS). Corrigindo..."
    chmod 600 "$PASSPHRASE_FILE"
fi

# --- Injeta senha automaticamente para todos os keygrips ---
log_debug "Injetando senha no gpg-agent para todos os keygrips..."
success_count=0
total_count=0

for keygrip in $KEYGRIPS; do
    total_count=$((total_count + 1))
    log_debug "Processando keygrip: $keygrip"
    if /usr/lib/gnupg/gpg-preset-passphrase --preset "$keygrip" < "$PASSPHRASE_FILE" 2>/dev/null; then
        success_count=$((success_count + 1))
        log_debug "✅ Keygrip $keygrip desbloqueado"
    else
        log_debug "❌ Falha no keygrip $keygrip"
    fi
done

if [ $success_count -gt 0 ]; then
    echo "[GPG-AUTO] ✅ Chave $GPG_EMAIL desbloqueada ($success_count/$total_count keygrips)."
else
    echo "[GPG-AUTO] ❌ Falha ao desbloquear qualquer keygrip. Verifique:"
    echo "           - Se o gpg-agent está rodando: gpg-connect-agent 'getinfo version' /bye"
    echo "           - Se a senha está correta no arquivo: $PASSPHRASE_FILE"
    echo "           - Se allow-preset-passphrase está habilitado no gpg-agent.conf"
    exit 1
fi

# --- Teste rápido ---
log_debug "Testando acesso à chave..."
if echo "test" | gpg --sign --local-user "$GPG_EMAIL" >/dev/null 2>&1; then
    echo "[GPG-AUTO] ✅ Teste de assinatura: OK"
else
    echo "[GPG-AUTO] ⚠️  Chave desbloqueada, mas teste de assinatura falhou"
fi

log_debug "Script concluído com sucesso"
