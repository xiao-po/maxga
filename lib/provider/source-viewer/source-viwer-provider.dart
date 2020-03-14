import 'package:flutter/cupertino.dart';
import 'package:maxga/base/error/maxga-http-error.dart';
import 'package:maxga/http/repo/maxga-data-http-repo.dart';
import 'package:maxga/model/manga/manga.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/model/manga/simple-manga-info.dart';
import 'package:maxga/provider/public/collection-provider.dart';

import '../../manga-repo-pool.dart';

enum SourceViewType {
  latestUpdate,
  rank,
}

enum MangaSourceViewerPageLoadState { none, loading, over, error }


class MangaSourceViewerPage {
  final MangaSource source;
  String title;
  SourceViewType type;
  MangaHttpErrorType errorType;
  ScrollController controller = ScrollController(initialScrollOffset: 0);
  List<SimpleMangaInfo> mangaList = [];
  bool initOver = false;
  bool isLast = false;
  int page = 0;
  MangaSourceViewerPageLoadState loadState =
      MangaSourceViewerPageLoadState.none;

  MangaSourceViewerPage(this.title, this.type, this.source);

  Future<List<SimpleMangaInfo>> _getMangaList(int page) async {
    MaxgaDataHttpRepo repo =
    MangaRepoPool.getInstance().getRepo(key: source.key);
    List<SimpleMangaInfo> mangaList = [];
    if (type == SourceViewType.latestUpdate) {
      mangaList = await repo.getLatestUpdate(page);
      debugPrint('更新列表已经加载完毕， 数量：${mangaList.length}');
      initOver = true;
    } else {
      mangaList = await repo.getRankedManga(page);
      debugPrint('排行列表已经加载完毕， 数量：${mangaList.length}');
      initOver = true;
    }
    var provider = CollectionProvider.getInstance();
    for(var i = 0; i < mangaList.length; i++) {
      final item = mangaList[i];
      var index = provider.collectionMangaList.indexWhere((manga) => manga.infoUrl == item.infoUrl);
      if (index >= 0) {
        mangaList[i] = item.copyWith(collected: true);
      }
    }

    return mangaList.toList();
  }

  Future<void> loadNextPage() async {
    if (loadState == MangaSourceViewerPageLoadState.loading) {
      return null;
    }
    try {
      loadState = MangaSourceViewerPageLoadState.loading;
      final mangaList = await _getMangaList(page++);
      if (mangaList.length == 0) {
        isLast = true;
      }
      this.mangaList.addAll(mangaList);
      errorType = null;
      loadState = MangaSourceViewerPageLoadState.over;
    } on MangaRepoError catch (e) {
      debugPrint(e.message);
      errorType = e.type;
      loadState = MangaSourceViewerPageLoadState.error;
      rethrow;
    }
  }

  Future<void> refreshPage() async {
    if (loadState == MangaSourceViewerPageLoadState.loading) {
      return null;
    }
    try {
      page = 0;
      loadState = MangaSourceViewerPageLoadState.loading;
      final mangaList = await _getMangaList(page++);
      if (mangaList.length == 0) {
        isLast = true;
      }
      this.mangaList = mangaList;
      errorType = null;
      loadState = MangaSourceViewerPageLoadState.over;
    } on MangaRepoError catch (e) {
      errorType = e.type;
      loadState = MangaSourceViewerPageLoadState.error;
      rethrow;
    }
  }

}
