import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/http/repo/dmzj/DmzjDataRepo.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/route/error-page/ErrorPage.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:maxga/route/search/SearchPage.dart';

class IndexPage extends StatefulWidget {
  final String name = 'index_page';

  @override
  State<StatefulWidget> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final GlobalKey scaffoldKey = GlobalKey();

  int loadStatus = 0;
  List<Manga> mangaList;

  int page = 0;

  @override
  void initState() {
    super.initState();
    this.getMangaList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text('maxga'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: this.toSearch,
          )
        ],
      ),
      body: buildIndexBody(),
    );
  }

  buildIndexBody() {
    if (loadStatus == 0) {
      return buildProcessIndicator();
    } else if (loadStatus == 1) {
      return ListView(
          children: mangaList
              .map((item) => MangaCard(
                    manga: item,
                    cover: CachedNetworkImage(
                        imageUrl: item.cover,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(strokeWidth: 2)),
                    onTap: () => this.goMangaInfoPage(item),
                  ))
              .toList());
    } else if (loadStatus == -1) {
      return ErrorPage(
        '加载失败了呢~~~，\n我们点击之后继续吧',
        onTap: this.getMangaList,
      );
    }
  }

  Center buildProcessIndicator() {
    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(),
      ),
    );
  }

  void getMangaList() async {
    try {
      mangaList = await DmzjDataRepo().getLatestUpdate(page);

      page++;
      this.loadStatus = 1;
    } catch (e) {
      this.loadStatus = -1;
      this.showSnack("getMangaList 失败， 页面： $page");
    }

    setState(() {});
  }

  void showSnack(String message) {
    Scaffold.of(scaffoldKey.currentContext).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  toSearch() {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return SearchPage();
    }));
  }

  goMangaInfoPage(Manga item) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
        id: item.id,
      );
    }));
  }
}
