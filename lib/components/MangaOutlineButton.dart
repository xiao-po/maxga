import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef VoidCallback = void Function();

class MangaOutlineButton extends StatelessWidget {
  final Text text;
  final bool active;
  final VoidCallback onPressed;

  const MangaOutlineButton(
      {Key key, this.text, this.active, this.onPressed})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).accentColor;
    return OutlineButton(
      padding: EdgeInsets.all(0),
      textColor: active ? activeColor : null,
      borderSide: BorderSide(
        color: active ? activeColor : null,
      ),
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(5.0)
      ),
      child: SizedBox(
        width: 100,
        child: text,
      ),
      onPressed: onPressed,
    );
  }
}
