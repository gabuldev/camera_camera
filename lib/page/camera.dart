import 'dart:io';
import 'package:camera_camera/page/bloc/bloc_camera.dart';
import 'package:camera_camera/shared/widgets/orientation_icon.dart';
import 'package:camera_camera/shared/widgets/rotate_icon.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:native_device_orientation/native_device_orientation.dart';

enum CameraMode { fullscreen, normal }

class Camera extends StatefulWidget {
  final Widget imageMask;
  final CameraMode mode;

  const Camera({Key key, this.imageMask, this.mode = CameraMode.fullscreen})
      : super(key: key);
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
  Size sizeImage;

  @override
  void initState() {
    super.initState();
    bloc.getCameras();
    bloc.cameras.listen((data) {
      bloc.controllCamera = CameraController(
        data[0],
        ResolutionPreset.high,
      );
      bloc.cameraOn.sink.add(0);
      bloc.controllCamera.initialize().then((_) {
        bloc.selectCamera.sink.add(true);
      });
    });
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Size sizeImage = size;
    double width = size.width;
    double height = size.height;   
    return NativeDeviceOrientationReader(
      useSensor: true,
      builder: (context) {
        NativeDeviceOrientation orientation =
            NativeDeviceOrientationReader.orientation(context);

        if(orientation == NativeDeviceOrientation.portraitDown || orientation == NativeDeviceOrientation.portraitUp ){
          sizeImage = Size(width, height);
        }
        else{
          sizeImage = Size(height, width); 
        } 

        print(sizeImage);
       
        return Scaffold(
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
                         
                          return OrientationWidget(
                            orientation: orientation,
                            child: OverflowBox(
                            
                              maxHeight: sizeImage.height,
                              maxWidth: sizeImage.height *previewRatio,
                              child:  Image.file(snapshot.data, fit: BoxFit.cover),
                            ),
                          );
                        } else {
                          return StreamBuilder<bool>(
                              stream: bloc.selectCamera.stream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data) {
                                    previewRatio =
                                        bloc.controllCamera.value.aspectRatio;
                                        print(previewRatio);
                                    
                                    return widget.mode == CameraMode.fullscreen
                                        ? OverflowBox(
                                            maxHeight: size.height,
                                            maxWidth:
                                                size.height * previewRatio,
                                            child: CameraPreview(
                                                bloc.controllCamera),
                                          )
                                        : AspectRatio(
                                            aspectRatio: bloc.controllCamera
                                                .value.aspectRatio,
                                            child: CameraPreview(
                                                bloc.controllCamera),
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
                if (widget.mode == CameraMode.fullscreen)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: StreamBuilder<Object>(
                          stream: bloc.imagePath.stream,
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      CircleAvatar(
                                        child: IconButton(
                                          icon: OrientationWidget(
                                            orientation: orientation,
                                            child: Icon(Icons.close,
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
                                          icon: OrientationWidget(
                                            orientation: orientation,
                                            child: Icon(Icons.check,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      CircleAvatar(
                                        child: IconButton(
                                          icon: OrientationWidget(
                                            orientation: orientation,
                                            child: Icon(Icons.arrow_back_ios,
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
                                        child: IconButton(
                                          icon: OrientationWidget(
                                            orientation: orientation,
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 25,
                                            ),
                                          ),
                                          onPressed: () {
                                            sizeImage =
                                                MediaQuery.of(context).size;

                                            bloc.onTakePictureButtonPressed();
                                          },
                                        ),
                                        backgroundColor: Colors.black38,
                                        radius: 35.0,
                                      ),
                                      CircleAvatar(
                                        child: RotateIcon(
                                          child: OrientationWidget(
                                            orientation: orientation,
                                            child: Icon(
                                              Icons.cached,
                                              color: Colors.white,
                                            ),
                                          ),
                                          onTap: () {
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
          bottomNavigationBar: widget.mode == CameraMode.normal
              ? BottomAppBar(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                    child: StreamBuilder<Object>(
                        stream: bloc.imagePath.stream,
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: IconButton(
                                        icon: OrientationWidget(
                                          orientation: orientation,
                                          child: Icon(Icons.close,
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
                                        icon: OrientationWidget(
                                          orientation: orientation,
                                          child: Icon(Icons.check,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: IconButton(
                                        icon: OrientationWidget(
                                          orientation: orientation,
                                          child: Icon(Icons.arrow_back_ios,
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
                                      child: IconButton(
                                        icon: OrientationWidget(
                                          orientation: orientation,
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                          ),
                                        ),
                                        onPressed: () {
                                          sizeImage =
                                              MediaQuery.of(context).size;
                                          bloc.onTakePictureButtonPressed();
                                        },
                                      ),
                                      backgroundColor: Colors.black38,
                                      radius: 25.0,
                                    ),
                                    CircleAvatar(
                                      child: RotateIcon(
                                        child: OrientationWidget(
                                          orientation: orientation,
                                          child: Icon(
                                            Icons.cached,
                                            color: Colors.white,
                                          ),
                                        ),
                                        onTap: () {
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
              : Container(
                  width: 0.0,
                  height: 0.0,
                ),
        );
      },
    );
  }
}
