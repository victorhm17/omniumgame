import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "dart:async"; // Adicionado import para StreamSubscription
import "package:cloud_firestore/cloud_firestore.dart"; // Adicionado import para Firestore
import "package:omnium_game/core/models/user_model.dart";
import "package:omnium_game/features/reputation/repositories/reputation_repository.dart";

part "reputation_state.dart";

class ReputationCubit extends Cubit<ReputationState> {
  final ReputationRepository _reputationRepository;
  StreamSubscription<UserModel?>? _userReputationSubscription; // Corrigido de Stream para StreamSubscription

  ReputationCubit({required ReputationRepository reputationRepository})
      : _reputationRepository = reputationRepository,
        super(ReputationInitial());

  void loadUserReputation(String userId) async {
    emit(ReputationLoading());
    _userReputationSubscription?.cancel();
    _userReputationSubscription = _reputationRepository.getUserReputationStream(userId).listen(
      (userModel) {
        if (userModel != null) {
          emit(ReputationLoaded(user: userModel));
        } else {
          emit(const ReputationError(message: "Usuário não encontrado."));
        }
      },
      onError: (error) {
        emit(ReputationError(message: "Erro ao carregar reputação: ${error.toString()}"));
      },
    );
  }

  // Este método seria chamado internamente ou por outros serviços após certas ações.
  // Por exemplo, após o PhotoChallengesCubit confirmar que um desafio foi pulado.
  Future<void> userSkippedChallenge(String userId) async {
    // O estado de loading/success/error para esta ação específica pode ser mais granular
    // ou pode-se simplesmente recarregar a reputação após a atualização.
    try {
      await _reputationRepository.updateUserReputationOnChallengeSkipped(userId);
      // Recarregar os dados do usuário para refletir a mudança
      // Se já houver uma subscrição ativa para este usuário, ela deve pegar a mudança.
      // Se não, pode ser necessário chamar loadUserReputation(userId) explicitamente
      // ou garantir que a UI esteja ouvindo o stream correto.
    } catch (e) {
      // Lidar com erro, talvez emitir um estado de erro específico para esta operação
      print("Erro no Cubit ao processar pulo de desafio: $e");
    }
  }

 Future<void> userCompletedChallenge(String userId) async {
    try {
      await _reputationRepository.updateUserReputationOnChallengeCompleted(userId);
    } catch (e) {
      print("Erro no Cubit ao processar conclusão de desafio: $e");
    }
  }

  Future<void> userPlayedMatch(String userId, {bool won = false}) async {
    try {
      await _reputationRepository.updateUserMatchStats(userId, won: won);
    } catch (e) {
      print("Erro no Cubit ao atualizar estatísticas de partida: $e");
    }
  }


  @override
  Future<void> close() {
    _userReputationSubscription?.cancel();
    return super.close();
  }
}

// Adicionar ao ReputationRepository, se não existir:
extension ReputationRepositoryStream on ReputationRepository {
  Stream<UserModel?> getUserReputationStream(String userId) {
    return FirebaseFirestore.instance.collection("users").doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }
}
