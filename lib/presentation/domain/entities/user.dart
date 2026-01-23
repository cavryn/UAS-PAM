// lib/presentation/domain/entities/user.dart

class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' or 'user'
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.photoUrl,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
}