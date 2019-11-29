
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
    final activeColor = Theme.of(context).accentColor;
    final disabledColor = Colors.black38;
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
      return OutlineButton(
        padding: EdgeInsets.all(0),
        textColor: disabledColor,
        borderSide: BorderSide(
          color: disabledColor,
        ),
        shape:
        RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
        child: SizedBox(
          width: 100,
          child: text,
        ),
        onPressed: onPressed,
      );
    }

  }
}
