import "package:cloud_firestore/cloud_firestore.dart";
import "package:equatable/equatable.dart";

class ChallengeTypeModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;

  const ChallengeTypeModel({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
  });

  @override
  List<Object?> get props => [id, name, description, iconUrl];

  factory ChallengeTypeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChallengeTypeModel(
      id: doc.id,
      name: data["name"] ?? "Desafio Desconhecido",
      description: data["description"],
      iconUrl: data["icon_url"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      if (description != null) "description": description,
      if (iconUrl != null) "icon_url": iconUrl,
    };
  }
}

class PhotoChallengeModel extends Equatable {
  final String id; // Pode ser o matchId
  final String matchId;
  final String chosenChallengeTypeId; // ID do ChallengeTypeModel
  final String chosenChallengeTypeName; // Nome do ChallengeTypeModel para exibição rápida
  final String challengerId; // Vencedor do trivia, quem desafiou
  final String challengedId; // Perdedor do trivia, quem deve cumprir
  final String status; // "pending_submission", "submitted", "skipped", "completed"
  final String? photoUrl;
  final Timestamp? submittedAt;
  final Timestamp? skippedAt;
  final Timestamp createdAt;

  const PhotoChallengeModel({
    required this.id,
    required this.matchId,
    required this.chosenChallengeTypeId,
    required this.chosenChallengeTypeName,
    required this.challengerId,
    required this.challengedId,
    required this.status,
    this.photoUrl,
    this.submittedAt,
    this.skippedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        matchId,
        chosenChallengeTypeId,
        chosenChallengeTypeName,
        challengerId,
        challengedId,
        status,
        photoUrl,
        submittedAt,
        skippedAt,
        createdAt,
      ];

  factory PhotoChallengeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PhotoChallengeModel(
      id: doc.id,
      matchId: data["match_id"] ?? "",
      chosenChallengeTypeId: data["chosen_challenge_type_id"] ?? "",
      chosenChallengeTypeName: data["chosen_challenge_type_name"] ?? "Desafio não especificado",
      challengerId: data["challenger_id"] ?? "",
      challengedId: data["challenged_id"] ?? "",
      status: data["status"] ?? "unknown",
      photoUrl: data["photo_url"],
      submittedAt: data["submitted_at"] as Timestamp?,
      skippedAt: data["skipped_at"] as Timestamp?,
      createdAt: data["created_at"] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "match_id": matchId,
      "chosen_challenge_type_id": chosenChallengeTypeId,
      "chosen_challenge_type_name": chosenChallengeTypeName,
      "challenger_id": challengerId,
      "challenged_id": challengedId,
      "status": status,
      if (photoUrl != null) "photo_url": photoUrl,
      if (submittedAt != null) "submitted_at": submittedAt,
      if (skippedAt != null) "skipped_at": skippedAt,
      "created_at": createdAt,
    };
  }

  PhotoChallengeModel copyWith({
    String? id,
    String? matchId,
    String? chosenChallengeTypeId,
    String? chosenChallengeTypeName,
    String? challengerId,
    String? challengedId,
    String? status,
    String? photoUrl,
    Timestamp? submittedAt,
    Timestamp? skippedAt,
    Timestamp? createdAt,
  }) {
    return PhotoChallengeModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      chosenChallengeTypeId: chosenChallengeTypeId ?? this.chosenChallengeTypeId,
      chosenChallengeTypeName: chosenChallengeTypeName ?? this.chosenChallengeTypeName,
      challengerId: challengerId ?? this.challengerId,
      challengedId: challengedId ?? this.challengedId,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      submittedAt: submittedAt ?? this.submittedAt,
      skippedAt: skippedAt ?? this.skippedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

