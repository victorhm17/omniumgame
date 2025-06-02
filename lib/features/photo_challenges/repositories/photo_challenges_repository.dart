import "dart:typed_data";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:omnium_game/core/models/challenge_model.dart";

class PhotoChallengesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _storage;

  PhotoChallengesRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  // Buscar tipos de desafios disponíveis
  Future<List<ChallengeTypeModel>> getChallengeTypes() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("challenge_types").get();
      return snapshot.docs
          .map((doc) => ChallengeTypeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar tipos de desafios: $e");
      throw Exception("Falha ao carregar tipos de desafios.");
    }
  }

  // Criar um novo desafio de foto após o fim de uma partida
  Future<PhotoChallengeModel> createPhotoChallenge({
    required String matchId,
    required String chosenChallengeTypeId,
    required String chosenChallengeTypeName,
    required String challengerId,
    required String challengedId,
  }) async {
    try {
      // Usar o matchId como ID do desafio para fácil referência
      final String challengeId = matchId;
      
      PhotoChallengeModel challenge = PhotoChallengeModel(
        id: challengeId,
        matchId: matchId,
        chosenChallengeTypeId: chosenChallengeTypeId,
        chosenChallengeTypeName: chosenChallengeTypeName,
        challengerId: challengerId,
        challengedId: challengedId,
        status: "pending_submission",
        createdAt: Timestamp.now(),
      );

      await _firestore
          .collection("photo_challenges")
          .doc(challengeId)
          .set(challenge.toFirestore());

      return challenge;
    } catch (e) {
      print("Erro ao criar desafio de foto: $e");
      throw Exception("Falha ao criar desafio de foto.");
    }
  }

  // Buscar um desafio específico
  Future<PhotoChallengeModel?> getPhotoChallenge(String challengeId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection("photo_challenges")
          .doc(challengeId)
          .get();
      
      if (doc.exists) {
        return PhotoChallengeModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Erro ao buscar desafio de foto: $e");
      throw Exception("Falha ao carregar desafio de foto.");
    }
  }

  // Buscar desafios pendentes para o usuário atual (como desafiado)
  Future<List<PhotoChallengeModel>> getPendingChallengesForCurrentUser() async {
    if (currentUser == null) return [];
    
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("photo_challenges")
          .where("challenged_id", isEqualTo: currentUser!.uid)
          .where("status", isEqualTo: "pending_submission")
          .get();
      
      return snapshot.docs
          .map((doc) => PhotoChallengeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Erro ao buscar desafios pendentes: $e");
      throw Exception("Falha ao carregar desafios pendentes.");
    }
  }

  // Enviar foto para um desafio
  Future<PhotoChallengeModel> submitPhotoForChallenge({
    required String challengeId,
    required Uint8List photoBytes,
    required String fileName,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception("Usuário não autenticado.");
      }

      // 1. Upload da foto para o Firebase Storage
      final String storagePath = "challenge_photos/$challengeId/$fileName";
      final Reference storageRef = _storage.ref().child(storagePath);
      
      // Upload do arquivo
      await storageRef.putData(photoBytes);
      
      // Obter URL de download
      final String photoUrl = await storageRef.getDownloadURL();
      
      // 2. Atualizar o documento do desafio
      await _firestore.collection("photo_challenges").doc(challengeId).update({
        "photo_url": photoUrl,
        "status": "submitted",
        "submitted_at": Timestamp.now(),
      });
      
      // 3. Buscar o desafio atualizado
      DocumentSnapshot doc = await _firestore
          .collection("photo_challenges")
          .doc(challengeId)
          .get();
      
      return PhotoChallengeModel.fromFirestore(doc);
    } catch (e) {
      print("Erro ao enviar foto para desafio: $e");
      throw Exception("Falha ao enviar foto para o desafio.");
    }
  }

  // Pular um desafio
  Future<PhotoChallengeModel> skipChallenge(String challengeId) async {
    try {
      if (currentUser == null) {
        throw Exception("Usuário não autenticado.");
      }

      // 1. Atualizar o documento do desafio
      await _firestore.collection("photo_challenges").doc(challengeId).update({
        "status": "skipped",
        "skipped_at": Timestamp.now(),
      });
      
      // 2. Buscar o desafio atualizado
      DocumentSnapshot doc = await _firestore
          .collection("photo_challenges")
          .doc(challengeId)
          .get();
      
      // 3. Atualizar a reputação do usuário (será implementado no sistema de reputação)
      // TODO: Integrar com o sistema de reputação
      
      return PhotoChallengeModel.fromFirestore(doc);
    } catch (e) {
      print("Erro ao pular desafio: $e");
      throw Exception("Falha ao pular o desafio.");
    }
  }

  // Stream para ouvir atualizações de um desafio específico
  Stream<PhotoChallengeModel?> getChallengeStream(String challengeId) {
    return _firestore
        .collection("photo_challenges")
        .doc(challengeId)
        .snapshots()
        .map((doc) => doc.exists ? PhotoChallengeModel.fromFirestore(doc) : null);
  }
}
