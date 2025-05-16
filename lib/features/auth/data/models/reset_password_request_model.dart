class ResetPasswordRequestModel {
  final String email;

  ResetPasswordRequestModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}
