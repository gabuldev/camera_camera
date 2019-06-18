# Camera_Camera

  

That is plugin contains native access camera your device, Android and iOS. You can take a photo or record video. Return file.

  ## Android
  You need add in **AndroidManifest.xml**
```dart
<activity
android:name="com.yalantis.ucrop.UCropActivity"
android:screenOrientation="portrait"
android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>
```

  You need add in **app/build.gradle**
```dart
minSdkVersion 21
```

## Mode Photo

  

You can take a photo and edit.

```dart

yourFunction () async {

File file = await  Navigator.push(context, MaterialPageRoute(builder: (context) => Camera()));

})

```

![](https://i.imgur.com/PcvOCan.jpg)

![](https://i.imgur.com/Pojbo7x.jpg)

  
  

# Mode Video

  

You cand record video and preview.

  

```dart

yourFunction () async {

File file = await  Navigator.push(context, MaterialPageRoute(builder: (context) => Video()));

})

```

  

## Installation

  

Add package in pubspec.yaml

  

```bash

camera_camera: current_version

```

  

## Usage

  

Import this in your page

  

```dart

import  'package:camera_camera/camera_camera.dart';

```

  

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

  

Please make sure to update tests as appropriate.

  

## License

[MIT](https://choosealicense.com/licenses/mit/)