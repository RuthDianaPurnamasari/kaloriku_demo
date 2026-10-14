/// DIGUNAKAN UNTUK FORM LOGIN
class LoginInput {
  final String username;
  final String password;

  LoginInput({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
      };
}

/// DIGUNAKAN UNTUK RESPONSE
class LoginResponse {
  final String? token;
  final String message;
  final int status;
  final String role;
  final String fullname;
  final String phone;

  LoginResponse({
    this.token,
    required this.message,
    required this.status,
    required this.role,
    required this.fullname,
    required this.phone,
  });

 // Factory method untuk convert dari JSON ke object LoginResponse
  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        token: json["token"] ?? '',
        message: json["message"] ?? '',
        status: json["status"] ?? 0,
        role: json["role"] ?? '',
        fullname: json["fullname"] ?? '',
        phone: json["phone"] ?? '',
      );

  /// Convert LoginResponse object ke JSON (misal untuk simpan ke local storage)
  Map<String, dynamic> toJson() => {
        "token": token,
        "message": message,
        "status": status,
        "role": role,
        "fullname": fullname,
        "phone": phone,
      };
}