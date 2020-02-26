import 'package:flutter/material.dart';

class MaxgaConfigListTile extends StatelessWidget {
  final Widget title;
  final Widget trailing;
  final Widget subTitle;
  final EdgeInsetsGeometry contentPadding;

  final VoidCallback onPressed;

  final VoidCallback onLongPressed;

  bool get disabled => onPressed == null && onLongPressed == null;
  const MaxgaConfigListTile(
      {Key key,
      @required this.title,
        this.subTitle,
      this.onPressed,
      Widget trailing,
      this.contentPadding =
          const EdgeInsets.only(top: 15, right: 25, left: 25, bottom: 15),
      this.onLongPressed})
      : this.trailing = trailing,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var titleText = title;
    var theme = Theme.of(context);
    var isDark = theme.brightness != Brightness.light;
    if (disabled) {
      var disableTextColor = isDark ? Colors.grey[600] : Colors.grey[500];
      titleText = AnimatedDefaultTextStyle(
        duration: kThemeChangeDuration,
        style: TextStyle(
          color: disableTextColor,
        ),
        child: titleText,
      );
    } else {
      var textColor = isDark ? Colors.grey[400] : Colors.grey[600];
      titleText = AnimatedDefaultTextStyle(
        duration: kThemeChangeDuration,
        style: TextStyle(
          color: textColor,
        ),
        child: titleText,
      );
    }
    Widget trainingText = AnimatedDefaultTextStyle(
      style: TextStyle(
        color: Colors.grey,
      ),
      duration: kThemeChangeDuration,
      child: trailing ?? const SizedBox(),
    );
    trainingText = IconTheme.merge(
        data: IconThemeData(color: Colors.grey, size: 15), child: trainingText);
    var body = Padding(
      padding: contentPadding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                titleText,
                if(subTitle != null) Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: DefaultTextStyle(
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400]
                    ),
                    child: subTitle,
                  ),
                )
              ],
            ),
          ),
          if (trailing != null) trainingText,
        ],
      ),
    );

    var backgroundColor;
    if (isDark) {
      backgroundColor = !disabled ? Colors.grey[800] : Colors.black26;
    } else {
      backgroundColor = !disabled ? Colors.white : Colors.grey[100];
    }
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onPressed,
        onLongPress: onLongPressed,
        child: body,
      ),
    );
  }
}




class ConfigListBoxDecoration extends BoxDecoration {
  ConfigListBoxDecoration(ThemeData themeData)
      : assert(themeData != null),
        super(
          boxShadow: themeData.brightness != Brightness.dark
              ? [
                  BoxShadow(
                      color: Colors.grey[300],
                      offset: Offset(0, 0),
                      blurRadius: 5),
                ]
              : null,
          border: Border(
            top: BorderSide(
                width: 1,
                color: themeData.brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[300]),
            bottom: BorderSide(
                width: 1,
                color: themeData.brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[300]),
          ),
        );
}
