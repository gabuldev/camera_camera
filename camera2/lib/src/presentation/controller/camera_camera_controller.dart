import 'package:camera/camera.dart';
import 'package:camera2/src/presentation/controller/camera_camera_status.dart';
import 'package:camera2/src/shared/entities/camera.dart';
import 'package:flutter/material.dart';

class CameraCameraController {
  final ResolutionPreset resolutionPreset;
  final CameraDescription cameraDescription;

  final statusNotifier = ValueNotifier<CameraCameraStatus>(CameraCameraEmpty());
  CameraCameraStatus get status => statusNotifier.value;
  set status(CameraCameraStatus status) => statusNotifier.value = status;

  CameraCameraController({
    @required this.resolutionPreset,
    @required this.cameraDescription,
  }) {
    _controller = CameraController(cameraDescription, resolutionPreset);
  }

  CameraController _controller;

  void init() async {
    status = CameraCameraLoading();
    try {
      await _controller.initialize();
      final maxZoom = await _controller.getMaxZoomLevel();
      final minZoom = await _controller.getMinZoomLevel();
      final maxExposure = await _controller.getMaxExposureOffset();
      final minExposure = await _controller.getMinExposureOffset();
      await _controller.setFlashMode(FlashMode.off);

      status = CameraCameraSuccess(
          camera: Camera(
              maxZoom: maxZoom,
              minZoom: minZoom,
              zoom: minZoom,
              maxExposure: maxExposure,
              minExposure: minExposure,
              flashMode: FlashMode.off));
    } on CameraException catch (e) {
      status = CameraCameraFailure(message: e.description, exception: e);
    }
  }

  void setFlashMode(FlashMode flashMode) async {
    final camera = status.camera.copyWith(flashMode: flashMode);
    status = CameraCameraSuccess(camera: camera);
    _controller.setFlashMode(flashMode);
  }

  void changeFlashMode() async {
    final flashMode = status.camera.flashMode;
    final list = FlashMode.values;
    var index = list.indexWhere((e) => e == flashMode);
    if (index + 1 < list.length) {
      index++;
    } else {
      index = 0;
    }
    setFlashMode(list[index]);
  }

  void setExposureMode(ExposureMode exposureMode) async {
    final camera = status.camera.copyWith(exposureMode: exposureMode);
    status = CameraCameraSuccess(camera: camera);
    _controller.setExposureMode(exposureMode);
  }

  void setFocusPoint(Offset focusPoint) async {
    final camera = status.camera.copyWith(focusPoint: focusPoint);
    status = CameraCameraSuccess(camera: camera);
    _controller.setFocusPoint(focusPoint);
  }

  void setExposurePoint(Offset exposurePoint) async {
    final camera = status.camera.copyWith(exposurePoint: exposurePoint);
    status = CameraCameraSuccess(camera: camera);
    _controller.setExposurePoint(exposurePoint);
  }

  void setExposureOffset(double exposureOffset) async {
    final camera = status.camera.copyWith(exposureOffset: exposureOffset);
    status = CameraCameraSuccess(camera: camera);
    _controller.setExposureOffset(exposureOffset);
  }

  void setZoomLevel(double zoom) async {
    if (zoom != 1) {
      var cameraZoom = double.parse(((zoom)).toStringAsFixed(1));
      if (cameraZoom >= status.camera.minZoom &&
          cameraZoom <= status.camera.maxZoom) {
        final camera = status.camera.copyWith(zoom: cameraZoom);
        status = CameraCameraSuccess(camera: camera);
        await _controller.setZoomLevel(cameraZoom);
      }
    }
  }

  void zoomChange() async {
    var zoom = status.camera.zoom;
    if (zoom + 0.5 <= status.camera.maxZoom) {
      zoom += 0.5;
    } else {
      zoom = 1.0;
    }
    final camera = status.camera.copyWith(zoom: zoom);
    status = CameraCameraSuccess(camera: camera);
    await _controller.setZoomLevel(zoom);
  }

  void zoomIn() async {
    var zoom = status.camera.zoom;
    if (zoom + 1 <= status.camera.maxZoom) {
      zoom += 1;

      final camera = status.camera.copyWith(zoom: zoom);
      status = CameraCameraSuccess(camera: camera);
      await _controller.setZoomLevel(zoom);
    }
  }

  void zoomOut() async {
    var zoom = status.camera.zoom;
    if (zoom - 1 >= status.camera.minZoom) {
      zoom -= 1;

      final camera = status.camera.copyWith(zoom: zoom);
      status = CameraCameraSuccess(camera: camera);
      await _controller.setZoomLevel(zoom);
    }
  }

  void takePhoto() async {
    final file = await _controller.takePicture();
    print(file);
  }

  Widget buildPreview() => _controller.buildPreview();

  Future<void> dispose() async {
    await _controller.dispose();
    return;
  }
}
