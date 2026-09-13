import 'package:equatable/equatable.dart';

enum TripStatus { active, completed }

class Trip extends Equatable {
  const Trip({
    required this.id,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.distanceInMeters = 0,
    this.maxSpeedInMps = 0,
  });

  final String id;
  final TripStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double distanceInMeters;
  final double maxSpeedInMps;

  bool get isActive => status == TripStatus.active;

  Duration get duration => (endedAt ?? DateTime.now()).difference(startedAt);

  Trip copyWith({
    TripStatus? status,
    DateTime? endedAt,
    double? distanceInMeters,
    double? maxSpeedInMps,
  }) {
    return Trip(
      id: id,
      status: status ?? this.status,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      maxSpeedInMps: maxSpeedInMps ?? this.maxSpeedInMps,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        status,
        startedAt,
        endedAt,
        distanceInMeters,
        maxSpeedInMps,
      ];
}
