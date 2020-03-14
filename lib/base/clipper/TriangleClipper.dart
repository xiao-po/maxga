import 'package:flutter/material.dart';

enum TriangleClip {
  topRight,
  topLeft,
  bottomLeft,
  bottomRight,
}

class TriangleClipper extends CustomClipper<Path> {
  final TriangleClip clip;

  const TriangleClipper(this.clip);

  @override
  Path getClip(Size size) {
    Path path = new Path();
    switch(clip) {

      case TriangleClip.topRight:
        path.moveTo(0.0, 0.0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case TriangleClip.topLeft:
        path.moveTo(0.0, 0.0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, 0);
        break;
      case TriangleClip.bottomLeft:
        path.moveTo(0.0, 0.0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case TriangleClip.bottomRight:
        path.moveTo(size.width, 0.0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
    }
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

class ClipTriangle extends StatelessWidget {
  final TriangleClip clip;
  final Widget child;

  const ClipTriangle({Key key, TriangleClip clip,@required this.child})
      : this.clip = clip ?? TriangleClip.topRight,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(clipper: TriangleClipper(clip), child: child);
  }
}
