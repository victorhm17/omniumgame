import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:omnium_game/features/trivia_game/cubit/trivia_game_cubit.dart';
import 'package:omnium_game/features/trivia_game/repositories/trivia_game_repository.dart';
import 'package:omnium_game/core/models/question_model.dart';
import 'package:omnium_game/core/models/match_model.dart';

import 'trivia_game_cubit_test.mocks.dart';

// Para gerar mocks: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([TriviaGameRepository, QuestionModel, MatchModel])
void main() {
  group('TriviaGameCubit', () {
    late TriviaGameCubit triviaGameCubit;
    late MockTriviaGameRepository mockTriviaGameRepository;
    late MockMatchModel mockMatchModel;
    late MockQuestionModel mockQuestionModel;

    setUp(() {
      mockTriviaGameRepository = MockTriviaGameRepository();
      mockMatchModel = MockMatchModel();
      mockQuestionModel = MockQuestionModel();
      
      when(mockMatchModel.id).thenReturn('testMatchId');
      when(mockQuestionModel.id).thenReturn('testQuestionId');
      when(mockQuestionModel.text).thenReturn('Qual a cor do cavalo branco de Napoleão?');
      when(mockQuestionModel.options).thenReturn([
        Option(text: 'Branco', isCorrect: true),
        Option(text: 'Preto', isCorrect: false),
        Option(text: 'Marrom', isCorrect: false),
        Option(text: 'Azul', isCorrect: false),
      ]);
      when(mockQuestionModel.difficulty).thenReturn('Fácil');
      when(mockQuestionModel.category).thenReturn('História');

      triviaGameCubit = TriviaGameCubit(triviaGameRepository: mockTriviaGameRepository);
    });

    tearDown(() {
      triviaGameCubit.close();
    });

    test('initial state is TriviaGameInitial', () {
      expect(triviaGameCubit.state, const TriviaGameInitial());
    });

    group('loadQuestionsForMatch', () {
      blocTest<TriviaGameCubit, TriviaGameState>(
        'emits [TriviaGameLoading, TriviaGameLoaded] when questions are loaded successfully',
        setUp: () {
          when(mockTriviaGameRepository.getQuestionsForMatch(any, any))
              .thenAnswer((_) async => [mockQuestionModel, mockQuestionModel]);
        },
        build: () => triviaGameCubit,
        act: (cubit) => cubit.loadQuestionsForMatch(mockMatchModel, 2),
        expect: () => [
          const TriviaGameLoading(),
          TriviaGameLoaded(questions: [mockQuestionModel, mockQuestionModel], currentQuestionIndex: 0, score: 0, answers: {}),
        ],
        verify: (_) {
          verify(mockTriviaGameRepository.getQuestionsForMatch(mockMatchModel, 2)).called(1);
        },
      );

      blocTest<TriviaGameCubit, TriviaGameState>(
        'emits [TriviaGameLoading, TriviaGameError] when loading questions fails',
        setUp: () {
          when(mockTriviaGameRepository.getQuestionsForMatch(any, any))
              .thenThrow(Exception('Failed to load questions'));
        },
        build: () => triviaGameCubit,
        act: (cubit) => cubit.loadQuestionsForMatch(mockMatchModel, 2),
        expect: () => [
          const TriviaGameLoading(),
          const TriviaGameError(message: 'Exception: Failed to load questions'),
        ],
      );
    });
    
    // TODO: Adicionar mais testes para:
    // - answerQuestion
    // - nextQuestion
    // - completeTrivia
    // - handleTimeout
  });
}

