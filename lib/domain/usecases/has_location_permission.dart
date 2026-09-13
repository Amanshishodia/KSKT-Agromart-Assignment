import '../repositories/location_repository.dart';

class HasLocationPermission {
  const HasLocationPermission(this._repository);

  final LocationRepository _repository;

  Future<bool> call() => _repository.hasPermission();
}
