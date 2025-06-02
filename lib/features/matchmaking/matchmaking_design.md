## Estrutura de Dados para Matchmaking (Firestore)

Coleção: `matches`
Documento: `match_id` (gerado automaticamente)

Campos:
*   `player1_id`: String (UID do jogador 1)
*   `player2_id`: String (UID do jogador 2, pode ser nulo inicialmente se esperando oponente)
*   `player1_username`: String
*   `player2_username`: String (nulo inicialmente)
*   `status`: String ("pending_random", "pending_friend_invite", "active", "completed", "cancelled")
*   `created_at`: Timestamp
*   `updated_at`: Timestamp
*   `current_turn`: String (UID do jogador da vez, ou "player1"/"player2")
*   `questions`: List<Map<String, dynamic>> (lista de IDs de perguntas ou as perguntas em si)
*   `scores`: Map<String, int> (ex: {"player1_id": 0, "player2_id": 0})
*   `winner_id`: String (nulo até o fim)
*   `is_friend_match`: bool (true se foi convite para amigo)
*   `invited_friend_id`: String (UID do amigo convidado, se `is_friend_match` for true e status `pending_friend_invite`)

Coleção: `match_invites` (alternativa para convites de amigos)
Documento: `invite_id`

Campos:
*   `inviter_id`: String
*   `invited_id`: String
*   `status`: String ("pending", "accepted", "declined")
*   `created_at`: Timestamp
*   `match_id_on_accept`: String (opcional, se o match já é pré-criado)

## Lógica do Matchmaking

1.  **Jogar com Amigo:**
    *   Usuário A seleciona "Jogar com Amigo".
    *   Usuário A busca/seleciona Amigo B da lista de amigos (a ser implementada a lista de amigos).
    *   Um convite é enviado para o Amigo B (pode ser uma notificação push e/ou um item na UI do Amigo B).
    *   Se Amigo B aceita, um novo documento `match` é criado com `player1_id` = UID de A, `player2_id` = UID de B, `status` = "active".

2.  **Jogar Aleatório:**
    *   Usuário A seleciona "Jogar Aleatório".
    *   O sistema busca por um documento `match` com `status` = "pending_random" e `player2_id` nulo.
    *   Se encontrado, Usuário A se junta a esse match como `player2_id`, e o `status` muda para "active".
    *   Se não encontrado, um novo documento `match` é criado com `player1_id` = UID de A, `status` = "pending_random". O sistema aguarda outro jogador.
    *   (Considerar um timeout para `pending_random` para evitar que jogadores esperem indefinidamente).

## Telas Envolvidas (Placeholder)

*   `matchmaking_options_screen.dart`: Tela para escolher "Jogar com Amigo" ou "Jogar Aleatório". (Já referenciada na `home_screen.dart`)
*   `find_opponent_loading_screen.dart`: Tela de espera enquanto busca oponente aleatório ou amigo aceita convite.
*   `friend_list_screen.dart`: Tela para selecionar amigo para convidar (a ser criada).

