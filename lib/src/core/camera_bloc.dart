import 'package:camera/camera.dart';
import 'package:camera_camera/src/presentation/controller/camera_camera_controller.dart';
import 'package:camera_camera/src/shared/entities/camera_side.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import 'camera_service.dart';
import 'camera_status.dart';

class CameraBloc {
  final CameraService service;
  final void Function(String value) onPath;
  final CameraSide cameraSide;
  final List<FlashMode> flashModes;
  CameraCameraController _cameraController;

  CameraBloc({
    @required this.service,
    @required this.onPath,
    @required this.cameraSide,
    @required this.flashModes,
  });

  //STREAM STATUS
  final statusStream =
      BehaviorSubject<CameraStatus>.seeded(CameraStatusEmpty());
  CameraStatus get status => statusStream.value;
  set status(CameraStatus status) => statusStream.sink.add(status);

  void init() async {
    await getAvailableCameras();
    status.when(
        orElse: () {},
        success: (_) {
          changeCamera();
        });
  }

  Future<void> getAvailableCameras() async {
    status = CameraStatusLoading();
    try {
      final cameras = await service.getCameras();
      if (cameraSide == CameraSide.back || cameraSide == CameraSide.front) {
        cameras.removeWhere((e) => e.lensDirection == cameraSide.lensDirection);
      }
      status = CameraStatusSuccess(cameras: cameras);
      return;
    } on CameraException catch (e) {
      status = CameraStatusFailure(message: e.description, error: e);
      return;
    }
  }

  void changeCamera([int specificIndex]) {
    if (status is CameraStatusSuccess) {
      final cameras = status.success.cameras;
      status = CameraStatusSelected(cameras: cameras, indexSelected: 0);
    } else if (status is CameraStatusPreview) {
      final cameras = status.preview.cameras;
      final index = status.preview.indexSelected;
      var indexSelected = 0;
      if (index + 1 < cameras.length) {
        indexSelected = index + 1;
      }
      status = CameraStatusSelected(
          cameras: cameras, indexSelected: specificIndex ?? indexSelected);
    } else {
      throw "CAMERA_CAMERA ERROR: Invalid changeCamera";
    }
  }

  void startPreview(
    ResolutionPreset resolutionPreset,
  ) async {
    if (_cameraController != null) {
      await _cameraController.dispose();
      await Future.delayed(Duration(milliseconds: 800));
    }
    final cameras = status.selected.cameras;
    final indexSelected = status.selected.indexSelected;
    _cameraController = CameraCameraController(
      cameraDescription: cameras[indexSelected],
      resolutionPreset: resolutionPreset,
      onPath: onPath,
      flashModes: flashModes,
    );
    status = CameraStatusPreview(
        controller: _cameraController,
        cameras: cameras,
        indexSelected: indexSelected);
  }

  void dispose() {
    statusStream.close();
  }
}
