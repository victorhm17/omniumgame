## Estrutura de Dados para Desafios de Fotos (Firestore)

Coleção: `challenges` (ou dentro do documento `matches`)
Se dentro de `matches`, pode ser um mapa:
`challenge_details`:
  * `chosen_challenge_type`: String (Ex: "pilha", "carro", "cadeira" - virá de uma lista pré-definida)
  * `challenger_id`: String (UID do vencedor da partida de trivia)
  * `challenged_id`: String (UID do perdedor da partida de trivia)
  * `status`: String ("pending_submission", "submitted", "skipped", "completed")
  * `photo_url`: String (URL da foto enviada, se `status` == "submitted")
  * `submitted_at`: Timestamp
  * `skipped_at`: Timestamp

Alternativamente, uma coleção separada `photo_challenges`:
Documento: `challenge_id` (pode ser o mesmo que `match_id` para fácil referência)

Campos:
*   `match_id`: String (ID da partida original)
*   `chosen_challenge_type`: String
*   `challenger_id`: String
*   `challenged_id`: String
*   `status`: String
*   `photo_url`: String
*   `submitted_at`: Timestamp
*   `skipped_at`: Timestamp
*   `created_at`: Timestamp

**Lista Pré-definida de Tipos de Desafio:**
Coleção: `challenge_types`
Documento: `type_id` (Ex: "pilha_objetos", "carro_qualquer", "cadeira_engracada")

Campos:
*   `name`: String (Ex: "Uma pilha de objetos", "Um carro qualquer", "Uma cadeira engraçada")
*   `description`: String (Opcional, descrição mais detalhada do desafio)
*   `icon_url`: String (Opcional, para exibir na UI)

## Lógica do Sistema de Desafios de Fotos

1.  **Fim da Partida de Trivia:**
    *   Após o `match` ser "completed" e um `winner_id` ser definido.
    *   O jogador vencedor (`challenger_id`) é apresentado com uma lista de tipos de desafios pré-definidos (buscados da coleção `challenge_types`).

2.  **Escolha do Desafio:**
    *   O vencedor seleciona um `chosen_challenge_type`.
    *   Um novo registro de desafio é criado (seja no `match` ou na coleção `photo_challenges`) com `status` = "pending_submission".

3.  **Notificação ao Perdedor:**
    *   O jogador perdedor (`challenged_id`) é notificado sobre o desafio escolhido.
    *   Ele vê o tipo de desafio e tem as opções: "Enviar Foto" ou "Pular Desafio".

4.  **Envio da Foto:**
    *   Se o perdedor escolher "Enviar Foto":
        *   Abre a câmera ou galeria do dispositivo (usar `image_picker` plugin).
        *   A foto selecionada é enviada para o Firebase Storage.
        *   A `photo_url` é salva no registro do desafio.
        *   O `status` do desafio muda para "submitted".
        *   O `submitted_at` é registrado.
        *   Opcional: O vencedor é notificado que a foto foi enviada e pode visualizá-la.

5.  **Pular Desafio:**
    *   Se o perdedor escolher "Pular Desafio":
        *   O `status` do desafio muda para "skipped".
        *   O `skipped_at` é registrado.
        *   A reputação do perdedor é afetada (ex: perfil marcado como "jogador evasivo"). Isso será tratado pelo sistema de reputação.

6.  **Visualização (Opcional):**
    *   O vencedor pode ver a foto enviada pelo perdedor.
    *   A foto pode ficar visível no perfil do perdedor ou em um histórico da partida (a definir conforme PRD).

## Telas Envolvidas (Placeholder)

*   `challenge_selection_screen.dart`: Para o vencedor escolher o tipo de desafio.
*   `challenge_submission_screen.dart`: Para o perdedor ver o desafio e optar por enviar a foto ou pular.
*   `photo_display_screen.dart`: (Opcional) Para visualizar a foto enviada.

## Considerações Adicionais

*   **Armazenamento de Fotos:** Firebase Storage será usado. É preciso definir regras de segurança para o acesso.
*   **Moderação de Conteúdo:** Não mencionado, mas fotos enviadas por usuários podem precisar de moderação.
*   **Plugin `image_picker`:** Para selecionar imagens da galeria ou câmera.
*   **Plugin `firebase_storage`:** Para fazer upload das imagens.

