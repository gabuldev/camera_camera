import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera2/src/core/camera_bloc.dart';
import 'package:camera2/src/core/camera_service.dart';
import 'package:camera2/src/core/camera_status.dart';
import 'package:camera2/src/presentation/widgets/camera_preview.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  final ResolutionPreset resolutionPreset;

  CameraPage({Key key, this.resolutionPreset = ResolutionPreset.ultraHigh})
      : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final bloc = CameraBloc(service: CameraServiceImpl());
  StreamSubscription _subscription;
  @override
  void initState() {
    //  SystemChrome.setEnabledSystemUIOverlays([]);
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
                      key: UniqueKey(),
                      controller: controller,
                    ),
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
