import 'package:flutter/material.dart';

class IndexSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  IndexSliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 2,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(IndexSliverAppBarDelegate oldDelegate) {
    return false;
  }
}