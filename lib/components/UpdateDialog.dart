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