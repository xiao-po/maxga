class MaxgaServerApi {
  static const String login = '/login';
  static const String syncCollectStatus = '/sync/collect';
  static const String syncReadStatus = '/sync/readStatus';

  static const String registry = '/registry';
  static const String refreshToken = '/refreshToken';

  static const String resetPassword = "/user/password/reset?email={email}";

  static const String hiddenManga = '/manga/{page}?keywords={keywords}';

  static const String logout = "/logout?refreshToken={refreshToken}";
}

