import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with SingleTickerProviderStateMixin {
  bool canCalcIndex = false;
  AnimationController controller;
  bool animateIsForward = false;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: ()  {
            if (!animateIsForward) {
              controller.forward();
              animateIsForward = true;
            } else {
              animateIsForward = false;
              controller.reverse();
            }
          },
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child:  AnimatedBuilder(
              animation: controller,
              builder: (context, child) => Transform.translate(offset: Offset(0, controller.value * 100), child: child,),
              child:  Text('231'),
            ),
          ),
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
