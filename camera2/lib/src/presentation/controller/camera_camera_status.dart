import 'package:camera/camera.dart';
import 'package:camera2/src/shared/entities/camera.dart';
import 'package:flutter/material.dart';

abstract class CameraCameraStatus {}

class CameraCameraEmpty extends CameraCameraStatus {
  CameraCameraEmpty();
}

class CameraCameraLoading extends CameraCameraStatus {
  CameraCameraLoading();
}

class CameraCameraFailure extends CameraCameraStatus {
  final String message;
  final CameraException exception;
  CameraCameraFailure({
    this.message,
    this.exception,
  });
}

class CameraCameraSuccess extends CameraCameraStatus {
  final Camera camera;
  CameraCameraSuccess({
    this.camera,
  });
}

extension CameraCameraStatusExt on CameraCameraStatus {
  Camera get camera => (this as CameraCameraSuccess).camera;
  CameraCameraFailure get failure => this as CameraCameraFailure;
  CameraCameraLoading get loading => this as CameraCameraLoading;
  CameraCameraSuccess get success => this as CameraCameraSuccess;
  dynamic when({
    Function(String message, dynamic exception) failure,
    Function() loading,
    @required Function() orElse,
    Function(Camera camera) success,
  }) {
    switch (this.runtimeType) {
      case CameraCameraFailure:
        {
          if (failure != null) {
            return failure(this.failure.message, this.failure.exception);
          } else {
            return orElse();
          }
        }
        break;
      case CameraCameraLoading:
        {
          if (loading != null) {
            return loading();
          } else {
            return orElse();
          }
        }

        break;
      case CameraCameraSuccess:
        {
          if (success != null) {
            return success(this.success.camera);
          } else {
            return orElse();
          }
        }
        break;

      default:
        throw "CAMERA CAMERA (UI) INVALID STATUS";
    }
  }
}
