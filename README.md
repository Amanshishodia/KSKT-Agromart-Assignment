# KSKT Agromart - Rider Tracking App

A Flutter app that tracks a rider's trip from **Start Trip** to **End Trip** and shows live
location, distance travelled, current speed and maximum speed.

Built with **BLoC** for state management and **clean architecture** for structure.

---

## Run it

```bash
flutter pub get
flutter run
```

```bash
flutter test
```

---

## Architecture

Three layers. Dependencies only point inwards: presentation depends on domain, data depends on
domain, and domain depends on nothing.

```
presentation   (UI + BLoC)
      |
      v
   domain      (entities, repository interfaces, use cases)
      ^
      |
    data       (models, data sources, repository implementations)
```

### Domain layer - the business rules

| File | Purpose |
| --- | --- |
| `entities/trip.dart` | A trip: id, status, start/end time, distance, max speed |
| `entities/trip_location.dart` | One GPS reading |
| `entities/location_filter.dart` | Decides whether a GPS reading can be trusted |
| `repositories/` | Interfaces only - no Flutter, no plugins, no SQLite |
| `usecases/` | One class per action: `StartTrip`, `EndTrip`, `GetActiveTrip`, `RecordLocation`, `WatchLocation`, `RequestLocationPermission` |

The domain layer imports nothing from Flutter or any plugin, which is what makes it testable with
plain unit tests.

### Data layer - how it is actually done

| File | Purpose |
| --- | --- |
| `datasources/location_data_source.dart` | Talks to `geolocator` |
| `datasources/trip_local_data_source.dart` | Talks to `sqflite` |
| `models/` | Extend the entities and add `fromMap` / `toMap` |
| `repositories/` | Implement the domain interfaces using the data sources |

### Presentation layer - BLoC

| Piece | Purpose |
| --- | --- |
| `TripEvent` | `TripStarted`, `TripEnded`, `TripRestored`, `TripLocationReceived` |
| `TripState` | status, trip, last location, current speed, error message |
| `TripBloc` | Handles events, calls use cases, emits new states |
| `TripPage` | `BlocConsumer` rebuilds the UI from the state |

Everything is wired together in `main.dart` with constructor injection, so every dependency can be
followed by reading one file.

---

## How a trip works

**Start Trip**

1. The UI sends `TripStarted` to the bloc.
2. The bloc calls `RequestLocationPermission`. If it is denied, it emits an error state.
3. The bloc calls `StartTrip`, which creates a trip row in SQLite.
4. The bloc subscribes to `WatchLocation` and emits `tracking`.

**Every GPS update**

1. The stream adds a `TripLocationReceived` event.
2. The bloc calls `RecordLocation`, which loads the last saved location, asks `LocationFilter`
   whether the new reading is acceptable, adds the distance between the two points, updates the
   maximum speed, and saves both the location and the trip.
3. If the filter rejected the reading, nothing is saved and no state is emitted.
4. Otherwise the bloc emits a new state and the UI updates.

**End Trip**

1. The UI sends `TripEnded`.
2. The bloc cancels the location subscription.
3. The bloc calls `EndTrip`, which marks the trip completed in SQLite.

---

## Handling bad GPS data

`LocationFilter` applies three rules before a reading is counted:

| Rule | Reason |
| --- | --- |
| Accuracy must be better than 50 m | A reading with a 200 m error is not worth counting |
| Speed must be under 50 m/s (180 km/h) | A rider cannot go faster than this |
| The implied speed between two readings must also be under 50 m/s | Catches a GPS jump: if the phone "teleports" 2 km in one second, the reading is dropped instead of adding 2 km to the trip |

There is also a minimum movement of 5 m. When the rider stands still, GPS drifts by a few metres,
and without this rule a parked bike would slowly gain distance.

Speed comes from the platform when it reports one, because that value is measured by the GPS chip.
When it does not (some devices and the iOS simulator report nothing), `RecordLocation` derives it
from distance divided by time, so current speed and maximum speed still work.

Because a rejected reading is simply skipped, a jump away from the route and back costs only one
reading: the next good reading is compared against the last *accepted* one, so the distance and the
maximum speed stay correct.

---

## Foreground, background and terminated

| Situation | Behaviour |
| --- | --- |
| App open | The location stream runs in the app |
| Background / screen locked - Android | `geolocator` runs a foreground service with an ongoing notification, so updates keep arriving |
| Background / screen locked - iOS | `UIBackgroundModes: location` plus `allowBackgroundLocationUpdates` keeps updates coming |
| App terminated (swiped away) | Tracking stops. The active trip stays in SQLite, and when the app is opened again `TripRestored` loads it and tracking continues |

That last row is the known limitation of this simple version. Neither platform lets an ordinary app
keep running after the user swipes it away without extra machinery:

- **Android** would need a foreground service running in its own isolate (for example
  `flutter_background_service`) so it survives the task being removed, plus a boot receiver to
  restart after a reboot.
- **iOS** has no equivalent of a foreground service. The usual approach is significant location
  change monitoring, which lets the system relaunch the app in the background when the rider moves,
  but only at roughly 500 m granularity and with no guarantee from Apple.

The trip itself is never lost, because every accepted point is written to SQLite immediately and the
trip is resumed the next time the app is opened.

---

## Offline support

There is no backend, so the app works offline by design. Every trip and every accepted location is
written to a local SQLite database, so no internet connection is needed and nothing is lost if the
app is closed or the phone restarts.

If a backend were added, the next step would be a `synced` flag on each location row and a worker
that uploads the unsynced rows whenever connectivity returns.

---

## Permissions

| Platform | Permission |
| --- | --- |
| Android | `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`, `POST_NOTIFICATIONS` |
| iOS | `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`, `UIBackgroundModes: location` |

For background tracking the rider has to choose **Allow all the time**.

---

## Tests

15 tests, no device needed.

| File | Covers |
| --- | --- |
| `test/location_filter_test.dart` | Poor accuracy, unrealistic speed, a GPS jump, standing-still noise, a valid move |
| `test/record_location_test.dart` | Rejected readings are not saved, distance is added, speed is derived or taken from the platform |
| `test/trip_bloc_test.dart` | Start with and without permission, restore an active trip, end a trip, ignore a rejected location |

---

## Folder structure

```
lib/
  core/
    constants.dart
    geo.dart
  domain/
    entities/
    repositories/
    usecases/
  data/
    models/
    datasources/
    repositories/
  presentation/
    bloc/
    pages/
    widgets/
  main.dart
```
