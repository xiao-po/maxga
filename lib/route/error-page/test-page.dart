import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TestPageState();

}

class _TestPageState extends State<TestPage> {
  bool isFloat = false;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          floating: isFloat,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.threesixty),onPressed: () => this.onTap(),)
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text('test'),
            background: Center(
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: SizedBox(
                    width: 10,
                    height: 10,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: 'https://assets.yande.re/assets/logo_small-418e8d5ec0229f274edebe4af43b01aa29ed83b715991ba14bb41ba06b5b57b5.png',
                      ),
                    )
                  ),
                ),
              )
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(List.generate(15, (index) => 'index').map((txt) => Container(child: Text(txt))).toList(growable: false)),
        )
      ],
    );
  }

  onTap() {
    this.isFloat = !this.isFloat;
    setState(() {

    });
  }


}