class LoginRequestDto {
  const LoginRequestDto({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class RegisterRequestDto {
  const RegisterRequestDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
      };
}

class UserDto {
  const UserDto({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phoneNumber,
    required this.theme,
  });

  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String phoneNumber;
  final String theme;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      theme: json['theme'] as String,
    );
  }
}

class AuthResponseDto {
  const AuthResponseDto({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final UserDto user;
  final String accessToken;
  final String refreshToken;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      user: UserDto.fromJson(json['userDto'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}