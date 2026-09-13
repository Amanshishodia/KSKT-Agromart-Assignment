import '../entities/trip.dart';
import '../entities/trip_location.dart';

abstract class TripRepository {
  Future<Trip> startTrip();

  Future<Trip> endTrip(Trip trip);

  Future<Trip?> getActiveTrip();

  Future<void> saveTrip(Trip trip);

  Future<void> saveLocation(String tripId, TripLocation location);

  Future<TripLocation?> getLastLocation(String tripId);
}
