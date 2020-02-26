import 'package:maxga/http/github/github-release-repo.dart';
import 'package:maxga/model/github/github-release.dart';
import 'package:maxga/model/maxga/maxga-release-info.dart';
import 'package:maxga/service/local-storage.service.dart';
import 'package:package_info/package_info.dart';

const IgnoreUpdateVersion =  'IgnoreUpdateVersion';
const CheckUpdateTime =  'CheckUpdateTime';

class UpdateService {
  static Future<MaxgaReleaseInfo> checkUpdateStatus() async {
    MaxgaReleaseInfo nextVersionInfo = await _getNextVersionInfo();
    String currentVersion = await getCurrentVersion();
    final String ignoreUpdateVersion = await LocalStorage.getString(IgnoreUpdateVersion);

    await LocalStorage.setString(CheckUpdateTime, DateTime.now().toIso8601String());

    if (nextVersionInfo.compare(currentVersion) &&( ignoreUpdateVersion == null || nextVersionInfo.compare(ignoreUpdateVersion))) {
      return nextVersionInfo;
    } else {
      return null;
    }
  }

  static Future<MaxgaReleaseInfo> checkUpdateStatusWithoutIgnore() async {
    MaxgaReleaseInfo nextVersionInfo = await _getNextVersionInfo();
    String currentVersion = await getCurrentVersion();

    if (nextVersionInfo.compare(currentVersion)) {
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

  static Future<String> getCurrentVersion() async {
    PackageInfo currentPackageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = currentPackageInfo.version;
    return currentVersion;
  }

  static void testClearData() async {
    await LocalStorage.setString(IgnoreUpdateVersion, '');

  }

  static Future<bool> isTodayChecked() async {
    var isoTimeString = await LocalStorage.getString(CheckUpdateTime);
    if (isoTimeString == null) {
      return false;
    }
    DateTime checkUpdateTime = DateTime.parse(isoTimeString);
    const OneDayTimestamp = 24 * 3600 * 1000;
    int tempValue = checkUpdateTime.millisecondsSinceEpoch % OneDayTimestamp;

    DateTime tomorrow = DateTime.fromMillisecondsSinceEpoch(checkUpdateTime.millisecondsSinceEpoch + OneDayTimestamp - tempValue);
    return tomorrow.compareTo(DateTime.now()) == 1;
  }
}