import 'dart:convert';

class User {
  final String uuid;
  final String username;
  final String email;
  final DateTime createTime;
  final String refreshToken;
  final String token;

  User(this.uuid, this.username, this.email, this.createTime, this.refreshToken,
      this.token);

  User.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        username = json['username'],
        email = json['email'],
        createTime = DateTime.parse(json['createTime']),
        refreshToken = json['refreshToken'],
        token = json['token'];

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'username': username,
    'email': email,
    'createTime': createTime.toIso8601String(),
    'refreshToken': refreshToken,
    'token': token,
  };
}

class UserQuery {
  final String username;
  final String password;

  UserQuery(this.username, this.password);

  Map<String, dynamic> toJson() => {'password': password, 'username': username};
}
