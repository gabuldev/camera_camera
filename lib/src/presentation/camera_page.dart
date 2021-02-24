import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_camera/src/core/camera_bloc.dart';
import 'package:camera_camera/src/core/camera_service.dart';
import 'package:camera_camera/src/core/camera_status.dart';
import 'package:camera_camera/src/presentation/widgets/camera_preview.dart';
import 'package:camera_camera/src/shared/entities/camera_side.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  ///Define your prefer resolution
  final ResolutionPreset resolutionPreset;

  ///CallBack function returns path your photo taken
  final void Function(String path) onFile;

  ///Define types of camera side is enabled
  final CameraSide cameraSide;

  ///Define your FlashMode accepteds
  final List<FlashMode> flashModes;

  ///Enable zoom camera ( default = true )
  final bool enableZoom;

  CameraPage({
    Key key,
    this.resolutionPreset = ResolutionPreset.ultraHigh,
    this.onFile,
    this.cameraSide = CameraSide.all,
    this.flashModes = FlashMode.values,
    this.enableZoom = true,
  }) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraBloc bloc;
  StreamSubscription _subscription;
  @override
  void initState() {
    bloc = CameraBloc(
      flashModes: widget.flashModes,
      service: CameraServiceImpl(),
      onFile: widget.onFile,
      cameraSide: widget.cameraSide,
    );
    bloc.init();
    _subscription = bloc.statusStream.listen((state) {
      return state.when(
          orElse: () {},
          selected: (camera) async {
            bloc.startPreview(widget.resolutionPreset);
          });
    });
    super.initState();
  }

  @override
  void dispose() {
    bloc.dispose();
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: StreamBuilder<CameraStatus>(
        stream: bloc.statusStream,
        initialData: CameraStatusEmpty(),
        builder: (_, snapshot) => snapshot.data.when(
            preview: (controller) => Stack(
                  children: [
                    CameraCameraPreview(
                      enableZoom: widget.enableZoom,
                      key: UniqueKey(),
                      controller: controller,
                    ),
                    if (bloc.status.preview.cameras.length > 1)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: InkWell(
                            onTap: () {
                              bloc.changeCamera();
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.black.withOpacity(0.6),
                              child: Icon(
                                Platform.isAndroid
                                    ? Icons.flip_camera_android
                                    : Icons.flip_camera_ios,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
            failure: (message, _) => Container(
                  color: Colors.black,
                  child: Text(message),
                ),
            orElse: () => Container(
                  color: Colors.black,
                )),
      ),
    );
  }
}
