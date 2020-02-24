import 'package:maxga/http/server/UserHttp.repo.dart';
import 'package:maxga/model/user/User.dart';
import 'package:maxga/model/user/query/user-registry-query.dart';

class UserService {
  static Future<User> login(UserQuery query) async {
    return await UserHttpRepo.login(query);
  }

  static Future<bool> registry(UserRegistryQuery query) async {
    return await UserHttpRepo.registry(query);

  }

  static Future<String> refreshToken(String refreshToken) async {
    return UserHttpRepo.refreshToken(refreshToken);
  }

  static Future<void> resetPasswordRequest(String email) async {
    return UserHttpRepo.resetPasswordRequest(email);
  }

  static Future<void> logout(String refreshToken) {
    return UserHttpRepo.logout(refreshToken);
  }
}