import "dart:typed_data";
import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "dart:async"; // Adicionado import para StreamSubscription
import "package:cloud_firestore/cloud_firestore.dart"; // Adicionado import para Firestore
import "package:omnium_game/core/models/challenge_model.dart";
import "package:omnium_game/features/photo_challenges/repositories/photo_challenges_repository.dart";

part "photo_challenges_state.dart";

class PhotoChallengesCubit extends Cubit<PhotoChallengesState> {
  final PhotoChallengesRepository _challengesRepository;
  StreamSubscription<List<PhotoChallengeModel>>? _pendingChallengesSubscription; // Corrigido de Stream para StreamSubscription
  StreamSubscription<PhotoChallengeModel?>? _activeChallengeSubscription; // Corrigido de Stream para StreamSubscription

  PhotoChallengesCubit({required PhotoChallengesRepository challengesRepository})
      : _challengesRepository = challengesRepository,
        super(PhotoChallengesInitial()) {
    loadPendingChallengesForCurrentUser();
  }

  void loadChallengeTypes() async {
    emit(PhotoChallengesLoadingTypes());
    try {
      final types = await _challengesRepository.getChallengeTypes();
      emit(PhotoChallengeTypesLoaded(types: types));
    } catch (e) {
      emit(PhotoChallengesError(message: "Erro ao carregar tipos de desafio: ${e.toString()}"));
    }
  }

  void createChallenge({
    required String matchId,
    required String chosenChallengeTypeId,
    required String chosenChallengeTypeName,
    required String challengerId, // Vencedor do trivia
    required String challengedId, // Perdedor do trivia
  }) async {
    emit(PhotoChallengeCreating());
    try {
      final challenge = await _challengesRepository.createPhotoChallenge(
        matchId: matchId,
        chosenChallengeTypeId: chosenChallengeTypeId,
        chosenChallengeTypeName: chosenChallengeTypeName,
        challengerId: challengerId,
        challengedId: challengedId,
      );
      emit(PhotoChallengeCreated(challenge: challenge));
      // O desafiado verá este desafio através do `loadPendingChallengesForCurrentUser`
      // O desafiador pode querer ver o status do desafio que ele criou.
      subscribeToChallengeUpdates(challenge.id);
    } catch (e) {
      emit(PhotoChallengesError(message: "Erro ao criar desafio: ${e.toString()}"));
    }
  }

  void loadPendingChallengesForCurrentUser() async {
    if (_challengesRepository.currentUser == null) {
      emit(PhotoChallengesInitial()); // Ou um estado de "não autenticado"
      return;
    }
    emit(PhotoChallengesLoadingPending());
    _pendingChallengesSubscription?.cancel();
    _pendingChallengesSubscription = _challengesRepository
        .getPendingChallengesForCurrentUserStream() // Assumindo que existe um stream no repo
        .listen((challenges) {
      emit(PhotoChallengesPendingLoaded(challenges: challenges));
    }, onError: (error) {
      emit(PhotoChallengesError(message: "Erro ao carregar desafios pendentes: ${error.toString()}"));
    });
  }
  
  // Método para buscar desafios pendentes uma única vez (se não usar stream)
  void fetchPendingChallengesOnce() async {
     if (_challengesRepository.currentUser == null) {
      emit(PhotoChallengesInitial());
      return;
    }
    emit(PhotoChallengesLoadingPending());
    try {
      final challenges = await _challengesRepository.getPendingChallengesForCurrentUser();
      emit(PhotoChallengesPendingLoaded(challenges: challenges));
    } catch (e) {
       emit(PhotoChallengesError(message: "Erro ao buscar desafios pendentes: ${e.toString()}"));
    }
  }

  void submitPhoto({
    required String challengeId,
    required Uint8List photoBytes,
    required String fileName,
  }) async {
    emit(PhotoChallengeSubmitting(challengeId: challengeId));
    try {
      final updatedChallenge = await _challengesRepository.submitPhotoForChallenge(
        challengeId: challengeId,
        photoBytes: photoBytes,
        fileName: fileName,
      );
      emit(PhotoChallengeSubmitted(challenge: updatedChallenge));
    } catch (e) {
      emit(PhotoChallengesError(message: "Erro ao enviar foto: ${e.toString()}"));
    }
  }

  void skipChallenge(String challengeId) async {
    emit(PhotoChallengeSkipping(challengeId: challengeId));
    try {
      final updatedChallenge = await _challengesRepository.skipChallenge(challengeId);
      // TODO: Disparar evento/lógica para atualizar reputação do usuário
      emit(PhotoChallengeSkipped(challenge: updatedChallenge));
    } catch (e) {
      emit(PhotoChallengesError(message: "Erro ao pular desafio: ${e.toString()}"));
    }
  }

  void subscribeToChallengeUpdates(String challengeId) {
    _activeChallengeSubscription?.cancel();
    _activeChallengeSubscription = _challengesRepository.getChallengeStream(challengeId).listen((challenge) {
      if (challenge != null) {
        // Emitir um estado genérico de atualização ou estados específicos baseados no status do desafio
        emit(PhotoChallengeStatusUpdate(challenge: challenge));
      } else {
        // Desafio não encontrado ou deletado
        // Poderia emitir um erro ou voltar para um estado inicial
      }
    }, onError: (error) {
      emit(PhotoChallengesError(message: "Erro ao ouvir atualizações do desafio: ${error.toString()}"));
    });
  }

  @override
  Future<void> close() {
    _pendingChallengesSubscription?.cancel();
    _activeChallengeSubscription?.cancel();
    return super.close();
  }
}

// Adicionar ao repositório, se não existir:
extension PhotoChallengesRepositoryStream on PhotoChallengesRepository {
  Stream<List<PhotoChallengeModel>> getPendingChallengesForCurrentUserStream() {
    if (currentUser == null) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection("photo_challenges")
        .where("challenged_id", isEqualTo: currentUser!.uid)
        .where("status", isEqualTo: "pending_submission")
        .orderBy("created_at", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PhotoChallengeModel.fromFirestore(doc))
            .toList());
  }
}
