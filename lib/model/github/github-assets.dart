
import 'github-uploader.dart';

class GithubAssets {
  String url;
  int id;
  String nodeId;
  String name;
  Null label;
  GithubUploader uploader;
  String contentType;
  String state;
  int size;
  int downloadCount;
  String createdAt;
  String updatedAt;
  String browserDownloadUrl;

  GithubAssets(
      {this.url,
        this.id,
        this.nodeId,
        this.name,
        this.label,
        this.uploader,
        this.contentType,
        this.state,
        this.size,
        this.downloadCount,
        this.createdAt,
        this.updatedAt,
        this.browserDownloadUrl});

  GithubAssets.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    id = json['id'];
    nodeId = json['node_id'];
    name = json['name'];
    label = json['label'];
    uploader = json['uploader'] != null
        ? GithubUploader.fromJson(json['uploader'])
        : null;
    contentType = json['content_type'];
    state = json['state'];
    size = json['size'];
    downloadCount = json['download_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    browserDownloadUrl = json['browser_download_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['url'] = this.url;
    data['id'] = this.id;
    data['node_id'] = this.nodeId;
    data['name'] = this.name;
    data['label'] = this.label;
    if (this.uploader != null) {
      data['uploader'] = this.uploader.toJson();
    }
    data['content_type'] = this.contentType;
    data['state'] = this.state;
    data['size'] = this.size;
    data['download_count'] = this.downloadCount;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['browser_download_url'] = this.browserDownloadUrl;
    return data;
  }
}