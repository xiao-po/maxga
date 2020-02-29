import 'package:maxga/http/server/user-http.repo.dart';
import 'package:maxga/model/user/user.dart';
import 'package:maxga/model/user/query/user-registry-query.dart';

class UserService {
  static Future<User> login(UserQuery query) async {
    return await UserHttpRepo.login(query);
  }

  static Future<bool> registry(UserRegistryQuery query) async {
    return await UserHttpRepo.registry(query);

  }


  static Future<void> resetPasswordRequest(String email) async {
    return UserHttpRepo.resetPasswordRequest(email);
  }

  static Future<void> logout(String refreshToken) {
    return UserHttpRepo.logout(refreshToken);
  }

  static Future<void> changePassword(String oldPassword, String newPassword) {
    return UserHttpRepo.changePassword(oldPassword, newPassword);

  }
}