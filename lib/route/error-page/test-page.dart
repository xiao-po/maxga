import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  bool isFloat = false;

  List<int> contentList = List.generate(24, (index) => index);
  int currentIndex = 0;
  ScrollController controller = ScrollController();
  int topIndex = 20;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      print(controller.offset);
    });
  }

  @override
  Widget build(BuildContext context) {

    Key forwardListKey = UniqueKey();
    Widget forwardList = SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        if (index == topIndex) {
          Future.delayed(Duration(seconds: 1), () {
            topIndex += 8;
            setState(() {       });;
          });
          return null;
        }
        return Container(
          color: index % 2 == 0 ? Colors.green : Colors.yellow,
          child: Text('fordward $index'),
          height: 100.0,
        );
      }),
      key: forwardListKey,
    );

    Widget reverseList = SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Container(
          color: index % 2 == 0 ? Colors.green : Colors.yellow,
          child: Text('reverse $index'),
          height: 100.0,
        );
      }),
    );
    return Scaffold(
        body:Scrollable(
          controller: controller,
          viewportBuilder: (BuildContext context, ViewportOffset offset) {
            return Viewport(
                offset: offset,
                center: forwardListKey,
                slivers: [
                  reverseList,
                  forwardList,
                ]);
          },
        ),
    );
  }

  onTap() {
    this.isFloat = !this.isFloat;
    setState(() {});
  }
}
