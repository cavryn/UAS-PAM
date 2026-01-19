import 'package:flutter/foundation.dart';
import '../presentation/domain/repositories/auth_repository.dart';
import '../presentation/domain/entities/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authRepository) {
    _checkAuthStatus();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Listen to auth state changes
      _authRepository.authStateChanges.listen((user) {
        _currentUser = user;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      print('Error checking auth status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔐 AuthProvider: Starting sign in...');
      
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      print('✅ AuthProvider: Sign in successful');
      print('👤 User: ${user.email}, Role: ${user.role}');

      _currentUser = user;
      _error = null;
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('❌ AuthProvider: Sign in failed - $e');
      _error = e.toString();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📝 AuthProvider: Starting registration...');
      
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );

      print('✅ AuthProvider: Registration successful');
      print('👤 User: ${user.email}, Role: ${user.role}');

      _currentUser = user;
      _error = null;
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      print('❌ AuthProvider: Registration failed - $e');
      _error = e.toString();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.updateUserData(
        uid: _currentUser!.id,
        name: name,
        phone: phone,
        photoUrl: photoUrl,
      );

      // Refresh user data
      final updatedUser = await _authRepository.getUserData(_currentUser!.id);
      if (updatedUser != null) {
        _currentUser = updatedUser;
      }
    } catch (e) {
      _error = e.toString();
      print('Error updating profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}