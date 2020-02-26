import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maxga/constant/icons/maxga-icon.dart';
import 'package:maxga/model/manga/MangaSource.dart';
import 'package:maxga/provider/source-viewer/source-viwer-provider.dart';

class CupertinoSourceViewer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CupertinoSourceViewerState();

}
class _CupertinoSourceViewerState extends State<CupertinoSourceViewer> with SingleTickerProviderStateMixin {
  String sourceName;
  List<MangaSourceViewerPage> tabs;
  PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child:
      SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 0),
          child: PageView(
            controller: pageController,
            children: <Widget>[
              ListView.builder(
                itemBuilder: (context, index) => Container(
                  child: Text('$index'),
                ),
              ),
              Container(
                color: Colors.white,
                child: Text('2'),
              )
            ],
          ),
        ),
      )
    );
  }

  Future<void> setMangaSource(MangaSource source) async {
    setState(() {
      sourceName = source.name;
      tabs = [
        MangaSourceViewerPage('最近更新', SourceViewType.latestUpdate, source),
        MangaSourceViewerPage('排名', SourceViewType.rank, source),
      ];
    });
    await Future.wait(
        tabs.map((state) => state.loadNextPage()).toList(growable: false));
    setState(() {});
  }

}

class _CupertinoTabBar extends StatefulWidget{
  final PageController controller;

  const _CupertinoTabBar({Key key, this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CupertinoTabBarState();

}

class _CupertinoTabBarState extends State<_CupertinoTabBar> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  PageController _controller;

  void _updateTabController() {
    final PageController newController = widget.controller ?? DefaultTabController.of(context);
    assert(() {
      if (newController == null) {
        throw FlutterError(
            'No TabController for ${widget.runtimeType}.\n'
                'When creating a ${widget.runtimeType}, you must either provide an explicit '
                'TabController using the "controller" property, or you must ensure that there '
                'is a DefaultTabController above the ${widget.runtimeType}.\n'
                'In this case, there was neither an explicit controller nor a default controller.'
        );
      }
      return true;
    }());

    if (newController == _controller)
      return;

    _controller = newController;
    if (_controller != null) {
      _controller.addListener(_handleTabControllerTick);
      _currentIndex = _controller.page?.round() ?? 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
  }

  @override
  void didUpdateWidget(_CupertinoTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateTabController();
    }
  }

  @override
  void initState() {
    super.initState();

  }

  void _handleTap(int index) {
    _controller.animateToPage(index,duration: Duration(milliseconds: 300),curve: Curves.easeInOut );
  }

  @override
  Widget build(BuildContext context) {
    final children = <GestureDetector>[];
    final testData = [
      '更新',
      '排名'
    ];
    
    for(var i = 0; i < testData.length; i++) {
      children.add(
        GestureDetector(
            behavior: HitTestBehavior.translucent,
          onTap: () => _handleTap(i),
          child: _CupertinoTabItem(
            label: testData[i],
            active: this._currentIndex == i,
          ),
        )
      );
    }

    

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTabControllerTick);
    _controller = null;
    super.dispose();
  }


  void _handleTabControllerTick() {
    if (_controller.page.round() != _currentIndex) {
      _currentIndex = _controller.page.round();
      setState(() {
        // Rebuild the tabs after a (potentially animated) index change
        // has completed.
      });
    }
  }
}

class _CupertinoTabItem extends StatelessWidget {
  final String label;
  final bool active;

  const _CupertinoTabItem({Key key, this.label, this.active = false}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    var labelWidgetList;
    final theme = Theme.of(context);
    final defaultTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
    if (this.active) {
      labelWidgetList = [
        Container(
          child: Text(label, style: defaultTextStyle.copyWith(color: theme.accentColor)),
        ),
          Container(
            child: Icon(MaxgaIcons.deltaTop, size: 10, color: theme.primaryColor,),
          )
      ];
    } else {
      labelWidgetList =  <Widget>[
        Container(
          child: Text(label, style: defaultTextStyle),
        )
      ];
    }
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 15, right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: labelWidgetList,
      ),
    );
  }

}