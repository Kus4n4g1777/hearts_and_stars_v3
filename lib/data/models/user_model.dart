class User {
  final String username;
  final String? email;

  User({required this.username, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
    );
  }
}

class LoginCredentials {
  final String username;
  final String password;

  LoginCredentials({required this.username, required this.password});

  Map<String, String> toFormData() => {
    'username': username,
    'password': password,
  };
}

class LoginResponse {
  final String accessToken;

  LoginResponse({required this.accessToken});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String? ?? '',
    );
  }
}