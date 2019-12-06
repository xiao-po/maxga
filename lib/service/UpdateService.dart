import 'package:maxga/http/github/GithubReleaseRepo.dart';
import 'package:maxga/model/github/GithubRelease.dart';
import 'package:maxga/model/maxga/MaxgaReleaseInfo.dart';
import 'package:maxga/service/LocalStorage.service.dart';
import 'package:package_info/package_info.dart';

final IgnoreUpdateVersion =  'IgnoreUpdateVersion';

class UpdateService {
  static Future<MaxgaReleaseInfo> checkUpdateStatus() async {
    MaxgaReleaseInfo nextVersionInfo = await _getNextVersionInfo();
    String currentVersion = await _getCurrentVersion();
    final String ignoreUpdateVersion = await LocalStorage.getString(IgnoreUpdateVersion);

    if (nextVersionInfo.compare(currentVersion) && nextVersionInfo.compare(ignoreUpdateVersion)) {
      return nextVersionInfo;
    } else {
      return null;
    }
  }


  static Future<bool> ignoreUpdate(MaxgaReleaseInfo maxgaReleaseInfo) async {

    final isOver = await LocalStorage.setString(IgnoreUpdateVersion, maxgaReleaseInfo.version);
    return isOver;
  }

   static Future<MaxgaReleaseInfo> _getNextVersionInfo() async {
     GithubRelease releaseVersionInfo = await GithubReleaseRepo.getLatestReleaseInfo();
    MaxgaReleaseInfo nextVersionInfo = MaxgaReleaseInfo.fromGithubRelease(releaseVersionInfo);
    return nextVersionInfo;
  }

  static Future<String> _getCurrentVersion() async {
    PackageInfo currentPackageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = currentPackageInfo.version;
    return currentVersion;
  }

  static void testClearData() async {
    await LocalStorage.setString(IgnoreUpdateVersion, '');

  }
}