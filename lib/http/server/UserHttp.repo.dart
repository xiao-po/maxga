import 'package:maxga/model/user/User.dart';
import 'package:maxga/model/user/query/user-registry-query.dart';

import 'base/MaxgaServer.contants.dart';
import 'base/MaxgaServerHttpUtils.dart';

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
}
