class DmzjTag {
  int tagId;
  String tagName;

  DmzjTag({this.tagId, this.tagName});

  DmzjTag.fromJson(Map<String, dynamic> json) {
    tagId = json['tag_id'];
    tagName = json['tag_name'];
  }
}
