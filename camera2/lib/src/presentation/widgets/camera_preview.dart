import 'package:flutter/material.dart';

import 'package:camera2/src/presentation/controller/camera_camera_controller.dart';
import 'package:camera2/src/presentation/controller/camera_camera_status.dart';

class CameraCameraPreview extends StatefulWidget {
  final CameraCameraController controller;
  CameraCameraPreview({
    Key key,
    @required this.controller,
  }) : super(key: key);

  @override
  _CameraCameraPreviewState createState() => _CameraCameraPreviewState();
}

class _CameraCameraPreviewState extends State<CameraCameraPreview> {
  @override
  void initState() {
    widget.controller.init();
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraCameraStatus>(
      valueListenable: widget.controller.statusNotifier,
      builder: (_, status, __) => status.when(
          success: (camera) => GestureDetector(
                onScaleUpdate: (details) {
                  widget.controller.setZoomLevel(details.scale);
                },
                child: Stack(
                  children: [
                    Center(child: widget.controller.buildPreview()),
                    Positioned(
                      bottom: 96,
                      left: 0.0,
                      right: 0.0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black.withOpacity(0.6),
                        child: IconButton(
                          icon: Center(
                            child: Text(
                              "${camera.zoom.toStringAsFixed(1)}x",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          onPressed: () {
                            widget.controller.zoomChange();
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.black.withOpacity(0.6),
                          child: IconButton(
                            onPressed: () {
                              widget.controller.changeFlashMode();
                            },
                            icon: Icon(
                              camera.flashModeIcon,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0.0,
                      right: 0.0,
                      child: InkWell(
                        onTap: () {
                          widget.controller.takePhoto();
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          failure: (message, _) => Container(
                color: Colors.black,
                child: Text(message),
              ),
          orElse: () => Container(
                color: Colors.black,
              )),
    );
  }
}