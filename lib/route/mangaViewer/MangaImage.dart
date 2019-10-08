import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';

import 'MangaTab.dart';

class MangaImage extends StatefulWidget {
  final String url;

  const MangaImage({Key key, this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MangaImageState();

}

class _MangaImageState extends State<MangaImage> with SingleTickerProviderStateMixin  {
  Map _httpHeaders = <String, String>{
    "Referer": "http://images.dmzj.com/",
  };
  MangaImageAnimationListener _animationListener;
  AnimationController _animationController;
  Animation _animation;
  List<double> doubleTapScales = [1, 1.5];
  ExtendedImageGesturePageView view;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(milliseconds: 200),vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return  ExtendedImage.network(
      widget.url,
      height: double.infinity,
      mode: ExtendedImageMode.gesture,
      headers: _httpHeaders,
      alignment: Alignment.center,
      fit: BoxFit.contain,
      onDoubleTap: (state) => zoomImage(state),
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
//    return GestureDetector (
//      onDoubleTap: () => {},
//      child: Container(
//        height: double.infinity,
//        width: double.infinity,
//      ),
//    );
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
      //print(_animation.value);
      state.handleDoubleTap(
          scale: _animation.value,
          doubleTapPosition: pointerDownPosition);
    };
    _animation = _animationController.drive(Tween<double>(begin: begin, end: end));

    _animation.addListener(_animationListener);

    _animationController.forward();
  }
}
