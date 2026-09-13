import 'package:equatable/equatable.dart';

class TripLocation extends Equatable {
  const TripLocation({
    required this.latitude,
    required this.longitude,
    required this.speedInMps,
    required this.accuracyInMeters,
    required this.recordedAt,
  });

  final double latitude;
  final double longitude;
  final double speedInMps;
  final double accuracyInMeters;
  final DateTime recordedAt;

  @override
  List<Object?> get props =>
      <Object?>[latitude, longitude, speedInMps, accuracyInMeters, recordedAt];
}
