import '../../domain/entities/trip_location.dart';

class TripLocationModel extends TripLocation {
  const TripLocationModel({
    required super.latitude,
    required super.longitude,
    required super.speedInMps,
    required super.accuracyInMeters,
    required super.recordedAt,
  });

  factory TripLocationModel.fromEntity(TripLocation location) {
    return TripLocationModel(
      latitude: location.latitude,
      longitude: location.longitude,
      speedInMps: location.speedInMps,
      accuracyInMeters: location.accuracyInMeters,
      recordedAt: location.recordedAt,
    );
  }

  factory TripLocationModel.fromMap(Map<String, Object?> map) {
    return TripLocationModel(
      latitude: (map['latitude']! as num).toDouble(),
      longitude: (map['longitude']! as num).toDouble(),
      speedInMps: (map['speed'] as num?)?.toDouble() ?? 0,
      accuracyInMeters: (map['accuracy'] as num?)?.toDouble() ?? 0,
      recordedAt:
          DateTime.fromMillisecondsSinceEpoch(map['recorded_at']! as int),
    );
  }

  Map<String, Object?> toMap(String tripId) {
    return <String, Object?>{
      'trip_id': tripId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speedInMps,
      'accuracy': accuracyInMeters,
      'recorded_at': recordedAt.millisecondsSinceEpoch,
    };
  }
}
