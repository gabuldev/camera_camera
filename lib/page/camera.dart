import 'dart:io';
import 'dart:math';
import 'package:camera_camera/page/bloc/bloc_camera.dart';
import 'package:camera_camera/shared/widgets/orientation_icon.dart';
import 'package:camera_camera/shared/widgets/rotate_icon.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' as prefix0;
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

class Camera extends StatefulWidget {
  final Widget imageMask;

  const Camera({Key key, this.imageMask}) : super(key: key);
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  var bloc = BlocCamera();
  var previewH;
  var previewW;
  var screenRatio;
  var previewRatio;
  Size tmp;

  @override
  void initState() {
    super.initState();
    bloc.getCameras();
    bloc.cameras.listen((data) {
      bloc.controllCamera = CameraController(
        data[0],
        ResolutionPreset.medium,
      );
      bloc.cameraOn.sink.add(0);
      bloc.controllCamera.initialize().then((_) {
        bloc.selectCamera.sink.add(true);
      });
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var screenH = math.max(size.height, size.width);
    var screenW = math.min(size.height, size.width);
    if (tmp == null) tmp = size;
    previewH = math.max(tmp.height, tmp.width);
    previewW = math.min(tmp.height, tmp.width);
    screenRatio = screenH / screenW;
    previewRatio = previewH / previewW;

    return Scaffold(
      appBar: PreferredSize(
        child: Container(
          color: Colors.transparent,
        ),
        preferredSize: Size.fromHeight(25.0),
      ),
      backgroundColor: Colors.black,
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: StreamBuilder<File>(
                  stream: bloc.imagePath.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return OverflowBox(
                          maxHeight: size
                              .height, //screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
                          maxWidth: size.height *
                              previewRatio, //screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
                          child: Image.file(
                            snapshot.data,
                          ));
                    } else {
                      return StreamBuilder<bool>(
                          stream: bloc.selectCamera.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data) {
                                previewRatio =
                                    bloc.controllCamera.value.aspectRatio;
                                return OverflowBox(
                                  maxHeight: size
                                      .height, //screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
                                  maxWidth: size.height *
                                      previewRatio, //screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
                                  child: CameraPreview(bloc.controllCamera),
                                );
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          });
                    }
                  }),
            ),
            if (widget.imageMask != null)
              Center(
                child: widget.imageMask,
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: StreamBuilder<Object>(
                    stream: bloc.imagePath.stream,
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                CircleAvatar(
                                  child: IconButton(
                                    icon: OrientationIcon(
                                      icon: Icon(Icons.close,
                                          color: Colors.white),
                                    ),
                                    onPressed: () {
                                      bloc.deletePhoto();
                                    },
                                  ),
                                  backgroundColor: Colors.black38,
                                  radius: 25.0,
                                ),
                                CircleAvatar(
                                  child: IconButton(
                                    icon: OrientationIcon(
                                      icon: Icon(Icons.check,
                                          color: Colors.white),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(
                                          context, bloc.imagePath.value);
                                    },
                                  ),
                                  backgroundColor: Colors.black38,
                                  radius: 25.0,
                                )
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                CircleAvatar(
                                  child: IconButton(
                                    icon: OrientationIcon(
                                      icon: Icon(Icons.arrow_back_ios,
                                          color: Colors.white),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  backgroundColor: Colors.black38,
                                  radius: 25.0,
                                ),
                                CircleAvatar(
                                  child: RotateIcon(
                                            child: OrientationIcon(
                                                        icon: Icon(
                                                          Icons.cached,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      onTap: (){
                                                        bloc.changeCamera();
                                                      },
                                          ),
                                        
                                  backgroundColor: Colors.black38,
                                  radius: 25.0,
                                )
                              ],
                            );
                    }),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: StreamBuilder<Object>(
            stream: bloc.imagePath.stream,
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Container(width: 0.0, height: 0.0)
                  : FloatingActionButton(
                      onPressed: () {
                        bloc.onTakePictureButtonPressed();
                      },
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: CircleAvatar(
                              radius: 45.0,
                              backgroundColor: Colors.black38,
                              child: OrientationIcon(
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 35.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.grey.shade800,
                    );
            }),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
