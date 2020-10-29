import 'package:camera/camera.dart';
export 'package:camera/camera.dart' show ResolutionPreset;

class CameraConfig {
  final bool enableAudio;
  final ResolutionPreset resolution;

  CameraConfig({this.enableAudio, this.resolution});
}
