import 'dart:io';

import 'package:geolocator/geolocator.dart';

import '../models/trip_location_model.dart';

abstract class LocationDataSource {
  Future<bool> requestPermission();

  Stream<TripLocationModel> watchLocation();
}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<bool> requestPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Stream<TripLocationModel> watchLocation() {
    return Geolocator.getPositionStream(locationSettings: _settings())
        .map(_toModel);
  }

  LocationSettings _settings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Trip in progress',
          notificationText: 'KSKT Agromart is recording your trip',
          enableWakeLock: true,
        ),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );
  }

  TripLocationModel _toModel(Position position) {
    return TripLocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      speedInMps: position.speed < 0 ? 0 : position.speed,
      accuracyInMeters: position.accuracy,
      recordedAt: position.timestamp,
    );
  }
}
