import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Camera {
  final double maxZoom;
  final double minZoom;
  final double? maxExposure;
  final double? minExposure;
  final double? exposureOffset;
  final double zoom;
  final FlashMode? flashMode;
  final ExposureMode? exposureMode;
  final Offset? focusPoint;
  final Offset? exposurePoint;
  Camera({
    required this.maxZoom,
    required this.minZoom,
    this.maxExposure,
    this.minExposure,
    this.exposureOffset,
    required this.zoom,
    this.flashMode,
    this.exposureMode,
    this.focusPoint,
    this.exposurePoint,
  });

  Camera copyWith({
    double? maxZoom,
    double? minZoom,
    double? maxExposure,
    double? minExposure,
    double? exposureOffset,
    double? zoom,
    FlashMode? flashMode,
    ExposureMode? exposureMode,
    Offset? focusPoint,
    Offset? exposurePoint,
  }) {
    return Camera(
      maxZoom: maxZoom ?? this.maxZoom,
      minZoom: minZoom ?? this.minZoom,
      maxExposure: maxExposure ?? this.maxExposure,
      minExposure: minExposure ?? this.minExposure,
      exposureOffset: exposureOffset ?? this.exposureOffset,
      zoom: zoom ?? this.zoom,
      flashMode: flashMode ?? this.flashMode,
      exposureMode: exposureMode ?? this.exposureMode,
      focusPoint: focusPoint ?? this.focusPoint,
      exposurePoint: exposurePoint ?? this.exposurePoint,
    );
  }

  IconData get flashModeIcon {
    switch (flashMode) {
      case FlashMode.always:
        {
          return Icons.flash_on;
        }

      case FlashMode.auto:
        {
          return Icons.flash_auto;
        }

      case FlashMode.off:
        {
          return Icons.flash_off;
        }

      case FlashMode.torch:
        {
          return FontAwesomeIcons.lightbulb;
        }

      default:
        throw "INVALID FLASH MODE";
    }
  }
}
