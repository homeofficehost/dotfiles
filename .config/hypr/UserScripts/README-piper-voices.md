# Sistema de TTS com Múltiplas Vozes Portuguesas

Este sistema foi atualizado para suportar múltiplas vozes portuguesas do piper-tts.

## Vozes Disponíveis

O sistema agora inclui três vozes diferentes em português brasileiro:

1. **pt_BR-faber-large** (Índice 0) - Voz masculina de alta qualidade
2. **pt_BR-faber-medium** (Índice 1) - Voz masculina de qualidade média (mais rápida)
3. **pt_BR-edresson-low** (Índice 2) - Voz feminina de qualidade baixa (mais rápida)

## Como Usar

### Modo Aleatório (Padrão)
Por padrão, o script `falar-toggle.sh` seleciona aleatoriamente uma das vozes disponíveis a cada execução:

```bash
./UserScripts/falar-toggle.sh "Texto para falar"
```

### Selecionar Voz Específica
Para usar uma voz específica, defina a variável de ambiente `PIPER_VOICE_INDEX`:

```bash
# Usar sempre a voz faber-large
export PIPER_VOICE_INDEX=0
./UserScripts/falar-toggle.sh "Teste com voz masculina grande"

# Usar sempre a voz faber-medium
export PIPER_VOICE_INDEX=1
./UserScripts/falar-toggle.sh "Teste com voz masculina média"

# Usar sempre a voz edresson-low
export PIPER_VOICE_INDEX=2
./UserScripts/falar-toggle.sh "Teste com voz feminina"
```

### Voltar ao Modo Aleatório
Para voltar ao modo aleatório:

```bash
unset PIPER_VOICE_INDEX
```

## Script de Gerenciamento de Vozes

O script `piper-voices.sh` facilita o gerenciamento das vozes:

### Listar Vozes Disponíveis
```bash
./UserScripts/piper-voices.sh list
# ou
./UserScripts/piper-voices.sh l
```

### Testar uma Voz
```bash
./UserScripts/piper-voices.sh test 0    # Testa faber-large
./UserScripts/piper-voices.sh test 1    # Testa faber-medium  
./UserScripts/piper-voices.sh test 2    # Testa edresson-low
```

### Definir Voz Padrão
```bash
./UserScripts/piper-voices.sh set 1     # Define faber-medium como padrão
```

## Logs

O sistema registra qual voz está sendo usada nos logs. Para ver:

```bash
tail -f "${XDG_RUNTIME_DIR:-/tmp}/hypr_tts.log"
```

Exemplo de log:
```
[2025-08-26 01:53:37] toggle: starting TTS (len=25) using voice: pt_BR-faber-medium
```

## Personalização

Para adicionar novas vozes portuguesas:

1. Baixe o modelo `.onnx` e o arquivo `.json` correspondente para `~/.local/share/piper/models/`
2. Adicione o caminho do modelo ao array `PT_VOICES` em ambos os scripts:
   - `UserScripts/falar-toggle.sh`
   - `UserScripts/piper-voices.sh`

## Características das Vozes

- **faber-large**: Melhor qualidade de áudio, mais lenta, voz masculina mais natural
- **faber-medium**: Qualidade média, velocidade moderada, voz masculina
- **edresson-low**: Qualidade mais baixa, mais rápida, voz feminina

A escolha da voz pode depender do seu caso de uso - use `large` para texto importante, `medium` para uso geral, e `low` para respostas rápidas.
