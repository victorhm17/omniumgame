## Estrutura de Dados para Reputação do Jogador (Firestore)

No documento do usuário (Coleção: `users`, Documento: `user_id`):

Campos adicionais:
*   `reputation_status`: String (Ex: "Normal", "Jogador Evasivo", "Confiável") - Pode ser um enum ou string.
*   `challenges_skipped_count`: Number (Contador de desafios pulados)
*   `challenges_completed_count`: Number (Contador de desafios cumpridos)
*   `matches_played`: Number
*   `matches_won`: Number
*   `last_reputation_update`: Timestamp

## Lógica do Sistema de Reputação

1.  **Inicialização:**
    *   Quando um novo usuário é criado, `reputation_status` pode ser "Normal", e contadores zerados.

2.  **Atualização ao Pular Desafio:**
    *   Quando um jogador pula um desafio de foto (status do desafio muda para "skipped"):
        *   Incrementar `challenges_skipped_count` no perfil do jogador.
        *   Atualizar `last_reputation_update`.
        *   Uma Cloud Function ou lógica no backend pode ser acionada para reavaliar o `reputation_status` com base no `challenges_skipped_count` e outras métricas (ex: se `challenges_skipped_count` > X, mudar status para "Jogador Evasivo").

3.  **Atualização ao Cumprir Desafio:**
    *   Quando um jogador envia a foto para um desafio (status do desafio muda para "submitted"):
        *   Incrementar `challenges_completed_count`.
        *   Atualizar `last_reputation_update`.
        *   Isso pode influenciar positivamente a reputação ou reverter um status negativo.

4.  **Exibição da Reputação:**
    *   O `reputation_status` pode ser exibido no perfil do jogador, visível para outros jogadores (especialmente durante o matchmaking ou ao visualizar perfis de amigos).

5.  **Critérios para Mudança de Status (Exemplo):**
    *   **Jogador Evasivo:** Se `challenges_skipped_count` >= 3 (ou uma porcentagem dos desafios totais).
    *   **Confiável:** Se `challenges_completed_count` >= 10 e `challenges_skipped_count` <= 1 (ou uma boa proporção).
    *   A lógica exata pode ser ajustada.

## Integração com Outras Funcionalidades

*   **Desafios de Fotos:** Quando `skipChallenge` é chamado no `PhotoChallengesRepository`, ele deve também invocar uma função para atualizar os dados de reputação do usuário.
*   **Perfil do Usuário:** A tela de perfil do usuário deve exibir o `reputation_status`.

## Telas Envolvidas (Placeholder)

*   Nenhuma tela nova específica apenas para reputação, mas a informação será integrada em:
    *   `profile_screen.dart` (a ser criada ou parte da `home_screen.dart`)
    *   Possivelmente em telas de matchmaking ou ao visualizar oponentes.

## Considerações Adicionais

*   **Cloud Functions:** Para lógicas mais complexas de atualização de reputação ou para evitar que o cliente manipule diretamente os contadores de forma indevida, Cloud Functions são recomendadas.
*   **Visibilidade:** Definir quem pode ver qual parte da informação de reputação.
*   **Decaimento ou Reset:** Considerar se a reputação negativa decai com o tempo ou com bom comportamento.

