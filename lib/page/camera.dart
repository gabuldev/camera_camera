import 'dart:io';
import 'package:camera_camera/page/bloc/bloc_camera.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class Camera extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  var bloc = BlocCamera();

  @override
  void initState() {
    super.initState();
    bloc.getCameras();
    bloc.cameras.listen((data) {
      bloc.controllCamera = CameraController(data[0], ResolutionPreset.medium);
      bloc.cameraOn.sink.add(0);
      bloc.controllCamera.initialize().then((_) {
        bloc.selectCamera.sink.add(true);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
          child: Transform.translate(
              offset: Offset(0.0, 0.0),
              child: Container(
                color: Colors.black,
              )),
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.12)),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(1.0),
          child: StreamBuilder<File>(
              stream: bloc.imagePath.stream,
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? Hero(tag: "1", child: Image.file(snapshot.data))
                    : Container(
                        child: StreamBuilder<bool>(
                            stream: bloc.selectCamera.stream,
                            builder: (context, snapshot) {
                              return snapshot.hasData
                                  ? snapshot.data
                                      ? AspectRatio(
                                          aspectRatio: bloc
                                              .controllCamera.value.aspectRatio,
                                          child: CameraPreview(
                                              bloc.controllCamera))
                                      : Container()
                                  : Container();
                            }),
                      );
              }),
        ),
      ),
      floatingActionButton: StreamBuilder<Object>(
          stream: bloc.imagePath.stream,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? FloatingActionButton(
                    onPressed: () {
                      bloc.cropImage();
                    },
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: CircleAvatar(
                            radius: 35.0,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.edit,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.grey.shade800,
                  )
                : FloatingActionButton(
                    onPressed: () {
                      bloc.onTakePictureButtonPressed();
                    },
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: CircleAvatar(
                            radius: 35.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.grey.shade800,
                  );
          }),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: StreamBuilder<Object>(
              stream: bloc.imagePath.stream,
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          CircleAvatar(
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () {
                                bloc.deletePhoto();
                              },
                            ),
                            backgroundColor: Colors.red,
                            radius: 25.0,
                          ),
                          CircleAvatar(
                            child: IconButton(
                              icon: Icon(
                                Icons.save,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context, bloc.imagePath.value);
                              },
                            ),
                            backgroundColor: Colors.grey.shade900,
                            radius: 25.0,
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          CircleAvatar(
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            backgroundColor: Colors.grey.shade900,
                            radius: 25.0,
                          ),
                          CircleAvatar(
                            child: IconButton(
                              icon: StreamBuilder<int>(
                                  stream: bloc.cameraOn,
                                  builder: (context, snapshot) {
                                    return snapshot.hasData
                                        ? snapshot.data == 0
                                            ? Icon(
                                                Icons.camera_front,
                                                color: Colors.white,
                                              )
                                            : Icon(
                                                Icons.camera_rear,
                                                color: Colors.white,
                                              )
                                        : Container();
                                  }),
                              onPressed: () {
                                bloc.changeCamera();
                              },
                            ),
                            backgroundColor: Colors.grey.shade900,
                            radius: 25.0,
                          )
                        ],
                      );
              }),
        ),
      ),
    );
  }
}
