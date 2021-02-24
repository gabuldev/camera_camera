import 'package:camera/camera.dart';

abstract class CameraService {
  Future<List<CameraDescription>> getCameras();
}

class CameraServiceImpl implements CameraService {
  @override
  Future<List<CameraDescription>> getCameras() {
    return availableCameras();
  }
}
