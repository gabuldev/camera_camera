import 'package:camera/camera.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:camera_camera/src/core/camera_bloc.dart';
import 'package:camera_camera/src/core/camera_service.dart';
import 'package:camera_camera/src/core/camera_status.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class CameraServiceMock extends Mock implements CameraService {}

void main() {
  late CameraBloc controller;
  late CameraService service;
  late Function(String value) onFile;
  setUp(() {
    onFile = (value) {};
    service = CameraServiceMock();
    controller = CameraBloc(
        service: service,
        onPath: onFile,
        cameraSide: CameraSide.all,
        flashModes: [FlashMode.off]);
  });

  group("Test CameraBloc", () {
    test("Get AvailableCameras - success", () {
      when(service).calls(#getCameras).thenReturn((_) => Future.value([
            CameraDescription(
                name: "teste",
                sensorOrientation: 0,
                lensDirection: CameraLensDirection.back)
          ]));
      controller.getAvailableCameras();
      controller.statusStream.listen(print);
      expectLater(
          controller.statusStream,
          emitsInOrder([
            isInstanceOf<CameraStatusLoading>(),
            isInstanceOf<CameraStatusSuccess>(),
          ]));
    });

    test("Get AvailableCameras - failure", () {
      when(service).calls(#getCameras).thenThrow(CameraException("0", "error"));
      controller.getAvailableCameras();

      expectLater(
          controller.statusStream,
          emitsInOrder([
            isInstanceOf<CameraStatusFailure>(),
          ]));
    });

    test("changeCamera when status is CameraStatusSuccess", () async {
      when(service).calls(#getCameras).thenAnswer((_) => Future.value([
            CameraDescription(
                name: "teste",
                sensorOrientation: 0,
                lensDirection: CameraLensDirection.back)
          ]));
      controller.getAvailableCameras();
      controller.statusStream.listen((state) => state.when(
          success: (_) {
            controller.changeCamera();
          },
          orElse: () {}));
      await expectLater(
          controller.statusStream,
          emitsInOrder([
            isInstanceOf<CameraStatusLoading>(),
            isInstanceOf<CameraStatusSuccess>(),
            isInstanceOf<CameraStatusSelected>(),
          ]));
      expect(controller.status.selected.indexSelected, 1);
    });

    test("changeCamera for next camera", () async {
      when(service).calls(#getCameras).thenAnswer((_) => Future.value([
            CameraDescription(
                name: "teste",
                sensorOrientation: 0,
                lensDirection: CameraLensDirection.back),
            CameraDescription(
                name: "teste",
                sensorOrientation: 0,
                lensDirection: CameraLensDirection.back)
          ]));
      controller.getAvailableCameras();
      controller.statusStream.listen((state) => state.when(
          success: (_) {
            controller.changeCamera();
            controller.changeCamera();
          },
          orElse: () {}));

      await expectLater(
          controller.statusStream,
          emitsInOrder([
            isInstanceOf<CameraStatusLoading>(),
            isInstanceOf<CameraStatusSuccess>(),
            isInstanceOf<CameraStatusSelected>(),
            isInstanceOf<CameraStatusSelected>(),
          ]));
      expect(controller.status.selected.indexSelected, 1);
    });

    test("changeCamera for next camera and return index 0", () async {
      when(service).calls(#getCameras).thenAnswer((_) => Future.value([
            CameraDescription(
                name: "teste",
                sensorOrientation: 0,
                lensDirection: CameraLensDirection.back),
            CameraDescription(
                name: "teste",
                sensorOrientation: 0,
                lensDirection: CameraLensDirection.back)
          ]));
      controller.getAvailableCameras();
      controller.statusStream.listen((state) => state.when(
          success: (_) {
            controller.changeCamera();
            controller.changeCamera();
            controller.changeCamera();
          },
          orElse: () {}));

      await expectLater(
          controller.statusStream,
          emitsInOrder([
            isInstanceOf<CameraStatusLoading>(),
            isInstanceOf<CameraStatusSuccess>(),
            isInstanceOf<CameraStatusSelected>(),
            isInstanceOf<CameraStatusSelected>(),
            isInstanceOf<CameraStatusSelected>(),
          ]));
      expect(controller.status.selected.indexSelected, 0);
    });
  });
}
