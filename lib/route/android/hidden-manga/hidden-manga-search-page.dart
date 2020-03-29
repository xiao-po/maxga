import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/components/base/manga-cover-image.dart';
import 'package:maxga/components/base/zero-divider.dart';
import 'package:maxga/components/card/card.dart';
import 'package:maxga/constant/list-load-status.dart';
import 'package:maxga/http/repo/dmzj/constants/dmzj-manga-source.dart';
import 'package:maxga/http/server/maxga-http.repo.dart';
import 'package:maxga/model/manga/manga-source.dart';
import 'package:maxga/model/maxga/hidden-manga.dart';
import 'package:maxga/route/android/mangaInfo/manga-info-page.dart';

import 'hidden-manga-page.dart';

class HiddenMangaSearchPage extends StatefulWidget {
  final String name = 'hiddenMangaSearchPage';
  @override
  State<StatefulWidget> createState() => _HiddenMangaSearchPageState();
}

class _HiddenMangaSearchPageState extends State<HiddenMangaSearchPage> {
  final searchInputController = TextEditingController();
  bool hasWords = false;
  ListLoadingStatus listLoadingStatus = ListLoadingStatus.beforeInit;
  List<HiddenManga> resultList = [];

  MangaSource mangaSource = DmzjMangaSource;


  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textStyle = theme.brightness == Brightness.light
        ? TextStyle(color: Colors.black54)
        : TextStyle(color: theme.hintColor);
    final textField = TextField(
      textInputAction: TextInputAction.search,
      controller: searchInputController,
      onChanged: (words) => this.inputChange(words),
      decoration: InputDecoration(
        hintText: '漫画名称、作者名字',
        hintStyle: textStyle,
        enabledBorder:
        UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
        focusedBorder:
        UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
      ),
    );
    Widget body;
    switch(this.listLoadingStatus) {
      case ListLoadingStatus.over:
        body = ListView.separated(
            itemBuilder: (_, index) {
              var mangaInfo = resultList[index];
              var tagPrefix = '$index';
              var mangaCoverImage = MangaCoverImage(
                source: mangaSource,
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
                  source: mangaSource,
                  manga: mangaInfo,
                ),
                cover: mangaCoverImage,
                onTap: () =>
                    this.goMangaInfoPage(mangaInfo, tagPrefix: tagPrefix),
              );
            },
            separatorBuilder: (_, i) => ZeroDivider(),
            itemCount: resultList.length
        );
        break;
      case ListLoadingStatus.error:
        body = Align(
          child: const Text('搜索隐藏漫画发生错误'),
        );
        break;
      case ListLoadingStatus.loading:
        body = Align(
          child: const SizedBox(
            width: 20,
            height: 20,
            child:  CircularProgressIndicator(),
          ),
        );
        break;
      case ListLoadingStatus.noMore:
        body = Align(
          child: const Text('没有找到你想要的漫画'),
        );
        break;
      default:
        body = Align(
          child: const Text('输入关键字搜索漫画\n目前所有的隐藏漫画都是个人收集', textAlign: TextAlign.center,),
        );
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: textField,
      ),
      body: body,
    );
  }


  Timer _debounce;
  UniqueKey searchWordsKey;

  void inputChange(String words) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    if (words.length != 0) {
      this.hasWords = true;
      _debounce = Timer(const Duration(milliseconds: 300), () {
        this.getSearchResult(words);
      });
    } else {
      this.hasWords = false;
    }

    setState(() {});
  }

  void getSearchResult(String words) async {
    var key = searchWordsKey = UniqueKey();
    try {
      setState(() {
        this.listLoadingStatus = ListLoadingStatus.loading;
      });
      var list = await MaxgaMangaHttpRepo.getHiddenManga(0, words);
      if (searchWordsKey != key) return null;
      if (list == null || list.length == 0) {
        setState(() {
          this.listLoadingStatus = ListLoadingStatus.noMore;
        });
      } else {
        setState(() {
          this.resultList = list;
          this.listLoadingStatus = ListLoadingStatus.over;
        });
      }
    } catch(e) {
      if (searchWordsKey != key) return null;

    }
  }


  goMangaInfoPage(HiddenManga mangaInfo, {String tagPrefix}) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
      return MangaInfoPage(
        title: mangaInfo.title,
        coverImageBuilder: (context) =>
            MangaCoverImage(
              source: mangaSource,
              url: mangaInfo.coverImgUrl,
              tagPrefix: '$tagPrefix${widget.name}',
              fit: BoxFit.cover,
            ),
        infoUrl: mangaInfo.infoUrl,
        sourceKey: mangaInfo.sourceKey,
      );
    }));
  }
}