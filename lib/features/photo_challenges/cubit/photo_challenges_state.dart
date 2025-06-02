part of "photo_challenges_cubit.dart";

abstract class PhotoChallengesState extends Equatable {
  const PhotoChallengesState();

  @override
  List<Object?> get props => [];
}

class PhotoChallengesInitial extends PhotoChallengesState {}

class PhotoChallengesLoadingTypes extends PhotoChallengesState {}

class PhotoChallengeTypesLoaded extends PhotoChallengesState {
  final List<ChallengeTypeModel> types;
  const PhotoChallengeTypesLoaded({required this.types});
  @override
  List<Object?> get props => [types];
}

class PhotoChallengeCreating extends PhotoChallengesState {}

class PhotoChallengeCreated extends PhotoChallengesState {
  final PhotoChallengeModel challenge;
  const PhotoChallengeCreated({required this.challenge});
  @override
  List<Object?> get props => [challenge];
}

class PhotoChallengesLoadingPending extends PhotoChallengesState {}

class PhotoChallengesPendingLoaded extends PhotoChallengesState {
  final List<PhotoChallengeModel> challenges;
  const PhotoChallengesPendingLoaded({required this.challenges});
  @override
  List<Object?> get props => [challenges];
}

class PhotoChallengeSubmitting extends PhotoChallengesState {
  final String challengeId;
  const PhotoChallengeSubmitting({required this.challengeId});
   @override
  List<Object?> get props => [challengeId];
}

class PhotoChallengeSubmitted extends PhotoChallengesState {
  final PhotoChallengeModel challenge;
  const PhotoChallengeSubmitted({required this.challenge});
  @override
  List<Object?> get props => [challenge];
}

class PhotoChallengeSkipping extends PhotoChallengesState {
  final String challengeId;
  const PhotoChallengeSkipping({required this.challengeId});
   @override
  List<Object?> get props => [challengeId];
}

class PhotoChallengeSkipped extends PhotoChallengesState {
  final PhotoChallengeModel challenge;
  const PhotoChallengeSkipped({required this.challenge});
  @override
  List<Object?> get props => [challenge];
}

// Estado genérico para quando um desafio específico é atualizado (via stream)
class PhotoChallengeStatusUpdate extends PhotoChallengesState {
  final PhotoChallengeModel challenge;
  const PhotoChallengeStatusUpdate({required this.challenge});
  @override
  List<Object?> get props => [challenge];
}

class PhotoChallengesError extends PhotoChallengesState {
  final String message;
  const PhotoChallengesError({required this.message});
  @override
  List<Object?> get props => [message];
}

