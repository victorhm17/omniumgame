import 'dart:async'; // Necessário para StreamSubscription
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:omnium_game/features/auth/repositories/auth_repository.dart';
// Import ReputationRepository if profile creation is handled here
// import 'package:omnium_game/features/reputation/repositories/reputation_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  // final ReputationRepository _reputationRepository; // Uncomment if used
  StreamSubscription<fb_auth.User?>? _userSubscription;

  AuthCubit({
    required AuthRepository authRepository,
    // required ReputationRepository reputationRepository, // Uncomment if used
  })  : _authRepository = authRepository,
        // _reputationRepository = reputationRepository, // Uncomment if used
        super(AuthInitial()) {
    _userSubscription = _authRepository.user.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  void appStarted() async {
    emit(AuthLoading());
    // The stream listener in the constructor will handle emitting
    // AuthAuthenticated or AuthUnauthenticated after this initial loading state.
    // If an immediate synchronous check is desired and possible, it could be added here,
    // but relying on the stream is generally more robust for auth state changes.
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(AuthLoading());
    try {
      final fb_auth.User? user = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName, // Pass displayName to repository
      );
      // No need to emit AuthAuthenticated here if the stream listener handles it
      // However, if signUp itself returns the user, it implies success
      // and the stream might take a moment to update. For immediate feedback:
      if (user != null) {
        // emit(AuthAuthenticated(user: user)); // Stream listener should catch this.
      } else {
        // This case should ideally be handled by exceptions from the repository
        emit(const AuthError(message: "Falha no cadastro. Usuário não retornado."));
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? "Ocorreu um erro durante o cadastro."));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> logInWithEmailAndPasswordRequested({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final fb_auth.User? user = await _authRepository.logInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Stream listener should catch this if successful.
      if (user == null) {
         // This case should ideally be handled by exceptions from the repository
        emit(const AuthError(message: "Falha no login. Usuário não retornado."));
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? "Ocorreu um erro durante o login."));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void logInWithFacebookRequested() async {
    emit(AuthLoading());
    try {
      final fb_auth.User? user = await _authRepository.logInWithFacebook();
      // Stream listener should catch this if successful.
      if (user == null && state is! AuthAuthenticated) {
        // If login fails and we are not already authenticated (e.g. user cancelled)
        emit(AuthUnauthenticated()); 
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      emit(AuthError(message: e.message ?? "Erro no login com Facebook."));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void logOutRequested() async {
    emit(AuthLoading());
    try {
      await _authRepository.logOut();
      // Stream listener will emit AuthUnauthenticated
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}

