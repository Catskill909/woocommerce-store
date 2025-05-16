import 'package:woocommerce_app/features/auth/domain/entities/user.dart';

class LoginResponseModel {
  final String token;
  final User user;

  LoginResponseModel({
    required this.token,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'],
      user: User(
        id: json['user_id'] ?? 0,
        email: json['user_email'] ?? '',
        username: json['user_nicename'],
        displayName: json['user_display_name'],
        token: json['token'],
      ),
    );
  }
}
