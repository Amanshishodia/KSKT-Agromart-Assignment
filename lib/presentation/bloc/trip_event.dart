part of 'trip_bloc.dart';

sealed class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class TripStarted extends TripEvent {
  const TripStarted();
}

class TripEnded extends TripEvent {
  const TripEnded();
}

class TripResumed extends TripEvent {
  const TripResumed();
}

class TripRestored extends TripEvent {
  const TripRestored();
}

class TripSettingsOpened extends TripEvent {
  const TripSettingsOpened();
}

class TripTrackingFailed extends TripEvent {
  const TripTrackingFailed();
}

class TripLocationReceived extends TripEvent {
  const TripLocationReceived(this.location);

  final TripLocation location;

  @override
  List<Object?> get props => <Object?>[location];
}
