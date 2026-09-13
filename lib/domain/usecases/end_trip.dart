import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class EndTrip {
  const EndTrip(this._repository);

  final TripRepository _repository;

  Future<Trip> call(Trip trip) => _repository.endTrip(trip);
}
