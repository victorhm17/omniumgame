part of "matchmaking_cubit.dart";

abstract class MatchmakingState extends Equatable {
  const MatchmakingState();

  @override
  List<Object?> get props => [];
}

class MatchmakingInitial extends MatchmakingState {}

class MatchmakingLoading extends MatchmakingState {
  final String message;
  const MatchmakingLoading({required this.message});
  @override
  List<Object?> get props => [message];
}

// Estado quando o jogador está aguardando um oponente aleatório se juntar à partida criada por ele
class MatchmakingLookingForOpponent extends MatchmakingState {
  final MatchModel match;
  final String message;
  const MatchmakingLookingForOpponent({required this.match, required this.message});
  @override
  List<Object?> get props => [match, message];
}

// Estado quando um convite para amigo foi enviado
class MatchmakingInviteSent extends MatchmakingState {
  final MatchModel match;
  final String message;
  const MatchmakingInviteSent({required this.match, required this.message});
  @override
  List<Object?> get props => [match, message];
}

// Estado quando uma partida (aleatória ou de amigo) foi formada com sucesso e está ativa
class MatchmakingSuccess extends MatchmakingState {
  final MatchModel match;
  final String message;
  const MatchmakingSuccess({required this.match, required this.message});
  @override
  List<Object?> get props => [match, message];
}

// Estado para exibir convites pendentes recebidos pelo usuário
class MatchmakingInvitesLoaded extends MatchmakingState {
  final List<MatchModel> invites;
  const MatchmakingInvitesLoaded({required this.invites});
  @override
  List<Object?> get props => [invites];
}

class MatchmakingCompleted extends MatchmakingState {
  final MatchModel match;
  final String message;
  const MatchmakingCompleted({required this.match, required this.message});
  @override
  List<Object?> get props => [match, message];
}

class MatchmakingCancelled extends MatchmakingState {
  final String matchId;
  final String message;
  const MatchmakingCancelled({required this.matchId, required this.message});
  @override
  List<Object?> get props => [matchId, message];
}

class MatchmakingError extends MatchmakingState {
  final String message;
  const MatchmakingError({required this.message});
  @override
  List<Object?> get props => [message];
}

