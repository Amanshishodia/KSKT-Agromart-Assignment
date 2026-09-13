import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rider_tracking_app/domain/entities/trip.dart';
import 'package:rider_tracking_app/domain/entities/trip_location.dart';
import 'package:rider_tracking_app/domain/usecases/end_trip.dart';
import 'package:rider_tracking_app/domain/usecases/get_active_trip.dart';
import 'package:rider_tracking_app/domain/usecases/record_location.dart';
import 'package:rider_tracking_app/domain/usecases/request_location_permission.dart';
import 'package:rider_tracking_app/domain/usecases/start_trip.dart';
import 'package:rider_tracking_app/domain/usecases/watch_location.dart';
import 'package:rider_tracking_app/presentation/bloc/trip_bloc.dart';

class MockStartTrip extends Mock implements StartTrip {}

class MockEndTrip extends Mock implements EndTrip {}

class MockGetActiveTrip extends Mock implements GetActiveTrip {}

class MockRecordLocation extends Mock implements RecordLocation {}

class MockWatchLocation extends Mock implements WatchLocation {}

class MockRequestLocationPermission extends Mock
    implements RequestLocationPermission {}

void main() {
  late MockStartTrip startTrip;
  late MockEndTrip endTrip;
  late MockGetActiveTrip getActiveTrip;
  late MockRecordLocation recordLocation;
  late MockWatchLocation watchLocation;
  late MockRequestLocationPermission requestLocationPermission;

  final Trip activeTrip = Trip(
    id: 'TRIP-1',
    status: TripStatus.active,
    startedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(activeTrip);
    registerFallbackValue(
      TripLocation(
        latitude: 0,
        longitude: 0,
        speedInMps: 0,
        accuracyInMeters: 0,
        recordedAt: DateTime(2026, 1, 1),
      ),
    );
  });

  setUp(() {
    startTrip = MockStartTrip();
    endTrip = MockEndTrip();
    getActiveTrip = MockGetActiveTrip();
    recordLocation = MockRecordLocation();
    watchLocation = MockWatchLocation();
    requestLocationPermission = MockRequestLocationPermission();

    when(() => watchLocation()).thenAnswer(
      (_) => const Stream<TripLocation>.empty(),
    );
  });

  TripBloc buildBloc() {
    return TripBloc(
      startTrip: startTrip,
      endTrip: endTrip,
      getActiveTrip: getActiveTrip,
      recordLocation: recordLocation,
      watchLocation: watchLocation,
      requestLocationPermission: requestLocationPermission,
    );
  }

  blocTest<TripBloc, TripState>(
    'starts tracking when permission is granted',
    setUp: () {
      when(() => requestLocationPermission()).thenAnswer((_) async => true);
      when(() => startTrip()).thenAnswer((_) async => activeTrip);
    },
    build: buildBloc,
    act: (TripBloc bloc) => bloc.add(const TripStarted()),
    expect: () => <TripState>[
      TripState(status: TripStatusView.tracking, trip: activeTrip),
    ],
  );

  blocTest<TripBloc, TripState>(
    'does not start a second trip when start is submitted twice',
    setUp: () {
      when(() => requestLocationPermission()).thenAnswer((_) async => true);
      when(() => startTrip()).thenAnswer((_) async => activeTrip);
    },
    build: buildBloc,
    act: (TripBloc bloc) async {
      bloc.add(const TripStarted());
      bloc.add(const TripStarted());
    },
    verify: (_) => verify(() => startTrip()).called(1),
  );

  blocTest<TripBloc, TripState>(
    'shows an error when permission is denied',
    setUp: () {
      when(() => requestLocationPermission()).thenAnswer((_) async => false);
    },
    build: buildBloc,
    act: (TripBloc bloc) => bloc.add(const TripStarted()),
    expect: () => <TripState>[
      const TripState(
        status: TripStatusView.error,
        errorMessage: 'Location permission is required to start a trip.',
      ),
    ],
    verify: (_) => verifyNever(() => startTrip()),
  );

  blocTest<TripBloc, TripState>(
    'restores an active trip on startup',
    setUp: () {
      when(() => getActiveTrip()).thenAnswer((_) async => activeTrip);
    },
    build: buildBloc,
    act: (TripBloc bloc) => bloc.add(const TripRestored()),
    expect: () => <TripState>[
      TripState(status: TripStatusView.tracking, trip: activeTrip),
    ],
  );

  blocTest<TripBloc, TripState>(
    'ends the trip and stops tracking',
    setUp: () {
      when(() => requestLocationPermission()).thenAnswer((_) async => true);
      when(() => startTrip()).thenAnswer((_) async => activeTrip);
      when(() => endTrip(any())).thenAnswer(
        (_) async => activeTrip.copyWith(
          status: TripStatus.completed,
          endedAt: DateTime(2026, 1, 1, 1),
        ),
      );
    },
    build: buildBloc,
    act: (TripBloc bloc) async {
      bloc.add(const TripStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const TripEnded());
    },
    skip: 1,
    expect: () => <TripState>[
      TripState(
        status: TripStatusView.completed,
        trip: activeTrip.copyWith(
          status: TripStatus.completed,
          endedAt: DateTime(2026, 1, 1, 1),
        ),
      ),
    ],
  );

  blocTest<TripBloc, TripState>(
    'ignores a location that the filter rejects',
    setUp: () {
      when(() => getActiveTrip()).thenAnswer((_) async => activeTrip);
      when(() => recordLocation(any(), any())).thenAnswer((_) async => null);
    },
    build: buildBloc,
    act: (TripBloc bloc) async {
      bloc.add(const TripRestored());
      await Future<void>.delayed(Duration.zero);
      bloc.add(
        TripLocationReceived(
          TripLocation(
            latitude: 28.6139,
            longitude: 77.2090,
            speedInMps: 10,
            accuracyInMeters: 200,
            recordedAt: DateTime(2026, 1, 1),
          ),
        ),
      );
    },
    expect: () => <TripState>[
      TripState(status: TripStatusView.tracking, trip: activeTrip),
    ],
  );
}
