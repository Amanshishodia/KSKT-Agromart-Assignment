import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.status,
    required super.startedAt,
    super.endedAt,
    super.distanceInMeters,
    super.maxSpeedInMps,
  });

  factory TripModel.fromEntity(Trip trip) {
    return TripModel(
      id: trip.id,
      status: trip.status,
      startedAt: trip.startedAt,
      endedAt: trip.endedAt,
      distanceInMeters: trip.distanceInMeters,
      maxSpeedInMps: trip.maxSpeedInMps,
    );
  }

  factory TripModel.fromMap(Map<String, Object?> map) {
    return TripModel(
      id: map['id']! as String,
      status: map['status'] == TripStatus.active.name
          ? TripStatus.active
          : TripStatus.completed,
      startedAt:
          DateTime.fromMillisecondsSinceEpoch(map['started_at']! as int),
      endedAt: map['ended_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['ended_at']! as int),
      distanceInMeters: (map['distance'] as num?)?.toDouble() ?? 0,
      maxSpeedInMps: (map['max_speed'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'status': status.name,
      'started_at': startedAt.millisecondsSinceEpoch,
      'ended_at': endedAt?.millisecondsSinceEpoch,
      'distance': distanceInMeters,
      'max_speed': maxSpeedInMps,
    };
  }
}
