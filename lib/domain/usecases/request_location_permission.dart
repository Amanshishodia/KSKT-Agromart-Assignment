import '../repositories/location_repository.dart';

class RequestLocationPermission {
  const RequestLocationPermission(this._repository);

  final LocationRepository _repository;

  Future<bool> call() => _repository.requestPermission();
}
