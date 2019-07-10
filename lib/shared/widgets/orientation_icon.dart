import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class OrientationIcon extends StatefulWidget {
  final Icon icon;

  const OrientationIcon({Key key, this.icon}) : super(key: key);
  @override
  _OrientationIconState createState() => _OrientationIconState();
}

class _OrientationIconState extends State<OrientationIcon> with SingleTickerProviderStateMixin{
  
  Animation rotate;
  AnimationController controller;
  double angle = 0.0;

  void initAnimation(){
    controller = AnimationController(vsync: this,duration: Duration(milliseconds: 500));
      rotate = Tween(begin: angle,end: angle).animate(CurvedAnimation(parent: controller,curve: Curves.bounceOut));
        
  }

  @override
  void initState() {
    initAnimation();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return NativeDeviceOrientationReader(
      useSensor: true,
      builder: (context){
        NativeDeviceOrientation orientation = NativeDeviceOrientationReader.orientation(context);
        print(orientation.toString());
        if(orientation == NativeDeviceOrientation.portraitDown || orientation == NativeDeviceOrientation.portraitUp ){
        if(controller.isCompleted)
          controller.reverse();
        return AnimatedBuilder(
            animation: controller,
            builder: (context, snapshot) {
              return Transform.rotate(
                angle: rotate.value,
                child: widget.icon,
              );
            }
          );
        }else{
          if(orientation == NativeDeviceOrientation.landscapeLeft){
            controller.reset();
            rotate = Tween(begin: angle,end: pi/2).animate(CurvedAnimation(parent: controller,curve: Curves.bounceOut));
            controller.forward();
          return AnimatedBuilder(
            animation: controller,
            builder: (context, snapshot) {
              return Transform.rotate(
                angle: rotate.value,
                child: widget.icon,
              );
            }
          );
          }

          else if (orientation == NativeDeviceOrientation.landscapeRight){
            controller.reset();
           rotate = Tween(begin: angle,end: -pi/2).animate(CurvedAnimation(parent: controller,curve: Curves.bounceOut));
            controller.forward();
          return AnimatedBuilder(
            animation: controller,
            builder: (context, snapshot) {
              return Transform.rotate(
                angle: rotate.value,
                child: widget.icon,
              );
            }
          );
          }
        }

      },
    );
  }
}