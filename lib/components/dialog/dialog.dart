import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatelessWidget {

  final String text;
  final String url;

  final VoidCallback onIgnore;

  UpdateDialog({
    this.text,
    this.url, this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新版本已经发布'),
      content: Text(this.text),
      actions: <Widget>[
        FlatButton(
            child: const Text('忽略此版本'),
            onPressed: () {
              this.onIgnore();
              Navigator.pop(context);
            }
        ),
        FlatButton(
            child: const Text('更新'),
            onPressed: () async{
              if (await canLaunch(this.url)) {
                await launch(url);
                Navigator.pop(context);
              }
            }
        )
      ],
    );
  }
}

class ForceUpdateDialog extends StatelessWidget{
  final String url;


  ForceUpdateDialog({
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('当前版本过于落后', style: TextStyle()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('当前的版本已经落后于主线版本过多，我们需要升级之后才能正常使用。'),
          const SizedBox(height: 8.0),
          Text('因为落后过多，建议您登录同步数据之后继续升级'),
          const SizedBox(height: 8.0),
          Text('升级通知将每次打开 APP 时都会提醒。')
        ],
      ),
      actions: <Widget>[
        FlatButton(
            child: const Text('放弃升级'),
            onPressed: () {
              Navigator.pop(context);

            }
        ),
        FlatButton(
            child: const Text('更新'),
            onPressed: () async{
              if (await canLaunch(this.url)) {
                await launch(url);
              }
            }
        )
      ],
    );
  }
}


/// 准备做 card dialog 的， 暂时放弃
//enum _MangaDialogOperationType {
//  info,
//  saveCover,
//  collect,
//  cancelCollect,
//  share,
//}
//class _MangaDialogOperationItem {
//  final String title;
//  final _MangaDialogOperationType type;
//
//  const _MangaDialogOperationItem(this.title, this.type);
//}
//const _MangaDialogOperationList = <_MangaDialogOperationItem>[
//  _MangaDialogOperationItem('漫画详情', _MangaDialogOperationType.info),
//  _MangaDialogOperationItem('收藏', _MangaDialogOperationType.collect),
//  _MangaDialogOperationItem('保存封面', _MangaDialogOperationType.saveCover),
//  _MangaDialogOperationItem('分享', _MangaDialogOperationType.share),
//];
//class MangaOperationDialog extends StatelessWidget {
//  final SimpleMangaInfo mangaInfo;
//  List<_MangaDialogOperationItem> mangaDialogOperationList;
//
//  MangaOperationDialog({Key key, this.mangaInfo}): super(key: key);
//
//
//  @override
//  Widget build(BuildContext context) {
//    return AlertDialog(
//      title: Text(mangaInfo.title, overflow: TextOverflow.ellipsis),
//
//    );
//  }
//
//
//}

class OptionDialog extends StatelessWidget {
  final String title;

  final List<Widget> children;

  const OptionDialog({Key key, @required this.title, this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const optionTextStyle = TextStyle(fontSize: 18);
    return Dialog(
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(title,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            ...children
          ],
        ),
      ),
    );
  }
}
