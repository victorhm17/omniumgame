import "package:flutter_bloc/flutter_bloc.dart";
import "package:equatable/equatable.dart";
import "dart:async";
import "package:firebase_auth/firebase_auth.dart";
import "package:omnium_game/core/models/bot_player.dart";
import "package:omnium_game/core/models/question_model.dart";
import "package:omnium_game/features/trivia_game/repositories/trivia_game_repository.dart";

part "bot_game_state.dart";

class BotGameCubit extends Cubit<BotGameState> {
  final TriviaGameRepository _triviaGameRepository;
  final BotPlayer _botPlayer;

  List<QuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  int _playerScore = 0;
  int _botScore = 0;
  Timer? _botResponseTimer;

  BotGameCubit({
    required TriviaGameRepository triviaGameRepository,
    required BotPlayer botPlayer,
  })  : _triviaGameRepository = triviaGameRepository,
        _botPlayer = botPlayer,
        super(BotGameInitial());

  Future<void> startGame() async {
    emit(BotGameLoading());

    // 🔍 LOGS DE DEBUG - ADICIONE ESTAS LINHAS:
    print('🔍 DEBUG: Verificando autenticação...');
    final user = FirebaseAuth.instance.currentUser;
    print('🔍 User authenticated: ${user != null}');
    if (user != null) {
      print('🔍 User ID: ${user.uid}');
      print('🔍 User email: ${user.email}');
    } else {
      print('❌ PROBLEMA: Usuário não está autenticado!');
    }
    print('🔍 Tentando carregar perguntas...');

    try {
      // Carregar perguntas para o jogo
      _questions = await _triviaGameRepository.getQuestionsForMatch(count: 10);

      if (_questions.isEmpty) {
        emit(const BotGameError(
            message: "Nenhuma pergunta encontrada para o jogo."));
        return;
      }

      _currentQuestionIndex = 0;
      _playerScore = 0;
      _botScore = 0;

      emit(BotGameQuestionLoaded(
        question: _questions[_currentQuestionIndex],
        questionNumber: _currentQuestionIndex + 1,
        totalQuestions: _questions.length,
        playerScore: _playerScore,
        botScore: _botScore,
        botPlayer: _botPlayer,
      ));

      // Iniciar timer para resposta do bot
      _startBotResponseTimer();
    } catch (e) {
      emit(BotGameError(message: "Erro ao iniciar jogo: ${e.toString()}"));
    }
  }

  void _startBotResponseTimer() {
    if (state is! BotGameQuestionLoaded) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final optionCorrectness =
        currentQuestion.options.map((option) => option.isCorrect).toList();
    final botResponse = _botPlayer.simulateResponse(optionCorrectness);

    _botResponseTimer?.cancel();
    _botResponseTimer = Timer(
      Duration(milliseconds: botResponse.responseTimeMs),
      () => _processBotAnswer(botResponse),
    );
  }

  void _processBotAnswer(BotResponse botResponse) {
    if (state is! BotGameQuestionLoaded) return;

    // Atualizar score do bot
    if (botResponse.isCorrect) {
      _botScore += _calculateScore(botResponse.responseTimeMs);
    }

    // Se o jogador ainda não respondeu, continuar esperando
    // Se já respondeu, mostrar resultado
    if (state is BotGameQuestionLoaded) {
      final currentState = state as BotGameQuestionLoaded;
      emit(currentState.copyWith(
        botHasAnswered: true,
        botSelectedOption: botResponse.selectedOptionIndex,
        botResponseTime: botResponse.responseTimeMs,
        botScore: _botScore,
      ));
    }
  }

  Future<void> submitPlayerAnswer(int selectedOptionIndex) async {
    if (state is! BotGameQuestionLoaded) return;

    final currentState = state as BotGameQuestionLoaded;
    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = currentQuestion.options[selectedOptionIndex].isCorrect;

    // Calcular tempo de resposta do jogador (simplificado)
    const int playerResponseTime = 3000; // TODO: Implementar timer real

    // Atualizar score do jogador
    if (isCorrect) {
      _playerScore += _calculateScore(playerResponseTime);
    }

    emit(currentState.copyWith(
      playerHasAnswered: true,
      playerSelectedOption: selectedOptionIndex,
      playerResponseTime: playerResponseTime,
      playerScore: _playerScore,
    ));

    // Se o bot ainda não respondeu, aguardar
    // Se já respondeu, mostrar resultado
    if (currentState.botHasAnswered) {
      _showQuestionResult();
    }
  }

  void _showQuestionResult() {
    if (state is! BotGameQuestionLoaded) return;

    final currentState = state as BotGameQuestionLoaded;
    final currentQuestion = _questions[_currentQuestionIndex];

    emit(BotGameQuestionResult(
      question: currentQuestion,
      questionNumber: _currentQuestionIndex + 1,
      totalQuestions: _questions.length,
      playerScore: _playerScore,
      botScore: _botScore,
      botPlayer: _botPlayer,
      playerSelectedOption: currentState.playerSelectedOption!,
      botSelectedOption: currentState.botSelectedOption!,
      playerResponseTime: currentState.playerResponseTime!,
      botResponseTime: currentState.botResponseTime!,
      playerIsCorrect:
          currentQuestion.options[currentState.playerSelectedOption!].isCorrect,
      botIsCorrect:
          currentQuestion.options[currentState.botSelectedOption!].isCorrect,
    ));
  }

  void proceedToNextQuestion() {
    _botResponseTimer?.cancel();
    _currentQuestionIndex++;

    if (_currentQuestionIndex < _questions.length) {
      emit(BotGameQuestionLoaded(
        question: _questions[_currentQuestionIndex],
        questionNumber: _currentQuestionIndex + 1,
        totalQuestions: _questions.length,
        playerScore: _playerScore,
        botScore: _botScore,
        botPlayer: _botPlayer,
      ));

      _startBotResponseTimer();
    } else {
      _finishGame();
    }
  }

  void _finishGame() {
    _botResponseTimer?.cancel();

    String result;
    if (_playerScore > _botScore) {
      result = "Vitória!";
    } else if (_botScore > _playerScore) {
      result = "Derrota!";
    } else {
      result = "Empate!";
    }

    emit(BotGameFinished(
      playerScore: _playerScore,
      botScore: _botScore,
      botPlayer: _botPlayer,
      result: result,
      totalQuestions: _questions.length,
    ));
  }

  int _calculateScore(int responseTimeMs) {
    // Sistema de pontuação baseado no tempo de resposta
    // Máximo 100 pontos, mínimo 10 pontos
    const int maxTime = 10000; // 10 segundos
    const int maxScore = 100;
    const int minScore = 10;

    if (responseTimeMs >= maxTime) return minScore;

    final timeBonus =
        ((maxTime - responseTimeMs) / maxTime) * (maxScore - minScore);
    return (minScore + timeBonus).round();
  }

  @override
  Future<void> close() {
    _botResponseTimer?.cancel();
    return super.close();
  }
}
