import 'package:camera/camera.dart';

enum CameraSide { front, back, all, external }

extension CameraSideExt on CameraSide {
  CameraLensDirection get lensDirection {
    switch (this) {
      case CameraSide.back:
        return CameraLensDirection.back;

      case CameraSide.external:
        return CameraLensDirection.external;

      case CameraSide.front:
        return CameraLensDirection.front;

      default:
        throw "INVALID CameraLensDirection";
    }
  }
}
