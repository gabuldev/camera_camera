import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_camera/src/features/camera/camera_config.dart';

import 'package:camera_camera/src/features/photo/photo_event.dart';
import 'package:camera_camera/src/features/photo/photo_state.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';

export 'photo_event.dart';
export 'photo_state.dart';

class PhotoController {
  final CameraConfig config;
  List<CameraDescription> cameras;
  CameraController camera;

  var _stateStream = BehaviorSubject<PhotoState>.seeded(PhotoStateEmpty());
  Stream<PhotoState> state;
  Sink<PhotoState> _stateIn;

  StreamSubscription _subscription;

  PhotoController({
    @required this.config,
  }) {
    state = _stateStream.stream;
    _stateIn = _stateStream.sink;
    _subscription = state.listen(_listenPhotoState);
    add(PhotoEventSearchCameras());
  }

  ///Load availableCameras your device
  Future<void> _loadCameras() async {
    try {
      _update(PhotoStateLoadingCameras());
      final response = await availableCameras();
      cameras = response;
      _update(PhotoStateCameraSelected(camera: cameras.first));
    } catch (e) {
      _update(PhotoStateFailure(e.toString()));
    }
  }

  ///Change cameras your device
  void _changeCamera(PhotoEventChangeCamera event) {
    _update(PhotoStateCameraSelected(camera: event.camera));
  }

  void _takePhoto() async {
    final path = await _getPath();
    await camera.takePicture(path);

    _update(PhotoStateTaked(path));
  }

  String get _timestamp => DateTime.now().millisecondsSinceEpoch.toString();
  Future<String> _getPath() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/Camera';
    await Directory(dirPath).create(recursive: true);
    return '$dirPath/$_timestamp.jpg';
  }

  ///Update state for camera
  void _update(PhotoState state) {
    _stateIn.add(state);
  }

  void add(PhotoEvent event) {
    switch (event.runtimeType) {
      case PhotoEventSearchCameras:
        {
          _loadCameras();
        }
        break;
      case PhotoEventChangeCamera:
        {
          _changeCamera(event as PhotoEventChangeCamera);
        }
        break;
      case PhotoEventTake:
        {
          _takePhoto();
        }
        break;
      default:
    }
  }

  void _starCameraController(CameraDescription selected) {
    camera = CameraController(selected, config.resolution,
        enableAudio: config.enableAudio);
  }

  void _selectCamera(CameraDescription selected) {
    if (camera == null) {
      _starCameraController(selected);
    } else {
      camera.dispose();
      _starCameraController(selected);
    }
    camera.initialize();
  }

  void _listenPhotoState(PhotoState state) {
    switch (state.runtimeType) {
      case PhotoStateCameraSelected:
        {
          final camera = (state as PhotoStateCameraSelected).camera;
          _selectCamera(camera);
        }

        break;
      default:
        print(state);
    }
  }

  void dispose() {
    _stateStream.close();
    _stateIn.close();
    _subscription.cancel();
  }
}
