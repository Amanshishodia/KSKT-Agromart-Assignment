import '../entities/trip_location.dart';

abstract class LocationRepository {
  Future<bool> hasPermission();

  Future<void> openSettings();

  Future<bool> requestPermission();

  Stream<TripLocation> watchLocation();
}
