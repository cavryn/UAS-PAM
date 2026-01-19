import '../entities/user.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  
  Future<User> signIn({
    required String email,
    required String password,
  });
  
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String role,
    String? phone,
  });
  
  Future<User?> getUserData(String uid);
  
  Future<void> updateUserData({
    required String uid,
    String? name,
    String? phone,
    String? photoUrl,
  });
  
  Future<void> signOut();
}