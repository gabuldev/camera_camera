import 'package:camera_camera/camera_camera.dart';
import 'package:camera_camera/src/core/camera_notifier.dart';
import 'package:camera_camera/src/core/camera_service.dart';
import 'package:camera_camera/src/core/camera_status.dart';
import 'package:camera_camera/src/presentation/controller/camera_camera_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class CameraServiceMock extends Mock implements CameraService {}

void main() {
  final cameras = [
    CameraDescription(
        name: "test1",
        sensorOrientation: 0,
        lensDirection: CameraLensDirection.back),
    CameraDescription(
        name: "test2",
        sensorOrientation: 0,
        lensDirection: CameraLensDirection.back)
  ];
  late CameraNotifier controller;
  late CameraService service;
  late Function(String value) onFile;
  setUp(() {
    onFile = (value) {};
    service = CameraServiceMock();
    controller = CameraNotifier(
        service: service,
        onPath: onFile,
        cameraSide: CameraSide.all,
        flashModes: [FlashMode.off],
        mode: CameraMode.ratio16s9);
  });

  group("Test CameraNotifier", () {
    test("Get AvailableCameras - success", () async {
      when(() => service.getCameras()).thenAnswer((_) => Future.value(cameras));
      final actual = [
        CameraStatusLoading(),
        CameraStatusSuccess(cameras: cameras)
      ];
      final matcher = <CameraStatus>[];
      controller.listen((value) => matcher.add(value));
      await controller.getAvailableCameras();
      expect(matcher[0], actual[0]);
      expect(matcher[1], actual[1]);
    });

    test("Get AvailableCameras - failure", () async {
      when(() => service.getCameras()).thenThrow(CameraException("0", "error"));
      final actual = [
        CameraStatusLoading(),
        CameraStatusSuccess(cameras: cameras)
      ];
      final matcher = <CameraStatus>[];
      controller.listen((value) => matcher.add(value));
      await controller.getAvailableCameras();
      expect(matcher[0], actual[0]);
    });

    test("changeCamera when status is CameraStatusSuccess", () async {
      when(() => service.getCameras()).thenAnswer((_) => Future.value(cameras));
      final actual = [
        CameraStatusLoading(),
        CameraStatusSuccess(cameras: cameras),
        CameraStatusSelected(cameras: cameras, indexSelected: 0)
      ];
      final matcher = <CameraStatus>[];
      controller.listen((state) {
        matcher.add(state);
        state.when(
            success: (_) {
              controller.changeCamera();
            },
            orElse: () {});
      });

      await controller.getAvailableCameras();
      expect(matcher[0], actual[0]);
      expect(matcher[1], actual[1]);
      expect(matcher[2], actual[2]);
    });

    test("changeCamera for next camera", () async {
      when(() => service.getCameras()).thenAnswer((_) => Future.value(cameras));
      final actual = [
        CameraStatusLoading(),
        CameraStatusSuccess(cameras: cameras),
        CameraStatusSelected(cameras: cameras, indexSelected: 0),
        CameraStatusSelected(cameras: cameras, indexSelected: 1),
      ];
      final matcher = <CameraStatus>[];
      controller.listen((state) {
        matcher.add(state);
        state.when(
            success: (_) {
              controller.changeCamera();
              controller.status = CameraStatusPreview(
                  controller: CameraCameraController(
                      onPath: print,
                      flashModes: [],
                      cameraDescription: cameras[0],
                      resolutionPreset: ResolutionPreset.high),
                  cameras: cameras,
                  indexSelected: 0);
              controller.changeCamera(1);
            },
            orElse: () {});
      });

      await controller.getAvailableCameras();
      expect(matcher[0], actual[0]);
      expect(matcher[1], actual[1]);
      expect(matcher[2], actual[2]);
      expect(controller.status.selected.indexSelected, 1);
    });

    test("changeCamera for next camera and return index 0", () async {
      when(() => service.getCameras()).thenAnswer((_) => Future.value(cameras));

      final matcher = <CameraStatus>[];
      controller.listen((state) {
        matcher.add(state);
        state.when(
            success: (_) {
              controller.status = CameraStatusPreview(
                  controller: CameraCameraController(
                      onPath: print,
                      flashModes: [],
                      cameraDescription: cameras[0],
                      resolutionPreset: ResolutionPreset.high),
                  cameras: cameras,
                  indexSelected: 0);
              controller.changeCamera();
              controller.changeCamera();
              controller.changeCamera();
            },
            orElse: () {});
      });

      await controller.getAvailableCameras();

      expect(controller.status.selected.indexSelected, 0);
    });

    test("Filter cameras by CameraSide.front", () async {
      const front = CameraDescription(
          name: "front",
          sensorOrientation: 0,
          lensDirection: CameraLensDirection.front);
      const back = CameraDescription(
          name: "back",
          sensorOrientation: 0,
          lensDirection: CameraLensDirection.back);
      when(() => service.getCameras())
          .thenAnswer((_) => Future.value([front, back]));
      final notifier = CameraNotifier(
          service: service,
          onPath: onFile,
          cameraSide: CameraSide.front,
          flashModes: [FlashMode.off],
          mode: CameraMode.ratio16s9);

      await notifier.getAvailableCameras();

      expect(notifier.status.success.cameras, [front]);
    });

    test("Filter cameras by CameraSide.back", () async {
      const front = CameraDescription(
          name: "front",
          sensorOrientation: 0,
          lensDirection: CameraLensDirection.front);
      const back = CameraDescription(
          name: "back",
          sensorOrientation: 0,
          lensDirection: CameraLensDirection.back);
      when(() => service.getCameras())
          .thenAnswer((_) => Future.value([front, back]));
      final notifier = CameraNotifier(
          service: service,
          onPath: onFile,
          cameraSide: CameraSide.back,
          flashModes: [FlashMode.off],
          mode: CameraMode.ratio16s9);

      await notifier.getAvailableCameras();

      expect(notifier.status.success.cameras, [back]);
    });

    test("CameraSide.all keeps every camera", () async {
      const front = CameraDescription(
          name: "front",
          sensorOrientation: 0,
          lensDirection: CameraLensDirection.front);
      const back = CameraDescription(
          name: "back",
          sensorOrientation: 0,
          lensDirection: CameraLensDirection.back);
      when(() => service.getCameras())
          .thenAnswer((_) => Future.value([front, back]));

      await controller.getAvailableCameras();

      expect(controller.status.success.cameras, [front, back]);
    });
  });
}
