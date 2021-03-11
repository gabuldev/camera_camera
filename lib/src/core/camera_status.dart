import 'package:camera/camera.dart';
import 'package:camera_camera/src/presentation/controller/camera_camera_controller.dart';

abstract class CameraStatus {}

class CameraStatusEmpty extends CameraStatus {}

class CameraStatusFailure extends CameraStatus {
  String message;
  dynamic error;
  CameraStatusFailure({
    required this.message,
    required this.error,
  });

  @override
  String toString() => 'CameraStatusFailure(message: $message, error: $error)';
}

class CameraStatusLoading extends CameraStatus {
  CameraStatusLoading();
}

class CameraStatusSuccess extends CameraStatus {
  List<CameraDescription> cameras;
  CameraStatusSuccess({
    required this.cameras,
  });
}

class CameraStatusSelected extends CameraStatus {
  List<CameraDescription> cameras;
  int indexSelected;
  CameraStatusSelected({
    required this.cameras,
    required this.indexSelected,
  });

  CameraDescription get actual => cameras[indexSelected];
}

class CameraStatusPreview extends CameraStatus {
  CameraCameraController controller;
  List<CameraDescription> cameras;
  int indexSelected;

  CameraStatusPreview({
    required this.controller,
    required this.cameras,
    required this.indexSelected,
  });
}

extension CameraStatusExt on CameraStatus {
  CameraStatusFailure get failure => this as CameraStatusFailure;
  CameraStatusLoading get loading => this as CameraStatusLoading;
  CameraStatusSuccess get success => this as CameraStatusSuccess;
  CameraStatusSelected get selected => this as CameraStatusSelected;
  CameraStatusPreview get preview => this as CameraStatusPreview;

  dynamic when({
    dynamic Function(String message, dynamic error)? failure,
    dynamic Function()? loading,
    required dynamic Function() orElse,
    dynamic Function(List<CameraDescription> cameras)? success,
    dynamic Function(CameraDescription camera)? selected,
    dynamic Function(CameraCameraController controller)? preview,
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

      case CameraStatusLoading:
        {
          if (loading != null) {
            return loading();
          } else {
            return orElse();
          }
        }

      case CameraStatusSuccess:
        {
          if (success != null) {
            return success(this.success.cameras);
          } else {
            return orElse();
          }
        }

      case CameraStatusSelected:
        {
          if (selected != null) {
            return selected(this.selected.actual);
          } else {
            return orElse();
          }
        }

      case CameraStatusEmpty:
        {
          return orElse();
        }

      case CameraStatusPreview:
        {
          if (preview != null) {
            return preview(this.preview.controller);
          } else {
            return orElse();
          }
        }

      default:
        throw "CAMERA INVALID STATUS";
    }
  }
}
