import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "dart:async"; // Adicionado import para StreamSubscription
import "package:cloud_firestore/cloud_firestore.dart"; // Adicionado import para Firestore
import "package:omnium_game/core/models/match_model.dart";
import "package:omnium_game/core/models/question_model.dart";
import "package:omnium_game/features/trivia_game/repositories/trivia_game_repository.dart";
import "package:omnium_game/features/matchmaking/repositories/matchmaking_repository.dart"; // Para atualizar o match

part "trivia_game_state.dart";

class TriviaGameCubit extends Cubit<TriviaGameState> {
  final TriviaGameRepository _triviaGameRepository;
  final MatchmakingRepository _matchmakingRepository; // Para interagir com o MatchModel
  final String matchId;
  MatchModel? _currentMatch;
  List<QuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  // TODO: Adicionar timer para resposta

  TriviaGameCubit({
    required this.matchId,
    required TriviaGameRepository triviaGameRepository,
    required MatchmakingRepository matchmakingRepository,
  })  : _triviaGameRepository = triviaGameRepository,
        _matchmakingRepository = matchmakingRepository,
        super(TriviaGameInitial());

  Future<void> loadGame() async {
    emit(TriviaGameLoading());
    try {
      // 1. Carregar dados da partida (para saber quem são os jogadores, etc.)
      //    Usaremos o stream do MatchmakingCubit para isso ou carregamos uma vez aqui.
      //    Por simplicidade, vamos supor que o MatchModel é passado ou carregado.
      //    Idealmente, o TriviaGameCubit ouviria o MatchModel do MatchmakingCubit ou de um stream próprio.
      DocumentSnapshot matchDoc = await FirebaseFirestore.instance.collection("matches").doc(matchId).get();
      if (!matchDoc.exists) {
        emit(const TriviaGameError(message: "Partida não encontrada ao carregar o jogo."));
        return;
      }
      _currentMatch = MatchModel.fromFirestore(matchDoc);

      if (_currentMatch!.status != "active") {
        emit(TriviaGameError(message: "A partida não está ativa. Status: ${_currentMatch!.status}"));
        return;
      }

      // 2. Carregar perguntas
      // Se as perguntas já estiverem no MatchModel, usar de lá.
      // Senão, buscar do repositório e potencialmente salvar no MatchModel.
      if (_currentMatch!.questions != null && _currentMatch!.questions!.isNotEmpty) {
        // TODO: Mapear de List<Map<String, dynamic>> para List<QuestionModel>
        // _questions = _currentMatch!.questions!.map((qMap) => QuestionModel.fromMap(qMap, qMap["id"] ?? UniqueKey().toString())).toList();
        // Por enquanto, vamos buscar novas perguntas se não estiverem formatadas como QuestionModel
        print("Perguntas já existem no match, mas precisam ser convertidas para QuestionModel.");
        _questions = await _triviaGameRepository.getQuestionsForMatch(count: 5); // Ex: 5 perguntas
         // TODO: Salvar as perguntas no MatchModel se for a primeira vez
        await _matchmakingRepository.updateMatchData(matchId, {
          "questions_data": _questions.map((q) => q.toMap()).toList(), // Salva a estrutura completa
          "current_question_index": 0,
          // "current_turn": _currentMatch!.player1Id // Define o primeiro jogador
        });

      } else {
        _questions = await _triviaGameRepository.getQuestionsForMatch(count: 5); // Ex: 5 perguntas
        if (_questions.isEmpty) {
          emit(const TriviaGameError(message: "Nenhuma pergunta encontrada para a partida."));
          return;
        }
        // Salvar as perguntas no MatchModel para persistência e para o outro jogador ver as mesmas
        await _matchmakingRepository.updateMatchData(matchId, {
          "questions_data": _questions.map((q) => q.toMap()).toList(), // Salva a estrutura completa
          "current_question_index": 0,
          // "current_turn": _currentMatch!.player1Id // Define o primeiro jogador
        });
      }
      
      _currentQuestionIndex = _currentMatch!.currentQuestionIndex ?? 0;

      if (_questions.isNotEmpty && _currentQuestionIndex < _questions.length) {
        emit(TriviaGameQuestionLoaded(
          question: _questions[_currentQuestionIndex],
          questionNumber: _currentQuestionIndex + 1,
          totalQuestions: _questions.length,
          match: _currentMatch!,
        ));
      } else if (_questions.isNotEmpty && _currentQuestionIndex >= _questions.length) {
        // Jogo já terminou, mostrar resultados
        emit(TriviaGameFinished(match: _currentMatch!, message: "Jogo carregado, mas já finalizado."));
      } else {
         emit(const TriviaGameError(message: "Não foi possível carregar as perguntas."));
      }

    } catch (e) {
      emit(TriviaGameError(message: "Erro ao carregar jogo: ${e.toString()}"));
    }
  }

  Future<void> submitAnswer(int selectedOptionIndex) async {
    if (state is! TriviaGameQuestionLoaded) return;
    final currentState = state as TriviaGameQuestionLoaded;
    final QuestionModel currentQuestion = currentState.question;
    final bool isCorrect = currentQuestion.options[selectedOptionIndex].isCorrect;
    final String currentPlayerId = _matchmakingRepository.currentUser!.uid;

    // TODO: Calcular tempo de resposta
    const int timeTakenMs = 5000; // Placeholder

    emit(TriviaGameAnswerProcessing(question: currentQuestion, selectedOptionIndex: selectedOptionIndex, match: _currentMatch!));

    try {
      await _triviaGameRepository.submitAnswer(
        matchId: matchId,
        playerId: currentPlayerId,
        questionId: currentQuestion.id,
        selectedOptionIndex: selectedOptionIndex,
        isCorrect: isCorrect,
        timeTakenMs: timeTakenMs,
      );

      // Atualizar score localmente ou recarregar o MatchModel
      int currentScore = _currentMatch!.scores[currentPlayerId] ?? 0;
      if (isCorrect) {
        currentScore += 10; // Exemplo de pontuação
      }
      _currentMatch = _currentMatch!.copyWith(scores: {..._currentMatch!.scores, currentPlayerId: currentScore});
      
      // Atualizar o score no Firestore também
      await _matchmakingRepository.updateMatchData(matchId, {
        "scores.$currentPlayerId": currentScore,
        // TODO: Lógica de alternância de turno ou se ambos respondem
      });

      emit(TriviaGameAnswerResult(
        question: currentQuestion,
        selectedOptionIndex: selectedOptionIndex,
        isCorrect: isCorrect,
        match: _currentMatch!,
        questionNumber: currentState.questionNumber,
        totalQuestions: currentState.totalQuestions,
      ));

      // TODO: Lógica para avançar para a próxima pergunta ou finalizar o jogo
      // await Future.delayed(const Duration(seconds: 2)); // Pequeno delay para mostrar o resultado
      // _nextQuestionOrFinish();

    } catch (e) {
      emit(TriviaGameError(message: "Erro ao submeter resposta: ${e.toString()}"));
      // Reverter para a pergunta anterior em caso de erro?
      emit(currentState); 
    }
  }

  void _nextQuestionOrFinish() async {
    _currentQuestionIndex++;
    await _matchmakingRepository.updateMatchData(matchId, {"current_question_index": _currentQuestionIndex});

    if (_currentQuestionIndex < _questions.length) {
      emit(TriviaGameQuestionLoaded(
        question: _questions[_currentQuestionIndex],
        questionNumber: _currentQuestionIndex + 1,
        totalQuestions: _questions.length,
        match: _currentMatch!,
      ));
    } else {
      // Jogo finalizado
      // TODO: Determinar vencedor
      String? winnerId;
      // Exemplo simples de lógica de vencedor
      final player1Id = _currentMatch!.player1Id;
      final player2Id = _currentMatch!.player2Id;
      if (player1Id != null && player2Id != null) {
          final scoreP1 = _currentMatch!.scores[player1Id] ?? 0;
          final scoreP2 = _currentMatch!.scores[player2Id] ?? 0;
          if (scoreP1 > scoreP2) winnerId = player1Id;
          else if (scoreP2 > scoreP1) winnerId = player2Id;
          // else é empate
      }
      _currentMatch = _currentMatch!.copyWith(status: "completed", winnerId: winnerId);
      await _matchmakingRepository.updateMatchData(matchId, {"status": "completed", "winner_id": winnerId});
      emit(TriviaGameFinished(match: _currentMatch!, message: "Jogo finalizado!"));
    }
  }
  
  // Chamado pela UI após o usuário ver o resultado da resposta
  void proceedToNextStep() {
     if (state is TriviaGameAnswerResult) {
        _nextQuestionOrFinish();
     } else {
        // Se não estava mostrando resultado, talvez recarregar o estado atual da pergunta
        if (_questions.isNotEmpty && _currentQuestionIndex < _questions.length) {
             emit(TriviaGameQuestionLoaded(
                question: _questions[_currentQuestionIndex],
                questionNumber: _currentQuestionIndex + 1,
                totalQuestions: _questions.length,
                match: _currentMatch!,
            ));
        } else if (_currentMatch != null && _currentMatch!.status == "completed") {
            emit(TriviaGameFinished(match: _currentMatch!, message: "Jogo já finalizado."));
        } else {
            // Tentar recarregar o jogo se algo estiver inconsistente
            loadGame();
        }
     }
  }
}

// Extensão para MatchmakingRepository para adicionar updateMatchData
// Idealmente, isso estaria no próprio MatchmakingRepository
extension MatchmakingRepositoryUpdate on MatchmakingRepository {
  Future<void> updateMatchData(String matchId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection("matches").doc(matchId).update(data);
  }
}
