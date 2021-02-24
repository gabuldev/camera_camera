import 'package:camera/camera.dart';

enum CameraSide { front, back, all, external }

extension CameraSideExt on CameraSide {
  CameraLensDirection get lensDirection {
    switch (this) {
      case CameraSide.back:
        return CameraLensDirection.back;

        break;
      case CameraSide.external:
        return CameraLensDirection.external;

        break;
      case CameraSide.front:
        return CameraLensDirection.front;

        break;
      default:
        throw "INVALID CameraLensDirection";
    }
  }
}
