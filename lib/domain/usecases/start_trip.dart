import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class StartTrip {
  const StartTrip(this._repository);

  final TripRepository _repository;

  Future<Trip> call() => _repository.startTrip();
}
