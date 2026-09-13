import '../../domain/entities/trip_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._dataSource);

  final LocationDataSource _dataSource;

  @override
  Future<bool> requestPermission() => _dataSource.requestPermission();

  @override
  Stream<TripLocation> watchLocation() => _dataSource.watchLocation();
}
