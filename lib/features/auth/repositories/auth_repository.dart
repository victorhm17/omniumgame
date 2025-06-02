import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth}) 
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<User?> signUp({
    required String email,
    required String password,
    String? displayName, // Adicionado displayName
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Atualiza o perfil do usuário com o displayName, se fornecido
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateProfile(displayName: displayName);
      }
      // TODO: Salvar informações adicionais do usuário no Firestore aqui
      // (ex: data de nascimento, reputação inicial)
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException (signUp): ${e.message}');
      throw e; 
    } catch (e) {
      print('Erro desconhecido (signUp): $e');
      rethrow;
    }
  }

  Future<User?> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException (logIn): ${e.message}');
      throw e;
    } catch (e) {
      print('Erro desconhecido (logIn): $e');
      rethrow;
    }
  }

  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Erro desconhecido (logOut): $e');
      rethrow;
    }
  }

  Future<User?> logInWithFacebook() async {
    print("Login com Facebook a ser implementado.");
    throw UnimplementedError("Login com Facebook ainda não implementado.");
  }

  Future<User?> logInWithInstagram() async {
    print("Login com Instagram a ser implementado.");
    throw UnimplementedError("Login com Instagram ainda não implementado.");
  }
}

