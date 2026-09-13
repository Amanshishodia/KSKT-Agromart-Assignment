import 'package:flutter_test/flutter_test.dart';
import 'package:rider_tracking_app/domain/entities/location_filter.dart';
import 'package:rider_tracking_app/domain/entities/trip_location.dart';

TripLocation buildLocation({
  double latitude = 28.6139,
  double longitude = 77.2090,
  double speed = 10,
  double accuracy = 5,
  int secondsFromStart = 0,
}) {
  return TripLocation(
    latitude: latitude,
    longitude: longitude,
    speedInMps: speed,
    accuracyInMeters: accuracy,
    recordedAt: DateTime(2026, 1, 1).add(Duration(seconds: secondsFromStart)),
  );
}

void main() {
  group('LocationFilter', () {
    test('accepts the first location when accuracy is good', () {
      expect(LocationFilter.isAcceptable(buildLocation(), null), isTrue);
    });

    test('rejects a location with poor accuracy', () {
      final TripLocation location = buildLocation(accuracy: 120);
      expect(LocationFilter.isAcceptable(location, null), isFalse);
    });

    test('rejects an unrealistic speed', () {
      final TripLocation location = buildLocation(speed: 200);
      expect(LocationFilter.isAcceptable(location, null), isFalse);
    });

    test('rejects a jump to an impossible location', () {
      final TripLocation previous = buildLocation();
      final TripLocation jump = buildLocation(
        latitude: 28.7000,
        secondsFromStart: 1,
      );
      expect(LocationFilter.isAcceptable(jump, previous), isFalse);
    });

    test('rejects small movements caused by gps noise', () {
      final TripLocation previous = buildLocation();
      final TripLocation noise = buildLocation(
        latitude: 28.613920,
        secondsFromStart: 1,
      );
      expect(LocationFilter.isAcceptable(noise, previous), isFalse);
    });

    test('accepts a realistic movement', () {
      final TripLocation previous = buildLocation();
      final TripLocation next = buildLocation(
        latitude: 28.614000,
        secondsFromStart: 1,
      );
      expect(LocationFilter.isAcceptable(next, previous), isTrue);
    });
  });
}
