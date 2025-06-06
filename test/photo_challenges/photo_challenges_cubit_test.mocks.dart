// Mocks generated by Mockito 5.4.6 from annotations
// in omnium_game/test/photo_challenges/photo_challenges_cubit_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:omnium_game/core/models/challenge_model.dart' as _i2;
import 'package:omnium_game/features/photo_challenges/repositories/photo_challenges_repository.dart'
    as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakePhotoChallengeModel_0 extends _i1.SmartFake
    implements _i2.PhotoChallengeModel {
  _FakePhotoChallengeModel_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [PhotoChallengesRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockPhotoChallengesRepository extends _i1.Mock
    implements _i3.PhotoChallengesRepository {
  MockPhotoChallengesRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<List<_i2.ChallengeTypeModel>> getChallengeTypes() =>
      (super.noSuchMethod(
            Invocation.method(#getChallengeTypes, []),
            returnValue: _i4.Future<List<_i2.ChallengeTypeModel>>.value(
              <_i2.ChallengeTypeModel>[],
            ),
          )
          as _i4.Future<List<_i2.ChallengeTypeModel>>);

  @override
  _i4.Future<_i2.PhotoChallengeModel> createPhotoChallenge({
    required String? matchId,
    required String? chosenChallengeTypeId,
    required String? chosenChallengeTypeName,
    required String? challengerId,
    required String? challengedId,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#createPhotoChallenge, [], {
              #matchId: matchId,
              #chosenChallengeTypeId: chosenChallengeTypeId,
              #chosenChallengeTypeName: chosenChallengeTypeName,
              #challengerId: challengerId,
              #challengedId: challengedId,
            }),
            returnValue: _i4.Future<_i2.PhotoChallengeModel>.value(
              _FakePhotoChallengeModel_0(
                this,
                Invocation.method(#createPhotoChallenge, [], {
                  #matchId: matchId,
                  #chosenChallengeTypeId: chosenChallengeTypeId,
                  #chosenChallengeTypeName: chosenChallengeTypeName,
                  #challengerId: challengerId,
                  #challengedId: challengedId,
                }),
              ),
            ),
          )
          as _i4.Future<_i2.PhotoChallengeModel>);

  @override
  _i4.Future<_i2.PhotoChallengeModel?> getPhotoChallenge(String? challengeId) =>
      (super.noSuchMethod(
            Invocation.method(#getPhotoChallenge, [challengeId]),
            returnValue: _i4.Future<_i2.PhotoChallengeModel?>.value(),
          )
          as _i4.Future<_i2.PhotoChallengeModel?>);

  @override
  _i4.Future<List<_i2.PhotoChallengeModel>>
  getPendingChallengesForCurrentUser() =>
      (super.noSuchMethod(
            Invocation.method(#getPendingChallengesForCurrentUser, []),
            returnValue: _i4.Future<List<_i2.PhotoChallengeModel>>.value(
              <_i2.PhotoChallengeModel>[],
            ),
          )
          as _i4.Future<List<_i2.PhotoChallengeModel>>);

  @override
  _i4.Future<_i2.PhotoChallengeModel> submitPhotoForChallenge({
    required String? challengeId,
    required dynamic photoBytes,
    required String? fileName,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#submitPhotoForChallenge, [], {
              #challengeId: challengeId,
              #photoBytes: photoBytes,
              #fileName: fileName,
            }),
            returnValue: _i4.Future<_i2.PhotoChallengeModel>.value(
              _FakePhotoChallengeModel_0(
                this,
                Invocation.method(#submitPhotoForChallenge, [], {
                  #challengeId: challengeId,
                  #photoBytes: photoBytes,
                  #fileName: fileName,
                }),
              ),
            ),
          )
          as _i4.Future<_i2.PhotoChallengeModel>);

  @override
  _i4.Future<_i2.PhotoChallengeModel> skipChallenge(String? challengeId) =>
      (super.noSuchMethod(
            Invocation.method(#skipChallenge, [challengeId]),
            returnValue: _i4.Future<_i2.PhotoChallengeModel>.value(
              _FakePhotoChallengeModel_0(
                this,
                Invocation.method(#skipChallenge, [challengeId]),
              ),
            ),
          )
          as _i4.Future<_i2.PhotoChallengeModel>);

  @override
  _i4.Stream<_i2.PhotoChallengeModel?> getChallengeStream(
    String? challengeId,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getChallengeStream, [challengeId]),
            returnValue: _i4.Stream<_i2.PhotoChallengeModel?>.empty(),
          )
          as _i4.Stream<_i2.PhotoChallengeModel?>);
}
