import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IndexEmptyPage extends StatelessWidget {
  final List<Widget> actions;

  const IndexEmptyPage({Key key, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('你没有收藏的漫画呢'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: actions,
          )
        ],
      ),
    );
  }

}