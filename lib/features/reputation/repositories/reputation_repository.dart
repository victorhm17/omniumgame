import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:omnium_game/core/models/user_model.dart";

class ReputationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  ReputationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserModel?> getUserReputation(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("users").doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Erro ao buscar reputação do usuário: $e");
      throw Exception("Falha ao carregar dados do usuário.");
    }
  }

  // Chamado quando um desafio é pulado
  Future<void> updateUserReputationOnChallengeSkipped(String userId) async {
    if (currentUser == null || currentUser!.uid != userId) {
      // Apenas o próprio usuário (ou o sistema via Cloud Function) deveria poder atualizar isso diretamente.
      // Para este exemplo, vamos permitir se o userId corresponder ao currentUser.
      // Idealmente, isso seria uma Cloud Function acionada pelo status do desafio.
      print("Tentativa de atualizar reputação para usuário diferente do logado ou não logado.");
      // throw Exception("Não autorizado a atualizar reputação para este usuário.");
      // Por ora, para simplificar o fluxo do agente, vamos permitir a chamada se o userId for fornecido.
    }

    DocumentReference userDocRef = _firestore.collection("users").doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDocRef);
        if (!snapshot.exists) {
          throw Exception("Usuário não encontrado para atualizar reputação.");
        }

        UserModel user = UserModel.fromFirestore(snapshot);
        int newSkippedCount = user.challengesSkippedCount + 1;
        String newReputationStatus = user.reputationStatus;

        // Lógica de exemplo para definir "Jogador Evasivo"
        if (newSkippedCount >= 3) { // Limite de exemplo
          newReputationStatus = "Jogador Evasivo";
        }
        // TODO: Adicionar lógica para outros status de reputação (ex: "Confiável")

        transaction.update(userDocRef, {
          "challenges_skipped_count": newSkippedCount,
          "reputation_status": newReputationStatus,
          "last_reputation_update": Timestamp.now(),
        });
      });
    } catch (e) {
      print("Erro ao atualizar reputação (desafio pulado): $e");
      throw Exception("Falha ao atualizar reputação após pular desafio.");
    }
  }

  // Chamado quando um desafio é completado (foto enviada)
  Future<void> updateUserReputationOnChallengeCompleted(String userId) async {
     if (currentUser == null || currentUser!.uid != userId) {
      print("Tentativa de atualizar reputação para usuário diferente do logado ou não logado.");
      // Por ora, para simplificar o fluxo do agente, vamos permitir a chamada se o userId for fornecido.
    }
    DocumentReference userDocRef = _firestore.collection("users").doc(userId);

    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDocRef);
        if (!snapshot.exists) {
          throw Exception("Usuário não encontrado para atualizar reputação.");
        }

        UserModel user = UserModel.fromFirestore(snapshot);
        int newCompletedCount = user.challengesCompletedCount + 1;
        String newReputationStatus = user.reputationStatus;

        // Lógica de exemplo para potencialmente melhorar a reputação
        if (user.reputationStatus == "Jogador Evasivo" && newCompletedCount > user.challengesSkippedCount) {
           // Exemplo: Se era evasivo mas começou a completar mais do que pular
           // newReputationStatus = "Normal"; // Ou alguma lógica mais elaborada
        }
        // TODO: Adicionar lógica para outros status de reputação (ex: "Confiável")

        transaction.update(userDocRef, {
          "challenges_completed_count": newCompletedCount,
          // "reputation_status": newReputationStatus, // Descomentar se a lógica acima for usada
          "last_reputation_update": Timestamp.now(),
        });
      });
    } catch (e) {
      print("Erro ao atualizar reputação (desafio completo): $e");
      throw Exception("Falha ao atualizar reputação após completar desafio.");
    }
  }
  
  // Atualizar contagem de partidas jogadas e ganhas
  Future<void> updateUserMatchStats(String userId, {bool won = false}) async {
    DocumentReference userDocRef = _firestore.collection("users").doc(userId);
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDocRef);
        if (!snapshot.exists) {
          throw Exception("Usuário não encontrado para atualizar estatísticas de partida.");
        }
        UserModel user = UserModel.fromFirestore(snapshot);
        int newMatchesPlayed = user.matchesPlayed + 1;
        int newMatchesWon = user.matchesWon + (won ? 1 : 0);

        transaction.update(userDocRef, {
          "matches_played": newMatchesPlayed,
          "matches_won": newMatchesWon,
        });
      });
    } catch (e) {
      print("Erro ao atualizar estatísticas de partida: $e");
      throw Exception("Falha ao atualizar estatísticas de partida.");
    }
  }

  // Método para criar o documento do usuário no Firestore quando ele se registra
  // (chamado pelo AuthRepository após o registro bem-sucedido)
  Future<void> createUserReputationProfile(String userId, String? email, String? displayName) async {
    UserModel newUser = UserModel(
      id: userId,
      email: email,
      displayName: displayName,
      createdAt: Timestamp.now(),
      // Outros campos com valores padrão já estão no construtor do UserModel
    );
    try {
      await _firestore.collection("users").doc(userId).set(newUser.toFirestore());
    } catch (e) {
      print("Erro ao criar perfil de reputação do usuário: $e");
      throw Exception("Falha ao criar perfil de reputação do usuário.");
    }
  }
}

