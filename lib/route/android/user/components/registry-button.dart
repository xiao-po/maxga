import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget content;

  const PrimaryButton({
    Key key,
    this.onPressed, this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FlatButton(
      color: theme.accentColor,
      splashColor: Colors.black12,
      disabledColor: theme.accentColor.withAlpha(0x77),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(5.0),
      ),
      onPressed: onPressed,
      child: content,
    );
  }
}