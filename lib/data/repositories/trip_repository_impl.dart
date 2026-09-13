import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_location.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_local_data_source.dart';
import '../models/trip_location_model.dart';
import '../models/trip_model.dart';

class TripRepositoryImpl implements TripRepository {
  const TripRepositoryImpl(this._localDataSource);

  final TripLocalDataSource _localDataSource;

  @override
  Future<Trip> startTrip() async {
    final DateTime now = DateTime.now();
    final TripModel trip = TripModel(
      id: 'TRIP-${now.millisecondsSinceEpoch}',
      status: TripStatus.active,
      startedAt: now,
    );
    await _localDataSource.insertTrip(trip);
    return trip;
  }

  @override
  Future<Trip> endTrip(Trip trip) async {
    final Trip completedTrip = trip.copyWith(
      status: TripStatus.completed,
      endedAt: DateTime.now(),
    );
    await _localDataSource.updateTrip(TripModel.fromEntity(completedTrip));
    return completedTrip;
  }

  @override
  Future<Trip?> getActiveTrip() => _localDataSource.getActiveTrip();

  @override
  Future<void> saveTrip(Trip trip) {
    return _localDataSource.updateTrip(TripModel.fromEntity(trip));
  }

  @override
  Future<void> saveLocation(String tripId, TripLocation location) {
    return _localDataSource.insertLocation(
      tripId,
      TripLocationModel.fromEntity(location),
    );
  }

  @override
  Future<TripLocation?> getLastLocation(String tripId) {
    return _localDataSource.getLastLocation(tripId);
  }
}
