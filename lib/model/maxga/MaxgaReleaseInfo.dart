import 'package:maxga/model/github/GithubRelease.dart';

class MaxgaReleaseInfo {
  String version;
  String description;
  String url;


  MaxgaReleaseInfo.fromGithubRelease(GithubRelease githubRelease) {
    this.version = githubRelease.tagName;
    this.description = githubRelease.body;
    this.url = githubRelease.htmlUrl;
  }

  bool compare(String version) {
    final nextVersion = this.version;
    final nextVersionList = _splitVersionNumber(nextVersion);
    final versionList = _splitVersionNumber(version);
    for (var i = 0; i < nextVersionList.length; i++ ) {
      if (nextVersionList[i] > versionList[i]) {
        return true;
      }
    }
    return false;
  }

  List<int> _splitVersionNumber(String nextVersion) => nextVersion.split('.').map((str) => int.parse(str)).toList(growable: false);
}