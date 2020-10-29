import 'package:camera/camera.dart';

class PhotoEvent {}

///Search available cameras your device
class PhotoEventSearchCameras extends PhotoEvent {}

///Change cameras your device
class PhotoEventChangeCamera extends PhotoEvent {
  final CameraDescription camera;

  PhotoEventChangeCamera(this.camera);
}

///Take photo
class PhotoEventTake extends PhotoEvent {}
