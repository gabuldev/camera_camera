# Camera_Camera 2.0

## New Features!

- Add Feature Zoom!
- Add Feature FlashMode
- Add Feature Change Camera, and seletec the CameraSide your prefer activated!
- CallBack for return File your photo, onFile(File yourFile)
- Removed return using Navigator.pop(context,file)
- Refactor in internal structure

![example](https://i.imgur.com/CWbwCoH.png=200x200)

# Guide for instalation

## Android

You need add in **app/build.gradle**

```dart
minSdkVersion 21
```

## IOS

You need add in **info.plist**

```dart
  	<key>NSCameraUsageDescription</key>
    <string>Can I use the camera please?</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>Can I use the mic please?</string>
```

## Flutter

Add package in pubspec.yaml

```yaml
camera_camera: current_version
```

## How to use

Camera_Camera is widget, you can use anywhere

Example 01

```dart
return Scaffold(
      body: CameraCamera(
        onFile: (file) => print(file);
      )
);
```

Example 02

```dart
return Scaffold(
      body: CameraCamera(
        onFile: (file) => print(file);
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
           Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CameraCamera(
                  onFile: (file) {
                    photos.add(file);
                    //When take foto you should close camera
                    Navigator.pop(context);
                    setState(() {});
                  },
                )))
        },
        child: Icon(Icons.camera_alt),
      ),
);
```

## Roadmap 2.0

| Feature               | Progress |
| :-------------------- | :------: |
| Zoom                  |    ✅    |
| Flash                 |    ✅    |
| CameraSide select     |    ✅    |
| nullsafety support    |    ✅    |
| Add Exposure controll |          |
| Add Easy Mode Video   |          |
| Add Gallery           |          |

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)
