import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import 'package:camera2/src/presentation/controller/camera_camera_controller.dart';

abstract class CameraStatus {}

class CameraStatusEmpty extends CameraStatus {}

class CameraStatusFailure extends CameraStatus {
  final String message;
  final dynamic error;
  CameraStatusFailure({
    this.message,
    this.error,
  });

  @override
  String toString() => 'CameraStatusFailure(message: $message, error: $error)';
}

class CameraStatusLoading extends CameraStatus {
  CameraStatusLoading();
}

class CameraStatusSuccess extends CameraStatus {
  final List<CameraDescription> cameras;
  CameraStatusSuccess({
    this.cameras,
  });
}

class CameraStatusSelected extends CameraStatus {
  final List<CameraDescription> cameras;
  final int indexSelected;
  CameraStatusSelected({
    this.cameras,
    this.indexSelected,
  });

  CameraDescription get actual => cameras[indexSelected];
}

class CameraStatusPreview extends CameraStatus {
  final CameraCameraController controller;
  final List<CameraDescription> cameras;
  final int indexSelected;

  CameraStatusPreview({
    @required this.controller,
    @required this.cameras,
    @required this.indexSelected,
  });
}

extension CameraStatusExt on CameraStatus {
  CameraStatusFailure get failure => this as CameraStatusFailure;
  CameraStatusLoading get loading => this as CameraStatusLoading;
  CameraStatusSuccess get success => this as CameraStatusSuccess;
  CameraStatusSelected get selected => this as CameraStatusSelected;
  CameraStatusPreview get preview => this as CameraStatusPreview;

  dynamic when({
    dynamic Function(String message, dynamic error) failure,
    dynamic Function() loading,
    @required dynamic Function() orElse,
    dynamic Function(List<CameraDescription> cameras) success,
    dynamic Function(CameraDescription camera) selected,
    dynamic Function(CameraCameraController controller) preview,
  }) {
    switch (this.runtimeType) {
      case CameraStatusFailure:
        {
          if (failure != null) {
            return failure(this.failure.message, this.failure.error);
          } else {
            return orElse();
          }
        }
        break;
      case CameraStatusLoading:
        {
          if (loading != null) {
            return loading();
          } else {
            return orElse();
          }
        }

        break;
      case CameraStatusSuccess:
        {
          if (success != null) {
            return success(this.success.cameras);
          } else {
            return orElse();
          }
        }
        break;
      case CameraStatusSelected:
        {
          if (selected != null) {
            return selected(this.selected.actual);
          } else {
            return orElse();
          }
        }
        break;

      case CameraStatusEmpty:
        {
          return orElse();
        }
        break;

      case CameraStatusPreview:
        {
          if (preview != null) {
            return preview(this.preview.controller);
          } else {
            return orElse();
          }
        }
        break;

      default:
        throw "CAMERA INVALID STATUS";
    }
  }
}
