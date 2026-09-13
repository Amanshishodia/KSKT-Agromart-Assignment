import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_location.dart';
import '../../domain/entities/trip_update.dart';
import '../../domain/usecases/end_trip.dart';
import '../../domain/usecases/get_active_trip.dart';
import '../../domain/usecases/has_location_permission.dart';
import '../../domain/usecases/open_location_settings.dart';
import '../../domain/usecases/record_location.dart';
import '../../domain/usecases/request_location_permission.dart';
import '../../domain/usecases/start_trip.dart';
import '../../domain/usecases/watch_location.dart';

part 'trip_event.dart';
part 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  TripBloc({
    required this.startTrip,
    required this.endTrip,
    required this.getActiveTrip,
    required this.recordLocation,
    required this.watchLocation,
    required this.requestLocationPermission,
    required this.hasLocationPermission,
    required this.openLocationSettings,
  }) : super(const TripState()) {
    on<TripRestored>(_onTripRestored);
    on<TripStarted>(_onTripStarted, transformer: droppable());
    on<TripResumed>(_onTripResumed, transformer: droppable());
    on<TripEnded>(_onTripEnded, transformer: droppable());
    on<TripTrackingFailed>(_onTripTrackingFailed);
    on<TripLocationReceived>(_onTripLocationReceived);
    on<TripSettingsOpened>(_onTripSettingsOpened, transformer: droppable());
  }

  final StartTrip startTrip;
  final EndTrip endTrip;
  final GetActiveTrip getActiveTrip;
  final RecordLocation recordLocation;
  final WatchLocation watchLocation;
  final RequestLocationPermission requestLocationPermission;
  final HasLocationPermission hasLocationPermission;
  final OpenLocationSettings openLocationSettings;

  StreamSubscription<TripLocation>? _locationSubscription;

  Future<void> _onTripRestored(
    TripRestored event,
    Emitter<TripState> emit,
  ) async {
    try {
      final Trip? activeTrip = await getActiveTrip();
      if (activeTrip == null) {
        emit(state.copyWith(status: TripStatusView.idle));
        return;
      }

      if (await hasLocationPermission()) {
        emit(state.copyWith(status: TripStatusView.tracking, trip: activeTrip));
        _listenToLocation();
        return;
      }

      emit(
        state.copyWith(
          status: TripStatusView.paused,
          trip: activeTrip,
          errorMessage:
              'Location access is off, so this trip is paused. Tap Resume to '
              'continue recording it.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TripStatusView.error,
          errorMessage: 'Could not load the active trip.',
        ),
      );
    }
  }

  Future<void> _onTripStarted(
    TripStarted event,
    Emitter<TripState> emit,
  ) async {
    if (state.isTracking) {
      return;
    }

    final bool granted = await requestLocationPermission();
    if (!granted) {
      emit(
        state.copyWith(
          status: TripStatusView.error,
          errorMessage: 'Location permission is required to start a trip.',
        ),
      );
      return;
    }

    try {
      final Trip trip = await startTrip();
      emit(TripState(status: TripStatusView.tracking, trip: trip));
      _listenToLocation();
    } catch (error) {
      emit(
        state.copyWith(
          status: TripStatusView.error,
          errorMessage: 'Could not start the trip.',
        ),
      );
    }
  }

  Future<void> _onTripResumed(
    TripResumed event,
    Emitter<TripState> emit,
  ) async {
    if (!state.hasActiveTrip || state.isTracking) {
      return;
    }

    final bool granted = await requestLocationPermission();
    if (!granted) {
      emit(
        state.copyWith(
          status: TripStatusView.paused,
          errorMessage:
              'Location permission is still off. Allow it in Settings to '
              'resume this trip.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: TripStatusView.tracking));
    _listenToLocation();
  }

  Future<void> _onTripEnded(TripEnded event, Emitter<TripState> emit) async {
    final Trip? trip = state.trip;
    if (trip == null || !trip.isActive) {
      return;
    }

    await _locationSubscription?.cancel();
    _locationSubscription = null;

    try {
      final Trip completedTrip = await endTrip(trip);
      emit(
        state.copyWith(
          status: TripStatusView.completed,
          trip: completedTrip,
          currentSpeedInMps: 0,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TripStatusView.error,
          errorMessage: 'Could not end the trip.',
        ),
      );
    }
  }

  Future<void> _onTripTrackingFailed(
    TripTrackingFailed event,
    Emitter<TripState> emit,
  ) async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    if (!state.hasActiveTrip) {
      return;
    }

    emit(
      state.copyWith(
        status: TripStatusView.paused,
        currentSpeedInMps: 0,
        errorMessage:
            'Location updates stopped. Check that location is on, then tap '
            'Resume.',
      ),
    );
  }

  Future<void> _onTripLocationReceived(
    TripLocationReceived event,
    Emitter<TripState> emit,
  ) async {
    final Trip? trip = state.trip;
    if (trip == null || !trip.isActive) {
      return;
    }

    try {
      final TripUpdate? update = await recordLocation(trip, event.location);
      if (update == null) {
        return;
      }

      emit(
        state.copyWith(
          trip: update.trip,
          lastLocation: event.location,
          currentSpeedInMps: update.speedInMps,
        ),
      );
    } catch (error) {
      return;
    }
  }

  Future<void> _onTripSettingsOpened(
    TripSettingsOpened event,
    Emitter<TripState> emit,
  ) async {
    await openLocationSettings();
  }

  void _listenToLocation() {
    _locationSubscription?.cancel();
    _locationSubscription = watchLocation().listen(
      (TripLocation location) => add(TripLocationReceived(location)),
      onError: (Object error) => add(const TripTrackingFailed()),
    );
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
