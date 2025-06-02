import "package:cloud_firestore/cloud_firestore.dart";
import "package:equatable/equatable.dart";

class UserModel extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String reputationStatus; // Ex: "Normal", "Jogador Evasivo", "Confiável"
  final int challengesSkippedCount;
  final int challengesCompletedCount;
  final int matchesPlayed;
  final int matchesWon;
  final Timestamp? lastReputationUpdate;
  final Timestamp createdAt;

  const UserModel({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.reputationStatus = "Normal",
    this.challengesSkippedCount = 0,
    this.challengesCompletedCount = 0,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.lastReputationUpdate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        reputationStatus,
        challengesSkippedCount,
        challengesCompletedCount,
        matchesPlayed,
        matchesWon,
        lastReputationUpdate,
        createdAt,
      ];

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Explicit cast
    return UserModel(
      id: doc.id,
      email: data["email"],
      displayName: data["displayName"],
      photoUrl: data["photoUrl"],
      reputationStatus: data["reputation_status"] ?? "Normal",
      challengesSkippedCount: data["challenges_skipped_count"] ?? 0,
      challengesCompletedCount: data["challenges_completed_count"] ?? 0,
      matchesPlayed: data["matches_played"] ?? 0,
      matchesWon: data["matches_won"] ?? 0,
      lastReputationUpdate: data["last_reputation_update"] as Timestamp?,
      createdAt: data["createdAt"] ?? Timestamp.now(), // Default if not present
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "email": email,
      "displayName": displayName,
      "photoUrl": photoUrl,
      "reputation_status": reputationStatus,
      "challenges_skipped_count": challengesSkippedCount,
      "challenges_completed_count": challengesCompletedCount,
      "matches_played": matchesPlayed,
      "matches_won": matchesWon,
      "last_reputation_update": lastReputationUpdate,
      "createdAt": createdAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? reputationStatus,
    int? challengesSkippedCount,
    int? challengesCompletedCount,
    int? matchesPlayed,
    int? matchesWon,
    Timestamp? lastReputationUpdate,
    Timestamp? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      reputationStatus: reputationStatus ?? this.reputationStatus,
      challengesSkippedCount: challengesSkippedCount ?? this.challengesSkippedCount,
      challengesCompletedCount: challengesCompletedCount ?? this.challengesCompletedCount,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      matchesWon: matchesWon ?? this.matchesWon,
      lastReputationUpdate: lastReputationUpdate ?? this.lastReputationUpdate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

