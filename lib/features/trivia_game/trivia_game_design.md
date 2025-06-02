## Estrutura de Dados para Perguntas e Respostas (Firestore)

Coleção: `questions`
Documento: `question_id` (gerado automaticamente ou ID customizado)

Campos:
*   `text`: String (O enunciado da pergunta)
*   `category`: String (Ex: "História", "Ciência", "Esportes", "Geral")
*   `difficulty`: String (Ex: "Fácil", "Médio", "Difícil")
*   `options`: List<Map<String, dynamic>>
    *   `text`: String (Texto da opção de resposta)
    *   `is_correct`: bool (Indica se esta é a resposta correta)
*   `image_url`: String (Opcional, URL de uma imagem associada à pergunta)
*   `explanation`: String (Opcional, uma breve explicação sobre a resposta correta)
*   `created_at`: Timestamp
*   `updated_at`: Timestamp

Coleção: `game_sessions` (ou dentro do documento `matches`)
Se dentro de `matches`, o campo `questions` pode ser uma lista de `question_id` e as respostas dos jogadores podem ser armazenadas em um novo campo, por exemplo `player_answers`.

Exemplo de `player_answers` dentro de `matches`:
`player_answers`: Map<String, List<Map<String, dynamic>>>
  `player1_id`:
    - `question_id`: "q1"
    - `selected_option_index`: 2
    - `is_correct`: true
    - `time_taken_ms`: 5200
  `player2_id`:
    - `question_id`: "q1"
    - `selected_option_index`: 1
    - `is_correct`: false
    - `time_taken_ms`: 7100

## Lógica do Jogo de Trivia

1.  **Início da Partida:**
    *   Quando um `match` se torna "active", o sistema seleciona um conjunto de perguntas (ex: 10 perguntas) da coleção `questions`. A seleção pode ser aleatória, por categoria, dificuldade, etc.
    *   As IDs das perguntas (ou as perguntas completas) são armazenadas no documento `match`.

2.  **Turnos:**
    *   A partida define quem começa (`current_turn` no `match`).
    *   O jogador da vez recebe a primeira pergunta não respondida.
    *   Um temporizador é iniciado para a resposta (ex: 15-30 segundos).

3.  **Responder Pergunta:**
    *   O jogador seleciona uma das opções.
    *   A resposta (opção selecionada, se correta, tempo levado) é registrada no `match`.
    *   O score do jogador é atualizado.
    *   Feedback visual é dado (correto/incorreto).

4.  **Alternância de Turno:**
    *   Após a resposta (ou o tempo esgotar), o turno passa para o outro jogador para a MESMA pergunta (se for o modelo de ambos respondem a mesma pergunta antes de passar para a próxima) ou para a PRÓXIMA pergunta (se for um modelo de perguntas alternadas).
    *   O PRD sugere que ambos respondem e o mais rápido/correto vence a rodada da pergunta. Isso precisa ser detalhado.
    *   Se for "quem vencer (seja respondendo mais perguntas corretamente ou sendo mais rápido)", então cada pergunta é uma rodada. Ambos respondem. Quem acertar ganha ponto. Se ambos acertarem, o mais rápido ganha um bônus ou desempate.

5.  **Fim da Partida:**
    *   Após todas as perguntas serem respondidas por ambos os jogadores.
    *   O jogador com maior score é declarado o vencedor (`winner_id` no `match`).
    *   O `status` do `match` muda para "completed".
    *   O vencedor pode escolher um desafio para o perdedor.

## Telas Envolvidas (Placeholder)

*   `trivia_game_screen.dart`: Tela principal onde as perguntas são exibidas, opções são selecionadas, e o placar é mostrado.
*   `game_results_screen.dart`: Tela exibida ao final da partida, mostrando o vencedor, perdedor e a opção de escolher/cumprir desafio.

## Considerações Adicionais

*   **Banco de Perguntas:** Como as perguntas serão populadas? Inicialmente podem ser fixas no código ou em um JSON local, mas idealmente viriam do Firestore para fácil atualização.
*   **Velocidade da Resposta:** O tempo de resposta precisa ser cronometrado e armazenado para desempates ou pontuação bônus.
*   **Power-ups/Dicas:** Não mencionado, mas poderia ser uma funcionalidade futura.

