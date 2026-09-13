import '../entities/trip_location.dart';

abstract class LocationRepository {
  Future<bool> requestPermission();

  Stream<TripLocation> watchLocation();
}
