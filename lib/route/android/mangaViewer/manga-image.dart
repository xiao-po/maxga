import 'package:extended_image/extended_image.dart';

import 'package:flutter/material.dart';
import 'package:maxga/constant/icons/maxga-icon.dart';

import 'components/manga-image-place-holder.dart';
import 'manga-tab.dart';

class MangaImage extends StatefulWidget {
  final String url;
  final int index;

  final Map<String, String> headers;

  const MangaImage({Key key, this.url, this.index, this.headers})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MangaImageState();
}

class _MangaImageState extends State<MangaImage>
    with SingleTickerProviderStateMixin {
  MangaImageAnimationListener _animationListener;
  AnimationController _animationController;
  Animation _animation;
  List<double> doubleTapScales = [1, 1.5];
  ExtendedImageGesturePageView view;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      widget.url,
      height: double.infinity,
      width: double.infinity,
      mode: ExtendedImageMode.gesture,
      headers: widget.headers,
      alignment: Alignment.center,
      fit: BoxFit.contain,
      onDoubleTap: (state) => zoomImage(state),
      loadStateChanged: (state) => buildMangeImage(state),
      initGestureConfigHandler: (state) {
        return GestureConfig(
            minScale: 1,
            animationMinScale: 0.7,
            maxScale: 3.0,
            animationMaxScale: 3.5,
            speed: 1.0,
            inertialSpeed: 100.0,
            initialScale: 1.0,
            inPageView: true,
            cacheGesture: false);
      },
    );
  }

  Widget buildMangeImage(ExtendedImageState state) {
    switch (state.extendedImageLoadState) {
      case LoadState.loading:
        return MangaImagePlaceHolder(index: widget.index);

      case LoadState.completed:
        return ExtendedImageGesture(state, null);
      case LoadState.failed:
        return buildFailedPlaceHolder(state);
      default:
        throw Error();
    }
  }

  GestureDetector buildFailedPlaceHolder(ExtendedImageState state) {
    return GestureDetector(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(
                  MaxgaIcons.imageFetchFailed,
                  size: 80,
                ),
              ),
              Text(
                '加载图片失败，点击重试',
              )
            ],
          )
        ],
      ),
      onTap: () {
        state.reLoadImage();
      },
    );
  }


  zoomImage(ExtendedImageGestureState state) {
    var pointerDownPosition = state.pointerDownPosition;
    double begin = state.gestureDetails.totalScale;
    double end;

    //remove old
    _animation?.removeListener(_animationListener);

    //stop pre
    _animationController.stop();

    //reset to use
    _animationController.reset();

    if (begin == doubleTapScales[0]) {
      end = doubleTapScales[1];
    } else {
      end = doubleTapScales[0];
    }

    _animationListener = () {
      state.handleDoubleTap(
          scale: _animation.value, doubleTapPosition: pointerDownPosition);
    };
    _animation =
        _animationController.drive(Tween<double>(begin: begin, end: end));

    _animation.addListener(_animationListener);

    _animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }
}
