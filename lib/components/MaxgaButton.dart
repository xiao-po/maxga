import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/route/search/search-page.dart';

class MaxgaSearchButton extends StatelessWidget {
  final Color color;

  const MaxgaSearchButton({
    Key key, this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.search,
        color: color,

      ),
      onPressed: ()  {
        Navigator.push(context, MaterialPageRoute<void>(builder: (context) {
          return SearchPage();
        }));
      },
    );
  }
}
