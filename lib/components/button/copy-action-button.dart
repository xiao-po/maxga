import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyActionButton extends StatelessWidget {
  const CopyActionButton({
    Key key,
    this.keyword,
    this.color,
  }) : super(key: key);

  final Color color;
  final String keyword;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: keyword));
        var scaffoldState = Scaffold.of(context);
        scaffoldState.hideCurrentSnackBar();
        scaffoldState.showSnackBar(SnackBar(
          content: const Text("已经复制关键词"),
        ));
      },
      icon: Icon(Icons.content_copy, size: 16, color: color),
    );
  }
}
