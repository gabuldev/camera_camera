import 'package:camera_camera/src/features/camera/camera_config.dart';
import 'package:camera_camera/src/features/photo/photo_view.dart';
import 'package:flutter/material.dart';

export 'package:camera_camera/src/features/camera/camera_config.dart';

class Camera extends StatelessWidget {
  final CameraConfig config;

  const Camera({
    Key key,
    this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      config: config,
    );
  }
}
