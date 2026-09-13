import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rider_tracking_app/data/datasources/trip_local_data_source.dart';
import 'package:rider_tracking_app/data/models/trip_model.dart';
import 'package:rider_tracking_app/data/repositories/trip_repository_impl.dart';
import 'package:rider_tracking_app/domain/entities/trip.dart';

class MockTripLocalDataSource extends Mock implements TripLocalDataSource {}

void main() {
  late MockTripLocalDataSource dataSource;
  late TripRepositoryImpl repository;

  final TripModel runningTrip = TripModel(
    id: 'TRIP-1',
    status: TripStatus.active,
    startedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() => registerFallbackValue(runningTrip));

  setUp(() {
    dataSource = MockTripLocalDataSource();
    when(() => dataSource.insertTrip(any())).thenAnswer((_) async {});
    when(() => dataSource.updateTrip(any())).thenAnswer((_) async {});
    repository = TripRepositoryImpl(dataSource);
  });

  test('returns the running trip instead of creating a second one', () async {
    when(() => dataSource.getActiveTrip())
        .thenAnswer((_) async => runningTrip);

    final Trip trip = await repository.startTrip();

    expect(trip.id, runningTrip.id);
    verifyNever(() => dataSource.insertTrip(any()));
  });

  test('creates a trip when none is running', () async {
    when(() => dataSource.getActiveTrip()).thenAnswer((_) async => null);

    final Trip trip = await repository.startTrip();

    expect(trip.status, TripStatus.active);
    verify(() => dataSource.insertTrip(any())).called(1);
  });

  test('marks the trip completed when it ends', () async {
    when(() => dataSource.getActiveTrip()).thenAnswer((_) async => null);

    final Trip trip = await repository.endTrip(runningTrip);

    expect(trip.status, TripStatus.completed);
    expect(trip.endedAt, isNotNull);
    verify(() => dataSource.updateTrip(any())).called(1);
  });
}
