import 'package:flutter/material.dart';

class FocusWidget extends StatelessWidget {
  final Color color;

  const FocusWidget({Key key, this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
          child: ClipPath(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: color,
        ),
        clipper: RectangleModePhoto(),
      ),
    );
  }
}

class RectangleModePhoto extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    var reactPath = Path();

    reactPath.moveTo(size.width/4, size.height/4);
    reactPath.lineTo(size.width/4, size.height*3/4);
    reactPath.lineTo(size.width*3/4, size.height*3/4);
    reactPath.lineTo(size.width*3/4, size.height/4);

    path.addPath(reactPath, Offset(0,0));
    path.addRect(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height)
    );
    path.fillType = PathFillType.evenOdd;
/*
    path.moveTo(size.width/4, size.height/4);
    path.lineTo(size.width/4, size.height*3/4);
    path.lineTo(size.width*3/4, size.height*3/4);
    path.lineTo(size.width*3/4, size.height/4);
*/
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
