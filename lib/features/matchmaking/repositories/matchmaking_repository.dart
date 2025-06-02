import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:omnium_game/core/models/match_model.dart"; // Criar este modelo

class MatchmakingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  MatchmakingRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  // Iniciar busca por partida aleatória ou criar uma nova se nenhuma estiver disponível
  Future<MatchModel?> findOrCreateRandomMatch() async {
    if (currentUser == null) throw Exception("Usuário não autenticado.");

    final String currentUserId = currentUser!.uid;
    final String? currentUsername = currentUser!.displayName ?? currentUser!.email; // Usar um nome de usuário real do perfil

    // Tentar encontrar uma partida pendente para entrar
    QuerySnapshot pendingMatches = await _firestore
        .collection("matches")
        .where("status", isEqualTo: "pending_random")
        .where("player1_id", isNotEqualTo: currentUserId) // Não entrar na própria partida pendente
        .orderBy("created_at")
        .limit(1)
        .get();

    if (pendingMatches.docs.isNotEmpty) {
      // Entrar em uma partida existente
      DocumentSnapshot matchDoc = pendingMatches.docs.first;
      MatchModel match = MatchModel.fromFirestore(matchDoc);

      if (match.player1Id == currentUserId) {
        // Caso raro, mas pode acontecer se a query não filtrar perfeitamente
        // ou se o usuário já criou uma partida pendente.
        // Neste caso, apenas retornamos a partida que ele já criou ou está.
        return match;
      }

      MatchModel updatedMatch = match.copyWith(
        player2Id: currentUserId,
        player2Username: currentUsername,
        status: "active",
        updatedAt: Timestamp.now(),
      );
      await _firestore.collection("matches").doc(match.id).update(updatedMatch.toFirestore());
      return updatedMatch;
    } else {
      // Criar uma nova partida pendente
      String matchId = _firestore.collection("matches").doc().id;
      MatchModel newMatch = MatchModel(
        id: matchId,
        player1Id: currentUserId,
        player1Username: currentUsername,
        player2Id: null,
        player2Username: null,
        status: "pending_random",
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        isFriendMatch: false,
        // Outros campos iniciais como scores, current_turn podem ser definidos aqui ou quando o jogo começar
        scores: {currentUserId: 0},
      );
      await _firestore.collection("matches").doc(matchId).set(newMatch.toFirestore());
      return newMatch;
    }
  }

  // Convidar um amigo para uma partida
  Future<MatchModel?> inviteFriendToMatch(String friendId, String friendUsername) async {
    if (currentUser == null) throw Exception("Usuário não autenticado.");
    // TODO: Verificar se friendId é realmente um amigo ou um usuário válido

    final String currentUserId = currentUser!.uid;
    final String? currentUsername = currentUser!.displayName ?? currentUser!.email;

    String matchId = _firestore.collection("matches").doc().id;
    MatchModel newMatch = MatchModel(
      id: matchId,
      player1Id: currentUserId,
      player1Username: currentUsername,
      player2Id: null, // Será preenchido quando o amigo aceitar
      player2Username: null,
      invitedFriendId: friendId,
      status: "pending_friend_invite",
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      isFriendMatch: true,
      scores: {currentUserId: 0},
    );
    await _firestore.collection("matches").doc(matchId).set(newMatch.toFirestore());
    // TODO: Enviar notificação/convite para o friendId
    return newMatch;
  }

  // Aceitar convite de amigo
  Future<MatchModel?> acceptFriendInvite(String matchId) async {
    if (currentUser == null) throw Exception("Usuário não autenticado.");

    final String currentUserId = currentUser!.uid;
    final String? currentUsername = currentUser!.displayName ?? currentUser!.email;

    DocumentSnapshot matchDoc = await _firestore.collection("matches").doc(matchId).get();
    if (!matchDoc.exists) throw Exception("Partida não encontrada.");

    MatchModel match = MatchModel.fromFirestore(matchDoc);
    if (match.status != "pending_friend_invite" || match.invitedFriendId != currentUserId) {
      throw Exception("Não é possível aceitar este convite.");
    }

    MatchModel updatedMatch = match.copyWith(
      player2Id: currentUserId,
      player2Username: currentUsername,
      status: "active",
      updatedAt: Timestamp.now(),
      scores: {...match.scores, currentUserId: 0}, // Adiciona score para o jogador 2
    );
    await _firestore.collection("matches").doc(match.id).update(updatedMatch.toFirestore());
    return updatedMatch;
  }

  // Recusar convite de amigo ou cancelar partida pendente
  Future<void> cancelOrDeclineMatch(String matchId) async {
    if (currentUser == null) throw Exception("Usuário não autenticado.");
    // TODO: Adicionar lógica para verificar se o usuário tem permissão para cancelar/recusar
    // (ex: é player1 de uma pending_random, ou invited_friend_id de uma pending_friend_invite)
    await _firestore.collection("matches").doc(matchId).update({
      "status": "cancelled",
      "updated_at": Timestamp.now(),
    });
  }

  // Stream para ouvir atualizações de uma partida específica
  Stream<MatchModel?> getMatchStream(String matchId) {
    return _firestore
        .collection("matches")
        .doc(matchId)
        .snapshots()
        .map((doc) => doc.exists ? MatchModel.fromFirestore(doc) : null);
  }

  // Stream para ouvir convites pendentes para o usuário atual
  Stream<List<MatchModel>> getPendingInvitesStream() {
    if (currentUser == null) return Stream.value([]);
    return _firestore
        .collection("matches")
        .where("status", isEqualTo: "pending_friend_invite")
        .where("invited_friend_id", isEqualTo: currentUser!.uid)
        .orderBy("created_at", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MatchModel.fromFirestore(doc)).toList());
  }
  
  // Método para atualizar dados da partida
  Future<void> updateMatchData(String matchId, Map<String, dynamic> data) async {
    await _firestore.collection("matches").doc(matchId).update(data);
  }
}
