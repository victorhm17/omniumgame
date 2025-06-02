import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:omnium_game/features/photo_challenges/cubit/photo_challenges_cubit.dart';
import 'package:omnium_game/features/photo_challenges/repositories/photo_challenges_repository.dart';
import 'package:omnium_game/core/models/challenge_model.dart';
import 'package:omnium_game/core/models/match_model.dart';
import 'package:omnium_game/core/models/user_model.dart'; // Assuming UserModel might be needed

import 'photo_challenges_cubit_test.mocks.dart';

// Para gerar mocks: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([PhotoChallengesRepository])
void main() {
  group('PhotoChallengesCubit', () {
    late PhotoChallengesCubit photoChallengesCubit;
    late MockPhotoChallengesRepository mockPhotoChallengesRepository;
    late MockMatchModel mockMatchModel;
    late MockChallengeModel mockChallengeModel;
    late MockUserModel mockWinner;
    late MockUserModel mockLoser;

    setUp(() {
      mockPhotoChallengesRepository = MockPhotoChallengesRepository();
      mockMatchModel = MockMatchModel();
      mockChallengeModel = MockChallengeModel();
      mockWinner = MockUserModel();
      mockLoser = MockUserModel();

      when(mockMatchModel.id).thenReturn('testMatchId');
      when(mockChallengeModel.id).thenReturn('testChallengeId');
      when(mockChallengeModel.description).thenReturn('Tire uma foto de uma colher');
      when(mockWinner.uid).thenReturn('winnerId');
      when(mockLoser.uid).thenReturn('loserId');

      photoChallengesCubit = PhotoChallengesCubit(
        photoChallengesRepository: mockPhotoChallengesRepository,
      );
    });

    tearDown(() {
      photoChallengesCubit.close();
    });

    test('initial state is PhotoChallengesInitial', () {
      expect(photoChallengesCubit.state, const PhotoChallengesInitial());
    });

    group('loadChallengeTypes', () {
      blocTest<PhotoChallengesCubit, PhotoChallengesState>(
        'emits [PhotoChallengesLoading, ChallengeTypesLoaded] when challenge types are loaded successfully',
        setUp: () {
          when(mockPhotoChallengesRepository.getChallengeTypes())
              .thenAnswer((_) async => [mockChallengeModel, mockChallengeModel]);
        },
        build: () => photoChallengesCubit,
        act: (cubit) => cubit.loadChallengeTypes(),
        expect: () => [
          const PhotoChallengesLoading(),
          ChallengeTypesLoaded(challengeTypes: [mockChallengeModel, mockChallengeModel]),
        ],
        verify: (_) {
          verify(mockPhotoChallengesRepository.getChallengeTypes()).called(1);
        },
      );

      blocTest<PhotoChallengesCubit, PhotoChallengesState>(
        'emits [PhotoChallengesLoading, PhotoChallengesError] when loading challenge types fails',
        setUp: () {
          when(mockPhotoChallengesRepository.getChallengeTypes())
              .thenThrow(Exception('Failed to load challenge types'));
        },
        build: () => photoChallengesCubit,
        act: (cubit) => cubit.loadChallengeTypes(),
        expect: () => [
          const PhotoChallengesLoading(),
          const PhotoChallengesError(message: 'Exception: Failed to load challenge types'),
        ],
      );
    });

    // TODO: Adicionar mais testes para:
    // - selectChallenge
    // - submitChallengePhoto
    // - skipChallenge
    // - loadActiveChallengeForMatch
  });
}

