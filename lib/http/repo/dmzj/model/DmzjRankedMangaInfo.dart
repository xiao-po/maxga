class DmzjRankedMangaInfo {
  String comicId;
  String title;
  String authors;
  String status;
  String cover;
  String types;
  String lastUpdatetime;
  String lastUpdateChapterName;
  String comicPy;
  String num;
  String tagId;

  DmzjRankedMangaInfo(
      {this.comicId,
        this.title,
        this.authors,
        this.status,
        this.cover,
        this.types,
        this.lastUpdatetime,
        this.lastUpdateChapterName,
        this.comicPy,
        this.num,
        this.tagId});

  DmzjRankedMangaInfo.fromJson(Map<String, dynamic> json) {
    comicId = json['comic_id'];
    title = json['title'];
    authors = json['authors'];
    status = json['status'];
    cover = json['cover'];
    types = json['types'];
    lastUpdatetime = json['last_updatetime'];
    lastUpdateChapterName = json['last_update_chapter_name'];
    comicPy = json['comic_py'];
    num = json['num'];
    tagId = json['tag_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['comic_id'] = this.comicId;
    data['title'] = this.title;
    data['authors'] = this.authors;
    data['status'] = this.status;
    data['cover'] = this.cover;
    data['types'] = this.types;
    data['last_updatetime'] = this.lastUpdatetime;
    data['last_update_chapter_name'] = this.lastUpdateChapterName;
    data['comic_py'] = this.comicPy;
    data['num'] = this.num;
    data['tag_id'] = this.tagId;
    return data;
  }
}