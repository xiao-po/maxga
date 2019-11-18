import 'GithubAssets.dart';
import 'GithubAuthor.dart';

class GithubRelease {
  String url;
  String assetsUrl;
  String uploadUrl;
  String htmlUrl;
  int id;
  String nodeId;
  String tagName;
  String targetCommitish;
  String name;
  bool draft;
  GithubAuthor author;
  bool prerelease;
  String createdAt;
  String publishedAt;
  List<GithubAssets> assets;
  String tarballUrl;
  String zipballUrl;
  String body;

  GithubRelease(
      {this.url,
        this.assetsUrl,
        this.uploadUrl,
        this.htmlUrl,
        this.id,
        this.nodeId,
        this.tagName,
        this.targetCommitish,
        this.name,
        this.draft,
        this.author,
        this.prerelease,
        this.createdAt,
        this.publishedAt,
        this.assets,
        this.tarballUrl,
        this.zipballUrl,
        this.body});

  GithubRelease.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    assetsUrl = json['assets_url'];
    uploadUrl = json['upload_url'];
    htmlUrl = json['html_url'];
    id = json['id'];
    nodeId = json['node_id'];
    tagName = json['tag_name'];
    targetCommitish = json['target_commitish'];
    name = json['name'];
    draft = json['draft'];
    author =
    json['author'] != null ? GithubAuthor.fromJson(json['author']) : null;
    prerelease = json['prerelease'];
    createdAt = json['created_at'];
    publishedAt = json['published_at'];
    if (json['assets'] != null) {
      assets = List<GithubAssets>();
      json['assets'].forEach((v) {
        assets.add(GithubAssets.fromJson(v));
      });
    }
    tarballUrl = json['tarball_url'];
    zipballUrl = json['zipball_url'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['url'] = this.url;
    data['assets_url'] = this.assetsUrl;
    data['upload_url'] = this.uploadUrl;
    data['html_url'] = this.htmlUrl;
    data['id'] = this.id;
    data['node_id'] = this.nodeId;
    data['tag_name'] = this.tagName;
    data['target_commitish'] = this.targetCommitish;
    data['name'] = this.name;
    data['draft'] = this.draft;
    if (this.author != null) {
      data['author'] = this.author.toJson();
    }
    data['prerelease'] = this.prerelease;
    data['created_at'] = this.createdAt;
    data['published_at'] = this.publishedAt;
    if (this.assets != null) {
      data['assets'] = this.assets.map((v) => v.toJson()).toList();
    }
    data['tarball_url'] = this.tarballUrl;
    data['zipball_url'] = this.zipballUrl;
    data['body'] = this.body;
    return data;
  }
}





