import '../entities/trip_location.dart';
import '../repositories/location_repository.dart';

class WatchLocation {
  const WatchLocation(this._repository);

  final LocationRepository _repository;

  Stream<TripLocation> call() => _repository.watchLocation();
}
