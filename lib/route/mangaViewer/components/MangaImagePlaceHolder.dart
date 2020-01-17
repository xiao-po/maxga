import 'package:flutter/material.dart';

class MangaImagePlaceHolder extends StatelessWidget {
  final int index;

  const MangaImagePlaceHolder({
    Key key,
    @required this.index,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '$index',
          style: TextStyle(color: Colors.white38, fontSize: 40),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        )
      ],
    );
  }
}
