import 'dart:async'; // Adicionado para StreamSubscription

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:omnium_game/features/matchmaking/cubit/matchmaking_cubit.dart';
import 'package:omnium_game/features/matchmaking/repositories/matchmaking_repository.dart';
import 'package:omnium_game/core/models/match_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart'; // Import para Timestamp

import 'matchmaking_cubit_test.mocks.dart';

// Para gerar mocks: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([MatchmakingRepository, MatchModel, fb_auth.User])
void main() {
  group('MatchmakingCubit', () {
    late MatchmakingCubit matchmakingCubit;
    late MockMatchmakingRepository mockMatchmakingRepository;
    late MockUser mockUser;
    late MockMatchModel mockMatchModel;
    late StreamController<List<MatchModel>> pendingInvitesController;
    late StreamController<MatchModel?> activeMatchController;

    setUp(() {
      mockMatchmakingRepository = MockMatchmakingRepository();
      mockUser = MockUser();
      mockMatchModel = MockMatchModel();
      pendingInvitesController = StreamController<List<MatchModel>>.broadcast();
      activeMatchController = StreamController<MatchModel?>.broadcast();

      when(mockUser.uid).thenReturn('testUserId');
      when(mockMatchModel.id).thenReturn('testMatchId');
      // Stubs básicos para MockMatchModel para evitar MissingStubError
      when(mockMatchModel.status).thenReturn('pending_friend_invite'); // Estado inicial comum para um convite
      when(mockMatchModel.player1Id).thenReturn('testUserId');
      when(mockMatchModel.player2Id).thenReturn(null); // Inicialmente sem segundo jogador
      when(mockMatchModel.winnerId).thenReturn(null);
      when(mockMatchModel.currentTurn).thenReturn('testUserId');
      when(mockMatchModel.createdAt).thenReturn(Timestamp.now()); // Corrigido para Timestamp
      when(mockMatchModel.updatedAt).thenReturn(Timestamp.now()); // Corrigido para Timestamp
      when(mockMatchModel.player1Username).thenReturn('Test User');
      when(mockMatchModel.player2Username).thenReturn(null);

      // Simular currentUser no repositório para _listenToPendingInvites
      when(mockMatchmakingRepository.currentUser).thenReturn(mockUser);
      // Usar o controller para o stream de convites
      when(mockMatchmakingRepository.getPendingInvitesStream()).thenAnswer((_) => pendingInvitesController.stream);
      // Usar o controller para o stream de partida ativa
      when(mockMatchmakingRepository.getMatchStream(any)).thenAnswer((_) => activeMatchController.stream);

      matchmakingCubit = MatchmakingCubit(matchmakingRepository: mockMatchmakingRepository);
    });

    tearDown(() {
      pendingInvitesController.close();
      activeMatchController.close();
      matchmakingCubit.close();
    });

    test('initial state after stream emits is MatchmakingInvitesLoaded with empty list', () async {
      // O construtor chama _listenToPendingInvites, que se inscreve no stream.
      // Emitimos uma lista vazia para simular o estado inicial após a primeira carga de convites.
      pendingInvitesController.add([]);
      await Future.delayed(Duration.zero); // Aguarda a emissão do stream ser processada
      expect(matchmakingCubit.state, const MatchmakingInvitesLoaded(invites: []));
    });

    group('inviteFriend', () {
      blocTest<MatchmakingCubit, MatchmakingState>(
        'emits [MatchmakingLoading, MatchmakingInviteSent, then MatchmakingSuccess if stream updates to active]',
        setUp: () {
          when(mockMatchmakingRepository.inviteFriendToMatch(any, any))
              .thenAnswer((_) async => mockMatchModel); // Retorna um MatchModel com status 'pending_friend_invite'
          
          // Configurar o mockMatchModel para o estado esperado após o convite
          when(mockMatchModel.status).thenReturn('pending_friend_invite');
        },
        build: () => matchmakingCubit,
        act: (cubit) {
          cubit.inviteFriend('opponentId', 'opponentUsername'); // Removido await
          // Simular a atualização do stream da partida para "active" após o convite ser aceito (hipoteticamente)
          // Para este teste, focamos no MatchmakingInviteSent. A transição para MatchmakingSuccess
          // dependeria de outra ação (acceptInvite) e da atualização do stream.
          // No entanto, _subscribeToMatchUpdates é chamado. Se o mockMatchModel já estiver "active", ele emitirá.
          // Vamos garantir que o status inicial do mockMatchModel no stream seja 'pending_friend_invite'
          // e depois, se quisermos testar a transição para active, emitimos um novo MatchModel.
          activeMatchController.add(mockMatchModel); // Emite o estado inicial da partida criada
        },
        expect: () => [
          const MatchmakingLoading(message: "Convidando amigo..."),
          MatchmakingInviteSent(match: mockMatchModel, message: "Convite enviado para opponentUsername!"),
          // Se o mockMatchModel (status: 'pending_friend_invite') for emitido no activeMatchController,
          // o _subscribeToMatchUpdates não necessariamente emitirá um novo estado visível aqui,
          // pois ele verifica se o status é 'active' e player2Id != null para MatchmakingSuccess.
          // Ou 'pending_random' para MatchmakingLookingForOpponent.
          // Para 'pending_friend_invite', ele não emite um novo estado específico no _subscribeToMatchUpdates.
          // Portanto, o MatchmakingInviteSent é o último estado esperado diretamente desta ação.
        ],
        verify: (_) {
          verify(mockMatchmakingRepository.inviteFriendToMatch('opponentId', 'opponentUsername')).called(1);
          verify(mockMatchmakingRepository.getMatchStream('testMatchId')).called(1);
        },
      );

      blocTest<MatchmakingCubit, MatchmakingState>(
        'emits [MatchmakingLoading, MatchmakingError] when inviteFriend fails',
        setUp: () {
          when(mockMatchmakingRepository.inviteFriendToMatch(any, any))
              .thenThrow(Exception('Failed to invite friend'));
        },
        build: () => matchmakingCubit,
        act: (cubit) => cubit.inviteFriend('opponentId', 'opponentUsername'), // Removido await se inviteFriend for void
        expect: () => [
          const MatchmakingLoading(message: "Convidando amigo..."),
          const MatchmakingError(message: 'Exception: Failed to invite friend'),
        ],
        verify: (_) {
          verify(mockMatchmakingRepository.inviteFriendToMatch('opponentId', 'opponentUsername')).called(1);
        },
      );
    });

    // TODO: Adicionar mais testes aqui para:
    // - findRandomMatch
    // - acceptInvite
    // - declineOrCancelMatch
    // - _listenToPendingInvites (testar diferentes cenários do stream)
    // - _subscribeToMatchUpdates (testar diferentes cenários do stream)
    // - clearMatchSubscription
  });
}

