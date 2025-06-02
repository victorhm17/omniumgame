part of "bot_game_cubit.dart";

abstract class BotGameState extends Equatable {
  const BotGameState();

  @override
  List<Object?> get props => [];
}

class BotGameInitial extends BotGameState {}

class BotGameLoading extends BotGameState {}

class BotGameQuestionLoaded extends BotGameState {
  final QuestionModel question;
  final int questionNumber;
  final int totalQuestions;
  final int playerScore;
  final int botScore;
  final BotPlayer botPlayer;
  final bool playerHasAnswered;
  final bool botHasAnswered;
  final int? playerSelectedOption;
  final int? botSelectedOption;
  final int? playerResponseTime;
  final int? botResponseTime;

  const BotGameQuestionLoaded({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.playerScore,
    required this.botScore,
    required this.botPlayer,
    this.playerHasAnswered = false,
    this.botHasAnswered = false,
    this.playerSelectedOption,
    this.botSelectedOption,
    this.playerResponseTime,
    this.botResponseTime,
  });

  @override
  List<Object?> get props => [
        question,
        questionNumber,
        totalQuestions,
        playerScore,
        botScore,
        botPlayer,
        playerHasAnswered,
        botHasAnswered,
        playerSelectedOption,
        botSelectedOption,
        playerResponseTime,
        botResponseTime,
      ];

  BotGameQuestionLoaded copyWith({
    QuestionModel? question,
    int? questionNumber,
    int? totalQuestions,
    int? playerScore,
    int? botScore,
    BotPlayer? botPlayer,
    bool? playerHasAnswered,
    bool? botHasAnswered,
    int? playerSelectedOption,
    int? botSelectedOption,
    int? playerResponseTime,
    int? botResponseTime,
  }) {
    return BotGameQuestionLoaded(
      question: question ?? this.question,
      questionNumber: questionNumber ?? this.questionNumber,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      playerScore: playerScore ?? this.playerScore,
      botScore: botScore ?? this.botScore,
      botPlayer: botPlayer ?? this.botPlayer,
      playerHasAnswered: playerHasAnswered ?? this.playerHasAnswered,
      botHasAnswered: botHasAnswered ?? this.botHasAnswered,
      playerSelectedOption: playerSelectedOption ?? this.playerSelectedOption,
      botSelectedOption: botSelectedOption ?? this.botSelectedOption,
      playerResponseTime: playerResponseTime ?? this.playerResponseTime,
      botResponseTime: botResponseTime ?? this.botResponseTime,
    );
  }

  bool get bothPlayersAnswered => playerHasAnswered && botHasAnswered;
}

class BotGameQuestionResult extends BotGameState {
  final QuestionModel question;
  final int questionNumber;
  final int totalQuestions;
  final int playerScore;
  final int botScore;
  final BotPlayer botPlayer;
  final int playerSelectedOption;
  final int botSelectedOption;
  final int playerResponseTime;
  final int botResponseTime;
  final bool playerIsCorrect;
  final bool botIsCorrect;

  const BotGameQuestionResult({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.playerScore,
    required this.botScore,
    required this.botPlayer,
    required this.playerSelectedOption,
    required this.botSelectedOption,
    required this.playerResponseTime,
    required this.botResponseTime,
    required this.playerIsCorrect,
    required this.botIsCorrect,
  });

  @override
  List<Object?> get props => [
        question,
        questionNumber,
        totalQuestions,
        playerScore,
        botScore,
        botPlayer,
        playerSelectedOption,
        botSelectedOption,
        playerResponseTime,
        botResponseTime,
        playerIsCorrect,
        botIsCorrect,
      ];
}

class BotGameFinished extends BotGameState {
  final int playerScore;
  final int botScore;
  final BotPlayer botPlayer;
  final String result;
  final int totalQuestions;

  const BotGameFinished({
    required this.playerScore,
    required this.botScore,
    required this.botPlayer,
    required this.result,
    required this.totalQuestions,
  });

  @override
  List<Object?> get props => [
        playerScore,
        botScore,
        botPlayer,
        result,
        totalQuestions,
      ];
}

class BotGameError extends BotGameState {
  final String message;

  const BotGameError({required this.message});

  @override
  List<Object?> get props => [message];
}

