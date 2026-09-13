import 'dart:math';

double distanceInMeters(
  double startLatitude,
  double startLongitude,
  double endLatitude,
  double endLongitude,
) {
  const double earthRadius = 6371000;
  final double dLat = _toRadians(endLatitude - startLatitude);
  final double dLon = _toRadians(endLongitude - startLongitude);
  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(startLatitude)) *
          cos(_toRadians(endLatitude)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _toRadians(double degrees) => degrees * pi / 180;
