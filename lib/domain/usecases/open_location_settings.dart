import '../repositories/location_repository.dart';

class OpenLocationSettings {
  const OpenLocationSettings(this._repository);

  final LocationRepository _repository;

  Future<void> call() => _repository.openSettings();
}
