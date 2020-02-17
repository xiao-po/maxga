import 'package:flutter/material.dart';

class MaxgaListTile extends StatelessWidget {
  final Widget title;
  final Widget training;
  final EdgeInsetsGeometry contentPadding;

  final VoidCallback onPressed;

  final VoidCallback onLongPressed;

  const MaxgaListTile(
      {Key key,
        @required this.title,
        this.onPressed,
        this.training,
        this.contentPadding =
        const EdgeInsets.only(top: 15, right: 25, left: 25, bottom: 15),
        this.onLongPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isBlockGesture = onPressed == null && onLongPressed == null;

    var body = Padding(
      padding: contentPadding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: title,
          ),
          if (training != null) training,
        ],
      ),
    );

    return Material(
      color: !isBlockGesture ? Colors.white : Colors.grey[200],
      child: InkWell(
        onTap: onPressed,
        onLongPress: onLongPressed,
        child: body,
      ),
    );
  }
}



class ConfigListBoxDecoration extends BoxDecoration {
  ConfigListBoxDecoration()
      : super(
    boxShadow: [
      BoxShadow(
          color: Colors.grey[300], offset: Offset(0, 0), blurRadius: 5),
    ],
    border: Border(
      top: BorderSide(width: 1, color: Colors.grey[300]),
      bottom: BorderSide(width: 1, color: Colors.grey[300]),
    ),
  );
}