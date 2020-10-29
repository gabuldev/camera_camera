import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_camera/src/features/camera/camera_config.dart';
import 'package:camera_camera/src/features/photo/photo_controller.dart';
import 'package:flutter/material.dart';

class PhotoView extends StatefulWidget {
  final CameraConfig config;

  PhotoView({Key key, this.config}) : super(key: key);

  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {
  PhotoController controller;

  @override
  void initState() {
    controller = PhotoController(config: widget.config);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          StreamBuilder<PhotoState>(
            stream: controller.state,
            initialData: PhotoStateEmpty(),
            builder: (context, state) {
              switch (state.data.runtimeType) {
                case PhotoStateCameraSelected:
                  {
                    return CameraPreview(controller.camera);
                  }
                  break;
                case PhotoStateTaked:
                  {
                    final path = (state.data as PhotoStateTaked).path;
                    return Image.file(File(path));
                  }
                  break;
                case PhotoStateFailure:
                  {
                    return Center(
                      child: Text("DONT AVALIABLE CAMERA YOUR DEVICE!"),
                    );
                  }
                  break;
                default:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              height: size.height * .15,
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(icon: Icon(Icons.photo), onPressed: () {}),
                  InkWell(
                    onTap: () {
                      controller.add(PhotoEventTake());
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey,
                      child: Center(
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.photo), onPressed: () {})
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
