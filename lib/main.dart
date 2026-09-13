import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

import 'data/datasources/location_data_source.dart';
import 'data/datasources/trip_local_data_source.dart';
import 'data/repositories/location_repository_impl.dart';
import 'data/repositories/trip_repository_impl.dart';
import 'domain/repositories/location_repository.dart';
import 'domain/repositories/trip_repository.dart';
import 'domain/usecases/end_trip.dart';
import 'domain/usecases/get_active_trip.dart';
import 'domain/usecases/has_location_permission.dart';
import 'domain/usecases/open_location_settings.dart';
import 'domain/usecases/record_location.dart';
import 'domain/usecases/request_location_permission.dart';
import 'domain/usecases/start_trip.dart';
import 'domain/usecases/watch_location.dart';
import 'presentation/bloc/trip_bloc.dart';
import 'presentation/pages/trip_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Database database = await TripLocalDataSourceImpl.openAppDatabase();
  final TripRepository tripRepository =
      TripRepositoryImpl(TripLocalDataSourceImpl(database));
  final LocationRepository locationRepository =
      LocationRepositoryImpl(LocationDataSourceImpl());

  runApp(
    RiderTrackingApp(
      tripRepository: tripRepository,
      locationRepository: locationRepository,
    ),
  );
}

class RiderTrackingApp extends StatelessWidget {
  const RiderTrackingApp({
    super.key,
    required this.tripRepository,
    required this.locationRepository,
  });

  final TripRepository tripRepository;
  final LocationRepository locationRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KSKT Agromart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: BlocProvider<TripBloc>(
        create: (BuildContext context) => TripBloc(
          startTrip: StartTrip(tripRepository),
          endTrip: EndTrip(tripRepository),
          getActiveTrip: GetActiveTrip(tripRepository),
          recordLocation: RecordLocation(tripRepository),
          watchLocation: WatchLocation(locationRepository),
          requestLocationPermission:
              RequestLocationPermission(locationRepository),
          hasLocationPermission: HasLocationPermission(locationRepository),
          openLocationSettings: OpenLocationSettings(locationRepository),
        )..add(const TripRestored()),
        child: const TripPage(),
      ),
    );
  }
}
