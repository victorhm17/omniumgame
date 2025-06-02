import "package:cloud_firestore/cloud_firestore.dart";
import "package:equatable/equatable.dart";

class MatchModel extends Equatable {
  final String id;
  final String player1Id;
  final String? player1Username;
  final String? player2Id;
  final String? player2Username;
  final String? invitedFriendId; // UID do amigo convidado
  final String status; // "pending_random", "pending_friend_invite", "active", "completed", "cancelled"
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final bool isFriendMatch;
  final String? currentTurn; // UID do jogador da vez
  final List<Map<String, dynamic>>? questions; // Lista de perguntas ou IDs
  final Map<String, int> scores; // Scores dos jogadores
  final String? winnerId;
  final int? currentQuestionIndex; // Adicionado para rastrear o índice da pergunta atual

  const MatchModel({
    required this.id,
    required this.player1Id,
    this.player1Username,
    this.player2Id,
    this.player2Username,
    this.invitedFriendId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isFriendMatch,
    this.currentTurn,
    this.questions,
    required this.scores,
    this.winnerId,
    this.currentQuestionIndex, // Adicionado ao construtor
  });

  @override
  List<Object?> get props => [
        id,
        player1Id,
        player1Username,
        player2Id,
        player2Username,
        invitedFriendId,
        status,
        createdAt,
        updatedAt,
        isFriendMatch,
        currentTurn,
        questions,
        scores,
        winnerId,
        currentQuestionIndex, // Adicionado à lista de props
      ];

  MatchModel copyWith({
    String? id,
    String? player1Id,
    String? player1Username,
    String? player2Id,
    String? player2Username,
    String? invitedFriendId,
    String? status,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool? isFriendMatch,
    String? currentTurn,
    List<Map<String, dynamic>>? questions,
    Map<String, int>? scores,
    String? winnerId,
    int? currentQuestionIndex, // Adicionado ao método copyWith
  }) {
    return MatchModel(
      id: id ?? this.id,
      player1Id: player1Id ?? this.player1Id,
      player1Username: player1Username ?? this.player1Username,
      player2Id: player2Id ?? this.player2Id,
      player2Username: player2Username ?? this.player2Username,
      invitedFriendId: invitedFriendId ?? this.invitedFriendId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFriendMatch: isFriendMatch ?? this.isFriendMatch,
      currentTurn: currentTurn ?? this.currentTurn,
      questions: questions ?? this.questions,
      scores: scores ?? this.scores,
      winnerId: winnerId ?? this.winnerId,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex, // Adicionado ao retorno
    );
  }

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MatchModel(
      id: doc.id,
      player1Id: data["player1_id"] ?? "",
      player1Username: data["player1_username"],
      player2Id: data["player2_id"],
      player2Username: data["player2_username"],
      invitedFriendId: data["invited_friend_id"],
      status: data["status"] ?? "unknown",
      createdAt: data["created_at"] ?? Timestamp.now(),
      updatedAt: data["updated_at"] ?? Timestamp.now(),
      isFriendMatch: data["is_friend_match"] ?? false,
      currentTurn: data["current_turn"],
      questions: data["questions"] != null 
          ? List<Map<String, dynamic>>.from(data["questions"])
          : null,
      scores: Map<String, int>.from(data["scores"] ?? {}),
      winnerId: data["winner_id"],
      currentQuestionIndex: data["current_question_index"], // Adicionado para ler do Firestore
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "player1_id": player1Id,
      if (player1Username != null) "player1_username": player1Username,
      if (player2Id != null) "player2_id": player2Id,
      if (player2Username != null) "player2_username": player2Username,
      if (invitedFriendId != null) "invited_friend_id": invitedFriendId,
      "status": status,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "is_friend_match": isFriendMatch,
      if (currentTurn != null) "current_turn": currentTurn,
      if (questions != null) "questions": questions,
      "scores": scores,
      if (winnerId != null) "winner_id": winnerId,
      if (currentQuestionIndex != null) "current_question_index": currentQuestionIndex, // Adicionado para salvar no Firestore
    };
  }
}
