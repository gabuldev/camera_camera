import 'package:camera/camera.dart';
import 'package:camera2/src/camera_bloc.dart';
import 'package:camera2/src/core/camera_service.dart';
import 'package:camera2/src/core/camera_status.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class CameraServiceMock extends Mock implements CameraService {}

void main() {
  CameraBloc controller;
  CameraService service;
  setUp(() {
    service = CameraServiceMock();
    controller = CameraBloc(service: service);
  });

  group("Test CameraBloc", () {
    test("Get AvailableCameras - success", () {
      when(service.getCameras())
          .thenAnswer((_) => Future.value([CameraDescription()]));
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
      when(service.getCameras()).thenThrow(CameraException("0", "error"));
      controller.getAvailableCameras();

      expectLater(
          controller.statusStream,
          emitsInOrder([
            isInstanceOf<CameraStatusFailure>(),
          ]));
    });

    test("changeCamera when status is CameraStatusSuccess", () async {
      when(service.getCameras())
          .thenAnswer((_) => Future.value([CameraDescription()]));
      controller.getAvailableCameras();
      controller.statusStream.listen((state) => state.when(success: (_) {
            controller.changeCamera();
          }));
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
      when(service.getCameras()).thenAnswer(
          (_) => Future.value([CameraDescription(), CameraDescription()]));
      controller.getAvailableCameras();
      controller.statusStream.listen((state) => state.when(success: (_) {
            controller.changeCamera();
            controller.changeCamera();
          }));

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
      when(service.getCameras()).thenAnswer(
          (_) => Future.value([CameraDescription(), CameraDescription()]));
      controller.getAvailableCameras();
      controller.statusStream.listen((state) => state.when(success: (_) {
            controller.changeCamera();
            controller.changeCamera();
            controller.changeCamera();
          }));

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
