import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "dart:async"; // Import necessário para StreamSubscription
import "package:omnium_game/core/models/match_model.dart";
import "package:omnium_game/features/matchmaking/repositories/matchmaking_repository.dart";
import "package:firebase_auth/firebase_auth.dart" as fb_auth;

part "matchmaking_state.dart";

class MatchmakingCubit extends Cubit<MatchmakingState> {
  final MatchmakingRepository _matchmakingRepository;
  // Corrigido: Tipo alterado de Stream para StreamSubscription
  StreamSubscription<List<MatchModel>>? _pendingInvitesSubscription;
  StreamSubscription<MatchModel?>? _activeMatchSubscription;

  MatchmakingCubit({required MatchmakingRepository matchmakingRepository})
      : _matchmakingRepository = matchmakingRepository,
        super(MatchmakingInitial()) {
    print("[MatchmakingCubit] Inicializado."); // Print para depuração
    _listenToPendingInvites();
  }

  void _listenToPendingInvites() {
    print("[MatchmakingCubit] Tentando ouvir convites pendentes...");
    if (_matchmakingRepository.currentUser != null) {
      // Corrigido: Atribuição correta para StreamSubscription
      _pendingInvitesSubscription = _matchmakingRepository.getPendingInvitesStream().listen((invites) {
        print("[MatchmakingCubit] Convites recebidos: ${invites.length}");
        emit(MatchmakingInvitesLoaded(invites: invites));
      }, onError: (error) {
        print("[MatchmakingCubit] Erro ao ouvir convites: $error");
        emit(MatchmakingError(message: "Erro ao carregar convites: ${error.toString()}"));
      });
    } else {
      print("[MatchmakingCubit] Usuário não logado, não é possível ouvir convites.");
    }
  }

  void findRandomMatch() async {
    print("[MatchmakingCubit] findRandomMatch chamado!"); // Print para depuração
    emit(MatchmakingLoading(message: "Procurando partida aleatória..."));
    try {
      final MatchModel? match = await _matchmakingRepository.findOrCreateRandomMatch();
      if (match != null) {
        print("[MatchmakingCubit] Partida encontrada/criada: ${match.id}, Status: ${match.status}");
        if (match.status == "active") {
          emit(MatchmakingSuccess(match: match, message: "Partida encontrada!"));
          _subscribeToMatchUpdates(match.id);
        } else if (match.status == "pending_random") {
          emit(MatchmakingLookingForOpponent(match: match, message: "Aguardando oponente..."));
          _subscribeToMatchUpdates(match.id);
        } else {
          print("[MatchmakingCubit] Status de partida inesperado: ${match.status}");
          emit(MatchmakingError(message: "Status de partida inesperado: ${match.status}"));
        }
      } else {
        print("[MatchmakingCubit] Não foi possível encontrar ou criar partida.");
        emit(const MatchmakingError(message: "Não foi possível encontrar ou criar uma partida."));
      }
    } catch (e) {
      print("[MatchmakingCubit] Erro em findRandomMatch: $e");
      emit(MatchmakingError(message: e.toString()));
    }
  }

  void inviteFriend(String friendId, String friendUsername) async {
    print("[MatchmakingCubit] inviteFriend chamado para $friendUsername ($friendId)");
    emit(MatchmakingLoading(message: "Convidando amigo..."));
    try {
      final MatchModel? match = await _matchmakingRepository.inviteFriendToMatch(friendId, friendUsername);
      if (match != null) {
        print("[MatchmakingCubit] Convite enviado, match ID: ${match.id}");
        emit(MatchmakingInviteSent(match: match, message: "Convite enviado para $friendUsername!"));
        _subscribeToMatchUpdates(match.id); // O criador também ouve a partida
      } else {
        print("[MatchmakingCubit] Falha ao enviar convite.");
        emit(const MatchmakingError(message: "Não foi possível enviar o convite."));
      }
    } catch (e) {
      print("[MatchmakingCubit] Erro em inviteFriend: $e");
      emit(MatchmakingError(message: e.toString()));
    }
  }

  void acceptInvite(String matchId) async {
    print("[MatchmakingCubit] acceptInvite chamado para match $matchId");
    emit(MatchmakingLoading(message: "Aceitando convite..."));
    try {
      final MatchModel? match = await _matchmakingRepository.acceptFriendInvite(matchId);
      if (match != null && match.status == "active") {
        print("[MatchmakingCubit] Convite aceito, partida iniciada: ${match.id}");
        emit(MatchmakingSuccess(match: match, message: "Convite aceito! Partida iniciada."));
        _subscribeToMatchUpdates(match.id);
      } else {
        print("[MatchmakingCubit] Falha ao aceitar convite ou partida não ativa.");
        emit(const MatchmakingError(message: "Não foi possível aceitar o convite ou iniciar a partida."));
      }
    } catch (e) {
      print("[MatchmakingCubit] Erro em acceptInvite: $e");
      emit(MatchmakingError(message: e.toString()));
    }
  }

  void declineOrCancelMatch(String matchId) async {
    print("[MatchmakingCubit] declineOrCancelMatch chamado para match $matchId");
    try {
      await _matchmakingRepository.cancelOrDeclineMatch(matchId);
      print("[MatchmakingCubit] Partida $matchId cancelada/recusada.");
      emit(MatchmakingInitial());
      _listenToPendingInvites();
    } catch (e) {
      print("[MatchmakingCubit] Erro em declineOrCancelMatch: $e");
      emit(MatchmakingError(message: "Erro ao cancelar/recusar partida: ${e.toString()}"));
    }
  }

  void _subscribeToMatchUpdates(String matchId) {
    print("[MatchmakingCubit] Assinando atualizações para match $matchId");
    _activeMatchSubscription?.cancel();
    // Corrigido: Atribuição correta para StreamSubscription
    _activeMatchSubscription = _matchmakingRepository.getMatchStream(matchId).listen((match) {
      if (match != null) {
        print("[MatchmakingCubit] Atualização recebida para match ${match.id}, Status: ${match.status}");
        if (match.status == "active" && match.player2Id != null) {
          if (state is! MatchmakingSuccess || (state as MatchmakingSuccess).match.id != match.id) {
             emit(MatchmakingSuccess(match: match, message: "Partida em andamento."));
          }
        } else if (match.status == "pending_random" && state is! MatchmakingLookingForOpponent) {
          emit(MatchmakingLookingForOpponent(match: match, message: "Ainda aguardando oponente..."));
        } else if (match.status == "pending_friend_invite" && state is! MatchmakingInviteSent) {
          // Estado específico para convite pendente
        } else if (match.status == "completed") {
          emit(MatchmakingCompleted(match: match, message: "Partida finalizada."));
          _activeMatchSubscription?.cancel();
        } else if (match.status == "cancelled") {
          emit(MatchmakingCancelled(matchId: match.id, message: "Partida cancelada."));
          _activeMatchSubscription?.cancel();
        }
      } else {
        print("[MatchmakingCubit] Partida $matchId não encontrada ou deletada.");
        emit(MatchmakingInitial());
        _activeMatchSubscription?.cancel();
      }
    }, onError: (error) {
      print("[MatchmakingCubit] Erro ao ouvir atualizações da partida $matchId: $error");
      emit(MatchmakingError(message: "Erro ao ouvir atualizações da partida: ${error.toString()}"));
    });
  }
  
  void clearMatchSubscription() {
    print("[MatchmakingCubit] Limpando assinatura de partida ativa.");
    _activeMatchSubscription?.cancel();
    _activeMatchSubscription = null;
    if (state is MatchmakingSuccess || state is MatchmakingLookingForOpponent || state is MatchmakingCompleted || state is MatchmakingCancelled) {
        _listenToPendingInvites();
    }
  }

  @override
  Future<void> close() {
    print("[MatchmakingCubit] Fechando Cubit e cancelando assinaturas.");
    _pendingInvitesSubscription?.cancel();
    _activeMatchSubscription?.cancel();
    return super.close();
  }
}

