import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/base/delay.dart';
import 'package:maxga/components/base/manga-cover-image.dart';
import 'package:maxga/components/base/zero-divider.dart';
import 'package:maxga/components/card/card.dart';
import 'package:maxga/components/card/maxga-list-view-loading-footer.dart';
import 'package:maxga/constant/list-load-status.dart';
import 'package:maxga/http/repo/dmzj/constants/dmzj-manga-source.dart';
import 'package:maxga/http/server/maxga-http.repo.dart';
import 'package:maxga/manga-repo-pool.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/model/maxga/hidden-manga.dart';
import 'package:maxga/route/android/mangaInfo/manga-info-page.dart';

import 'hidden-manga-search-page.dart';

enum _LoadingStatus { over, error, loading }


class HiddenMangaPage extends StatefulWidget {
  final name = "hiddenmanga";

  @override
  State<StatefulWidget> createState() => _HiddenMangaPageState();
}

class _HiddenMangaPageState extends State<HiddenMangaPage> {
  var initStatus = _LoadingStatus.loading;

  var pageLoadStatus = ListLoadingStatus.over;
  var source =
      MangaRepoPool.getInstance().getMangaSourceByKey(DmzjMangaSourceKey);

  var page = 0;
  ScrollController controller = ScrollController();

  List<HiddenManga> hiddenMangaList = [];

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    MaxgaMangaHttpRepo.getHiddenManga(page).then((v) {
      setState(() {
        hiddenMangaList.addAll(v);
        page++;
        initStatus = _LoadingStatus.over;
      });
    }).catchError((e) {
      setState(() {
        initStatus = _LoadingStatus.error;
      });
    });
    controller.addListener(() {
      if (controller.position.extentAfter < 200) {
        loadMoreHiddenManga();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (initStatus) {
      case _LoadingStatus.loading:
        body = Container(
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        );
        break;
      case _LoadingStatus.error:
        body = Align(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("服务器接口暂时大姨妈了~~"),
              const SizedBox(height: 8.0),
              Text("如果你看见了，请联系邮箱 wly19960911@qq.com")
            ],
          ),
        );
        break;
      case _LoadingStatus.over:
        {
          body = ListView.separated(
            controller: controller,
            itemCount: hiddenMangaList.length + 1,
            itemBuilder: (context, index) {
              if (index == hiddenMangaList.length) {
                switch(pageLoadStatus) {
                  case ListLoadingStatus.error:
                    return Text('加载错误');
                    break;
                  case ListLoadingStatus.loading:
                    return MaxgaListViewLoadingFooter();
                    break;
                  case ListLoadingStatus.noMore:
                  case ListLoadingStatus.over:
                  default:
                    return null;
                }
              } else {
                var mangaInfo = hiddenMangaList[index];
                var tagPrefix = '$index';
                var mangaCoverImage = MangaCoverImage(
                  source: source,
                  url: mangaInfo.coverImgUrl,
                  tagPrefix: '$tagPrefix${widget.name}',
                );
                return MangaListTile(
                  title: Text(
                    mangaInfo.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                  ),
                  labels: [
                    mangaInfo.authors.join(' / '),
                    mangaInfo.typeList.join(' / '),
                  ]
                      .map((item) => MangaListTileLabel(text: item))
                      .toList(growable: false),
                  extra: HiddenMangaListTileExtra(
                    source: source,
                    manga: mangaInfo,
                  ),
                  cover: mangaCoverImage,
                  onTap: () =>
                      this.goMangaInfoPage(mangaInfo, tagPrefix: tagPrefix),
                );
              }
            },
            separatorBuilder: (BuildContext context, int index) =>
                ZeroDivider(),
          );
        }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("隐藏漫画"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: toHiddenMangaSearch,)
        ],
      ),
      body: body,
    );
  }

  @override
  void dispose() {
    super.dispose();
    this.controller.dispose();
  }

  void loadMoreHiddenManga() async {
    if (this.pageLoadStatus != ListLoadingStatus.over) {
      return null;
    }
    try {
      setState(() {
        this.pageLoadStatus = ListLoadingStatus.loading;
      });
      var list = await MaxgaMangaHttpRepo.getHiddenManga(page);
      if (list == null || list.length == 0) {
        setState(() {
          this.pageLoadStatus = ListLoadingStatus.noMore;
        });
      } else {
        setState(() {
          this.hiddenMangaList.addAll(list);
          this.page++;
          this.pageLoadStatus = ListLoadingStatus.over;
        });
      }
    } catch (e) {
      this.pageLoadStatus = ListLoadingStatus.error;
    }
  }

  goMangaInfoPage(HiddenManga mangaInfo, {String tagPrefix}) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
        title: mangaInfo.title,
        coverImageBuilder: (context) => MangaCoverImage(
          source: source,
          url: mangaInfo.coverImgUrl,
          tagPrefix: '$tagPrefix${widget.name}',
          fit: BoxFit.cover,
        ),
        infoUrl: mangaInfo.infoUrl,
        sourceKey: mangaInfo.sourceKey,
      );
    }));
  }

  void toHiddenMangaSearch() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => HiddenMangaSearchPage()
    ));
  }
}

class HiddenMangaListTileExtra extends StatelessWidget {
  final HiddenManga manga;
  final MangaSource source;
  final Color textColor;

  const HiddenMangaListTileExtra({
    Key key,
    @required this.manga,
    this.textColor = Colors.grey,
    @required this.source,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: textColor);
    var bottomText;
    bottomText = Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            manga.hidden ? "隐藏" : "未隐藏",
            manga.lock ? "被锁定" : "暂时没有锁定",
          ]
              .map((el) => Text(el,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle))
              .toList(growable: false),
        ));
    return MangaExtra(
      body: Text(
        source.name,
        textAlign: TextAlign.right,
        style: textStyle,
      ),
      bottom: bottomText,
    );
  }
}
