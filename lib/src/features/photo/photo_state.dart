import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PhotoState {}

class PhotoStateEmpty extends PhotoState {}

class PhotoStateLoadingCameras extends PhotoState {}

class PhotoStateTaked extends PhotoState {
  final String path;

  PhotoStateTaked(this.path);
}

class PhotoStateCameraSelected extends PhotoState {
  final CameraDescription camera;

  PhotoStateCameraSelected({
    @required this.camera,
  });
}

class PhotoStateFailure extends PhotoState {
  final String message;

  PhotoStateFailure(this.message);
}
