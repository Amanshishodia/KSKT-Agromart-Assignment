import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class GetActiveTrip {
  const GetActiveTrip(this._repository);

  final TripRepository _repository;

  Future<Trip?> call() => _repository.getActiveTrip();
}
