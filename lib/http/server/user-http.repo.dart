import 'package:maxga/model/user/query/user-registry-query.dart';
import 'package:maxga/model/user/user.dart';

import 'base/maxga-server-http-utils.dart';
import 'base/maxga-server.contants.dart';

class UserHttpRepo {
  static Future<bool> registry(UserRegistryQuery query) {
    return MaxgaServerHttpUtils.post<bool>(
      MaxgaServerApi.registry,
      query,
      factory: (v) => true,
    );
  }

  static Future<User> login(UserQuery query) {
    return MaxgaServerHttpUtils.post<User>(
      MaxgaServerApi.login +
          '?username=${query.username}&password=${query.password}',
      query,
      factory: (v) => User.fromJson(v),
    );
  }

  static Future<String> refreshToken(String refreshToken) {
    return MaxgaServerHttpUtils.get<String>(
      MaxgaServerApi.refreshToken + '?refreshToken=${Uri.encodeComponent(refreshToken)}'
    );
  }

  static Future<void> resetPasswordRequest(String email) {
    return MaxgaServerHttpUtils.post<String>(
      MaxgaServerApi.resetPassword.replaceFirst("{email}", email),
      null,
    );
  }

  static Future<void> logout(String refreshToken) {
    return MaxgaServerHttpUtils.post<String>(
      MaxgaServerApi.logout.replaceFirst("{refreshToken}", refreshToken),
      null,
    );
  }

  static Future<void> changePassword(String oldPassword, String newPassword) {
    return MaxgaServerHttpUtils.post<String>(
      MaxgaServerApi.changePassword
          .replaceFirst("{password}", newPassword)
          .replaceFirst("{oldPassword}", oldPassword),
      null,
    );
  }
}
