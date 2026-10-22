---
name: tri
description: Estratégia de 3 etapas para tarefas de código com custo baixo — planner forte planeja em inglês, orchestrator barato coordena e revisa, executor local (Ollama, 32k) executa. Use quando a tarefa puder ser quebrada em passos pequenos e verificáveis, ou quando o usuário pedir "/tri", "plano + execução local" ou "economizar tokens".
---

# tri: planejar forte, coordenar barato, executar local

## Quando usar
- Mudanças que cabem em tarefas pequenas (até ~4 arquivos e ~300 linhas cada) com um comando de verificação.
- Não use para investigação aberta, decisões de arquitetura ou tarefas que precisem de web.

## Como rodar
- Pelo comando: `/tri <pedido em português ou inglês>`.
- Só o plano, sem executar: chame o subagente `planner` com o pedido.

## As etapas
| Etapa | Agente | Modelo | Papel |
|---|---|---|---|
| 1 | `planner` | `openai/gpt-5.6-sol-fast` | Lê o repo e escreve o plano em inglês: Goal, Context, Tasks (Files / Steps / Check / Done when), Risks |
| 2 | `orchestrator` | `kiro/claude-haiku-4-5` | Despacha uma tarefa por vez, revisa só o diff e o Check, repete uma vez se falhar, não commita |
| 3 | `executor` | `ollama-devws/qwen38-9b-heretic-q5km-32k` | Executa uma tarefa com só os arquivos listados e responde STATUS/CHANGED/CHECK |

## Ajustes
- Os prompts ficam em `~/.config/opencode/agents/{planner,orchestrator,executor}.md`; o formato do plano está no `planner.md`.
- Para trocar um modelo, edite o campo `model:` do agente.
- O executor depende do devworkstation ligado (Ollama em `devworkstation.local:11434`).
