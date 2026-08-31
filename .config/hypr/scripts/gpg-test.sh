#!/usr/bin/env bash

echo "=== Diagnóstico GPG ==="
echo

echo "1. Verificando gpg-agent:"
if pgrep gpg-agent >/dev/null; then
    echo "✅ gpg-agent está rodando"
else
    echo "❌ gpg-agent não está rodando"
fi

echo
echo "2. Versão do gpg-agent:"
gpgconf --check-programs

echo
echo "3. Testando conexão com gpg-agent:"
gpg-connect-agent 'getinfo version' /bye

echo
echo "4. Variáveis de ambiente:"
echo "GPG_TTY: $GPG_TTY"
echo "SSH_AUTH_SOCK: $SSH_AUTH_SOCK"

echo
echo "5. Chaves disponíveis:"
gpg --list-secret-keys --with-keygrip

echo
echo "6. Testando assinatura simples:"
if echo "teste" | gpg --sign --armor --local-user thomas.groch@gmail.com >/dev/null 2>&1; then
    echo "✅ Assinatura funcionou"
else
    echo "❌ Assinatura falhou"
fi

echo
echo "7. Configuração do gpg-agent:"
cat ~/.gnupg/gpg-agent.conf

echo
echo "=== Fim do diagnóstico ==="
