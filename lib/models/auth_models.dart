class AuthResponse {
  final String message;

  AuthResponse({required this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] ?? 'Success',
    );
  }
}