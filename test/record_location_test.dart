import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rider_tracking_app/domain/entities/trip.dart';
import 'package:rider_tracking_app/domain/entities/trip_location.dart';
import 'package:rider_tracking_app/domain/entities/trip_update.dart';
import 'package:rider_tracking_app/domain/repositories/trip_repository.dart';
import 'package:rider_tracking_app/domain/usecases/record_location.dart';

class MockTripRepository extends Mock implements TripRepository {}

void main() {
  late MockTripRepository repository;
  late RecordLocation recordLocation;

  final Trip trip = Trip(
    id: 'TRIP-1',
    status: TripStatus.active,
    startedAt: DateTime(2026, 1, 1),
  );

  TripLocation buildLocation({
    double latitude = 28.6139,
    double speed = 0,
    double accuracy = 5,
    int secondsFromStart = 0,
  }) {
    return TripLocation(
      latitude: latitude,
      longitude: 77.2090,
      speedInMps: speed,
      accuracyInMeters: accuracy,
      recordedAt: DateTime(2026, 1, 1).add(Duration(seconds: secondsFromStart)),
    );
  }

  setUpAll(() {
    registerFallbackValue(buildLocation());
    registerFallbackValue(trip);
  });

  setUp(() {
    repository = MockTripRepository();
    when(() => repository.saveLocation(any(), any())).thenAnswer((_) async {});
    when(() => repository.saveTrip(any())).thenAnswer((_) async {});
  });

  test('returns null when the filter rejects the location', () async {
    when(() => repository.getLastLocation(any())).thenAnswer((_) async => null);
    recordLocation = RecordLocation(repository);

    final TripUpdate? result =
        await recordLocation(trip, buildLocation(accuracy: 300));

    expect(result, isNull);
    verifyNever(() => repository.saveLocation(any(), any()));
  });

  test('adds the distance between two accepted locations', () async {
    when(() => repository.getLastLocation(any()))
        .thenAnswer((_) async => buildLocation());
    recordLocation = RecordLocation(repository);

    final TripUpdate? result = await recordLocation(
      trip,
      buildLocation(latitude: 28.614800, secondsFromStart: 10),
    );

    expect(result, isNotNull);
    expect(result!.trip.distanceInMeters, closeTo(100, 5));
  });

  test('derives the speed when the platform does not report one', () async {
    when(() => repository.getLastLocation(any()))
        .thenAnswer((_) async => buildLocation());
    recordLocation = RecordLocation(repository);

    final TripUpdate? result = await recordLocation(
      trip,
      buildLocation(latitude: 28.614800, secondsFromStart: 10),
    );

    expect(result!.speedInMps, closeTo(10, 0.5));
    expect(result.trip.maxSpeedInMps, closeTo(10, 0.5));
  });

  test('prefers the speed reported by the platform', () async {
    when(() => repository.getLastLocation(any()))
        .thenAnswer((_) async => buildLocation());
    recordLocation = RecordLocation(repository);

    final TripUpdate? result = await recordLocation(
      trip,
      buildLocation(latitude: 28.614800, speed: 8, secondsFromStart: 10),
    );

    expect(result!.speedInMps, 8);
  });
}
