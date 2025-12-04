class AuthResponse {
  final String message;
  final bool isPro; 
  AuthResponse({
    required this.message,
    this.isPro = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] ?? 'Success',
      isPro: json['isPro'] ?? false, 
    );
  }
}