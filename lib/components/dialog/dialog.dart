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