import 'package:flutter/material.dart';
import 'package:maxga/components/button/manga-outline-button.dart';
import 'package:maxga/constant/icons/antd-icon.dart';


class MangaInfoBottomBar extends StatelessWidget {
  final VoidCallback onCollect;
  final VoidCallback onResume;
  final VoidCallback onSearchMangaName;
  final bool isRead;
  final bool collected;


  const MangaInfoBottomBar(
      {Key key,
      this.onCollect,
      this.onResume,
      this.isRead = false,
      this.collected = false, this.onSearchMangaName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconActiveColor = theme.brightness == Brightness.dark
        ? Colors.orange
        : Colors.orangeAccent;

    final textColor = theme.brightness == Brightness.light ? Color(0xFF424242) : Colors.white54;
    return Container(
      decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? Theme.of(context).primaryColor
              : null,
          border: Border(top: BorderSide(width: 1, color: theme.dividerColor))),
      padding: EdgeInsets.only(left: 10, top: 2, bottom: 2, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton.icon(
                  onPressed: onCollect,
                  icon: !collected
                      ? Icon(
                          Icons.star_border,
                          color: theme.hintColor,
                        )
                      : Icon(Icons.star, color: iconActiveColor),
                  label: Text('收藏',
                      style: TextStyle(color: textColor))),
              _SearchOtherSourceButton(
                textColor: textColor,
                onPressed: onSearchMangaName,
              )
            ],
          ),
          FlatButton(
            onPressed: onResume,
            textColor: Colors.white,
            color: theme.accentColor,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(25.0)),
            child: isRead ? Text('  继续阅读  ') : Text('  开始阅读  '),
          )
        ],
      ),
    );
  }
}

class _SearchOtherSourceButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color textColor;
  const _SearchOtherSourceButton({
    Key key, this.onPressed, this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FlatButton(
      padding: EdgeInsets.only(left: 10, right: 10),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            AntdIcons.search,
            size: 18,
            color: theme.accentColor,
          ),
          const SizedBox(width: 4.0),
          Text('搜索其他网站',
              style: TextStyle(color: textColor, fontSize: 13)),
        ],
      ),
    );
  }
}
