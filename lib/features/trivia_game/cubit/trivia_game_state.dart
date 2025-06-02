part of "trivia_game_cubit.dart";

abstract class TriviaGameState extends Equatable {
  const TriviaGameState();

  @override
  List<Object?> get props => [];
}

class TriviaGameInitial extends TriviaGameState {}

class TriviaGameLoading extends TriviaGameState {}

class TriviaGameQuestionLoaded extends TriviaGameState {
  final QuestionModel question;
  final int questionNumber;
  final int totalQuestions;
  final MatchModel match; // Para exibir placares, etc.

  const TriviaGameQuestionLoaded({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.match,
  });

  @override
  List<Object?> get props => [question, questionNumber, totalQuestions, match];
}

// Estado enquanto a resposta do usuário está sendo processada
class TriviaGameAnswerProcessing extends TriviaGameState {
  final QuestionModel question;
  final int selectedOptionIndex;
  final MatchModel match;

  const TriviaGameAnswerProcessing({
    required this.question,
    required this.selectedOptionIndex,
    required this.match,
  });

  @override
  List<Object?> get props => [question, selectedOptionIndex, match];
}

// Estado após a resposta ser processada, mostrando se foi correta ou não
class TriviaGameAnswerResult extends TriviaGameState {
  final QuestionModel question;
  final int selectedOptionIndex;
  final bool isCorrect;
  final MatchModel match; // Match atualizado com novo score
  final int questionNumber; // Adicionado para manter consistência com TriviaGameQuestionLoaded
  final int totalQuestions; // Adicionado para manter consistência com TriviaGameQuestionLoaded

  const TriviaGameAnswerResult({
    required this.question,
    required this.selectedOptionIndex,
    required this.isCorrect,
    required this.match,
    required this.questionNumber,
    required this.totalQuestions,
  });

  @override
  List<Object?> get props => [question, selectedOptionIndex, isCorrect, match, questionNumber, totalQuestions];
}

class TriviaGameFinished extends TriviaGameState {
  final MatchModel match; // Match finalizado com vencedor
  final String message;

  const TriviaGameFinished({required this.match, required this.message});

  @override
  List<Object?> get props => [match, message];
}

class TriviaGameError extends TriviaGameState {
  final String message;

  const TriviaGameError({required this.message});

  @override
  List<Object?> get props => [message];
}
