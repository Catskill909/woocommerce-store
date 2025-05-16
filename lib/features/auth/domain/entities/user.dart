import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? avatarUrl;
  final String? token;
  final bool isAdmin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.displayName,
    this.avatarUrl,
    this.token,
    this.isAdmin = false,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        firstName,
        lastName,
        displayName,
        avatarUrl,
        token,
        isAdmin,
        createdAt,
        updatedAt,
      ];

  User copyWith({
    int? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? displayName,
    String? avatarUrl,
    String? token,
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      token: token ?? this.token,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAuthenticated => token != null && token!.isNotEmpty;
}
