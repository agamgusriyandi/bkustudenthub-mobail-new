import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  final String? email;
  final String? identifier;
  final String? nim;
  final String? password;

  const LoginRequest({this.email, this.identifier, this.nim, this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'],
      identifier: json['identifier'],
      nim: json['nim'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'identifier': identifier,
      'nim': nim,
      'password': password,
    };
  }

  @override
  List<Object?> get props => [email, identifier, nim, password];
}
