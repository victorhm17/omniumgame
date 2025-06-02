part of "reputation_cubit.dart";

abstract class ReputationState extends Equatable {
  const ReputationState();

  @override
  List<Object?> get props => [];
}

class ReputationInitial extends ReputationState {}

class ReputationLoading extends ReputationState {}

class ReputationLoaded extends ReputationState {
  final UserModel user;
  const ReputationLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class ReputationError extends ReputationState {
  final String message;
  const ReputationError({required this.message});

  @override
  List<Object?> get props => [message];
}

