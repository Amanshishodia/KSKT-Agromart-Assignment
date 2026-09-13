import '../../core/constants.dart';
import '../../core/geo.dart';
import 'trip_location.dart';

class LocationFilter {
  static bool isAcceptable(TripLocation location, TripLocation? previous) {
    if (location.accuracyInMeters > TrackingRules.maxAccuracyInMeters) {
      return false;
    }
    if (location.speedInMps > TrackingRules.maxSpeedInMps) {
      return false;
    }
    if (previous == null) {
      return true;
    }

    final double seconds =
        location.recordedAt.difference(previous.recordedAt).inMilliseconds /
            1000;
    if (seconds <= 0) {
      return false;
    }

    final double distance = distanceBetween(previous, location);
    if (distance < TrackingRules.minDistanceInMeters) {
      return false;
    }

    return distance / seconds <= TrackingRules.maxSpeedInMps;
  }

  static double distanceBetween(TripLocation from, TripLocation to) {
    return distanceInMeters(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }
}
