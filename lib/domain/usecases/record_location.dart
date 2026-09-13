import 'dart:math';

import '../entities/location_filter.dart';
import '../entities/trip.dart';
import '../entities/trip_location.dart';
import '../entities/trip_update.dart';
import '../repositories/trip_repository.dart';

class RecordLocation {
  const RecordLocation(this._repository);

  final TripRepository _repository;

  Future<TripUpdate?> call(Trip trip, TripLocation location) async {
    final TripLocation? previous = await _repository.getLastLocation(trip.id);
    if (!LocationFilter.isAcceptable(location, previous)) {
      return null;
    }

    final double addedDistance = previous == null
        ? 0
        : LocationFilter.distanceBetween(previous, location);
    final double speed = _speedOf(location, previous, addedDistance);

    final Trip updatedTrip = trip.copyWith(
      distanceInMeters: trip.distanceInMeters + addedDistance,
      maxSpeedInMps: max(trip.maxSpeedInMps, speed),
    );

    await _repository.saveLocation(trip.id, location);
    await _repository.saveTrip(updatedTrip);
    return TripUpdate(trip: updatedTrip, speedInMps: speed);
  }

  double _speedOf(
    TripLocation location,
    TripLocation? previous,
    double distance,
  ) {
    if (location.speedInMps > 0) {
      return location.speedInMps;
    }
    if (previous == null) {
      return 0;
    }
    final double seconds =
        location.recordedAt.difference(previous.recordedAt).inMilliseconds /
            1000;
    if (seconds <= 0) {
      return 0;
    }
    return distance / seconds;
  }
}
