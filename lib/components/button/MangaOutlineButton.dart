import 'package:flutter/material.dart';

typedef VoidCallback = void Function();

class MangaOutlineButton extends StatelessWidget {
  final Text text;
  final bool active;
  final VoidCallback onPressed;

  const MangaOutlineButton({Key key, this.text, this.active, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final activeColor = theme.accentColor;
    final textColor = theme.hintColor;
    if (active) {
      return FlatButton(
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(5.0)),
        color: activeColor,
        textColor: Colors.white,
        child: SizedBox(
          width: 100,
          child: text,
        ),
        onPressed: onPressed,
      );
    } else {
      var body = OutlineButton(
        padding: EdgeInsets.all(0),
        textColor: textColor,
        borderSide: BorderSide(
          color: textColor,
        ),
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(5.0)),
        child: SizedBox(
          width: 100,
          child: text,
        ),
        onPressed: onPressed,
      );

      return body;
    }
  }
}
