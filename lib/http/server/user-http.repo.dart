import 'package:maxga/model/user/user.dart';
import 'package:maxga/model/user/query/user-registry-query.dart';

import 'base/maxga-server.contants.dart';
import 'base/maxga-server-http-utils.dart';

class UserHttpRepo {
  static Future<bool> registry(UserRegistryQuery query) {
    return MaxgaServerHttpUtils.requestMaxgaServer<bool>(
      MaxgaServerApi.registry,
      query,
          (v) => true,
    );
  }

  static Future<User> login(UserQuery query) {
    return MaxgaServerHttpUtils.requestMaxgaServer<User>(
      MaxgaServerApi.login +
          '?username=${query.username}&password=${query.password}',
      query,
          (v) => User.fromJson(v),
    );
  }

  static Future<String> refreshToken(String refreshToken) {
    return MaxgaServerHttpUtils.requestMaxgaServer<String>(
      MaxgaServerApi.refreshToken,
      null,
          (v) => v,
    );
  }

  static Future<void> resetPasswordRequest(String email) {
    return MaxgaServerHttpUtils.requestMaxgaServer<String>(
      MaxgaServerApi.resetPassword.replaceFirst("{email}", email),
      null,
          (v) => v,
    );
  }

  static Future<void> logout(String refreshToken) {
    return MaxgaServerHttpUtils.requestMaxgaServer<String>(
      MaxgaServerApi.logout.replaceFirst("{refreshToken}", refreshToken),
      null,
          (v) => v,
    );
  }
}
