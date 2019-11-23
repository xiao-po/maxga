import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/Card.dart';
import 'package:maxga/components/MangaCoverImage.dart';
import 'package:maxga/model/Manga.dart';
import 'package:maxga/provider/HistoryProvider.dart';
import 'package:maxga/route/error-page/EmptyPage.dart';
import 'package:maxga/route/mangaInfo/MangaInfoPage.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  final name = 'history_page';

  @override
  State<StatefulWidget> createState() => _HistToryPageState();
}

class _HistToryPageState extends State<HistoryPage> {
  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    List<SimpleMangaInfo> mangaHistoryList = Provider.of<List<SimpleMangaInfo>>(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: BackButton(),
        title: Text('历史记录'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => deleteHistoryList(),
          )
        ],
      ),
      body: mangaHistoryList?.length != 0 ? ListView(
          children:
          mangaHistoryList.map((item) => MangaCard(
            manga: item,
            cover: MangaCoverImage(
              url: item.coverImgUrl,
              tagPrefix: widget.name,
            ),
            onTap: () => this.goMangaInfoPage(item),
          ))
              .toList()) : EmptyPage('暂无历史记录'),
    );
  }

  goMangaInfoPage(SimpleMangaInfo item) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
          coverImageBuilder: (c) => MangaCoverImage(
                url: item.coverImgUrl,
                tagPrefix: widget.name,
                fit: BoxFit.cover,
              ),
          manga: item);
    }));
  }

  deleteHistoryList() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('是否清除历史记录'),
              actions: <Widget>[
                FlatButton(
                    child: const Text('取消'),
                    onPressed: () => Navigator.pop(context)),
                FlatButton(
                    child: const Text('清除'),
                    onPressed: () {
                      Navigator.pop(context);
                      HistoryProvider.getInstance().clearHistory();
                    }),
              ],
            ));
  }
}
