import 'dart:async';

import 'package:battery/battery.dart';
import 'package:flutter/material.dart';
import 'package:maxga/model/manga/Chapter.dart';

class MangaStatusBar extends StatefulWidget {
  final Chapter currentChapter;
  final int currentIndex;

  MangaStatusBar(this.currentChapter, this.currentIndex);

  @override
  State<StatefulWidget> createState() => _MangaStatusBarState();
}

class _MangaStatusBarState extends State<MangaStatusBar> {
  final Battery _battery = Battery();
  StreamSubscription batteryStatusSubscription;

  DateTime currentTime;
  Timer timer;
  BatteryState batteryState = BatteryState.discharging;
  int currentBattery = 100;

  @override
  void initState() {
    super.initState();
    this.updateTimeAndBattery();
    waitUpdateTimeByMinute();
    batteryStatusSubscription =
        _battery.onBatteryStateChanged.listen((state) => batteryState = state);
  }

  @override
  Widget build(BuildContext context) {
    const defaultTextStyle = TextStyle(color: Color(0xffeaeaea), fontSize: 13);
    int index = widget.currentIndex;
    if (index > widget.currentChapter.imgUrlList.length) {
      index = widget.currentChapter.imgUrlList.length;
    } else if (index == 0) {
      index = 1;
    }

    return Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
                padding:
                EdgeInsets.only(left: 10, right: 20, top: 7, bottom: 4),
                decoration: BoxDecoration(color: Color(0xff263238)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      LimitedBox(
                        maxWidth: 130,
                        child: Text(
                          '${widget.currentChapter.title} ',
                          overflow: TextOverflow.ellipsis,
                          style: defaultTextStyle,
                        ),
                      ),
                      Text(
                        ' $index/${widget.currentChapter.imgUrlList.length} '
                            ' ${currentTime.hour}:${currentTime.minute}  $currentBattery%',
                        style: defaultTextStyle,
                      ),
                    ]))
          ],
        ));
  }

  void waitUpdateTimeByMinute() {
    int restSeconds = 60 - currentTime.second;
    this.timer = Timer(Duration(seconds: restSeconds), () {
      waitUpdateTimeByMinute();
      updateTimeAndBattery();
    });
  }

  void updateTimeAndBattery() async {
    currentTime = DateTime.now();

    currentBattery = await _battery.batteryLevel;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    batteryStatusSubscription.cancel();
  }
}