part of 'trip_bloc.dart';

enum TripStatusView { initial, idle, tracking, paused, completed, error }

class TripState extends Equatable {
  const TripState({
    this.status = TripStatusView.initial,
    this.trip,
    this.lastLocation,
    this.currentSpeedInMps = 0,
    this.errorMessage,
  });

  final TripStatusView status;
  final Trip? trip;
  final TripLocation? lastLocation;
  final double currentSpeedInMps;
  final String? errorMessage;

  bool get isTracking => status == TripStatusView.tracking;

  bool get isPaused => status == TripStatusView.paused;

  bool get hasActiveTrip => trip?.isActive ?? false;

  double get distanceInMeters => trip?.distanceInMeters ?? 0;

  double get maxSpeedInMps => trip?.maxSpeedInMps ?? 0;

  TripState copyWith({
    TripStatusView? status,
    Trip? trip,
    TripLocation? lastLocation,
    double? currentSpeedInMps,
    String? errorMessage,
  }) {
    return TripState(
      status: status ?? this.status,
      trip: trip ?? this.trip,
      lastLocation: lastLocation ?? this.lastLocation,
      currentSpeedInMps: currentSpeedInMps ?? this.currentSpeedInMps,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        trip,
        lastLocation,
        currentSpeedInMps,
        errorMessage,
      ];
}
