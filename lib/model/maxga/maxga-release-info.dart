import 'package:maxga/model/github/github-release.dart';

enum MaxgaUpdateStatus {
  hasUpdate,
  mustUpdate,
  noUpdate,
}


class MaxgaReleaseInfo {
  String version;
  String description;
  String url;


  MaxgaReleaseInfo.fromGithubRelease(GithubRelease githubRelease) {
    this.version = githubRelease.tagName;
    this.description = githubRelease.body;
    this.url = githubRelease.htmlUrl;
  }

  MaxgaUpdateStatus compare(String version) {
    final nextVersion = this.version;
    final nextVersionList = _splitVersionAsNumber(nextVersion);
    final versionList = _splitVersionAsNumber(version);
    if (nextVersionList[0] > versionList[0] || (nextVersionList[1] - 5) >= versionList[1]) {
      return MaxgaUpdateStatus.mustUpdate;
    } else if (nextVersionList[1] > versionList[1] || nextVersionList[2] > versionList[2]) {
      return MaxgaUpdateStatus.hasUpdate;
    }
    return MaxgaUpdateStatus.noUpdate;
  }

  List<int> _splitVersionAsNumber(String nextVersion) => nextVersion.split('.').map((str) => int.parse(str)).toList(growable: false);
}

class CheckUpdateResult {
  final MaxgaReleaseInfo releaseInfo;
  final MaxgaUpdateStatus status;

  CheckUpdateResult(this.releaseInfo, [this.status = MaxgaUpdateStatus.noUpdate]);


}