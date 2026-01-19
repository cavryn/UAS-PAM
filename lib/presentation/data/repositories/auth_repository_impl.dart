// lib/presentation/data/repositories/auth_repository_impl.dart

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../services/firebase_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Stream<User?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _authService.getUserData(firebaseUser.uid);
    });
  }

  @override
  User? get currentUser {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) return null;
    // Note: This is synchronous, so we can't fetch full user data here
    // You might want to handle this differently in production
    return null;
  }

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    return await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
    String? phone,
  }) async {
    return await _authService.registerWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
      role: role,
      phone: phone,
    );
  }

  @override
  Future<User?> getUserData(String uid) async {
    return await _authService.getUserData(uid);
  }

  @override
  Future<void> updateUserData({
    required String uid,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    await _authService.updateUserData(
      uid: uid,
      name: name,
      phone: phone,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }
}