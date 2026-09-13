import 'package:sqflite/sqflite.dart';

import '../../domain/entities/trip.dart';
import '../models/trip_location_model.dart';
import '../models/trip_model.dart';

abstract class TripLocalDataSource {
  Future<void> insertTrip(TripModel trip);

  Future<void> updateTrip(TripModel trip);

  Future<TripModel?> getActiveTrip();

  Future<void> insertLocation(String tripId, TripLocationModel location);

  Future<TripLocationModel?> getLastLocation(String tripId);
}

class TripLocalDataSourceImpl implements TripLocalDataSource {
  TripLocalDataSourceImpl(this._database);

  final Database _database;

  static Future<Database> openAppDatabase() async {
    final String path = '${await getDatabasesPath()}/rider_tracking.db';
    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE trips (
            id TEXT PRIMARY KEY,
            status TEXT NOT NULL,
            started_at INTEGER NOT NULL,
            ended_at INTEGER,
            distance REAL NOT NULL DEFAULT 0,
            max_speed REAL NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            trip_id TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            speed REAL NOT NULL,
            accuracy REAL NOT NULL,
            recorded_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<void> insertTrip(TripModel trip) async {
    await _database.insert('trips', trip.toMap());
  }

  @override
  Future<void> updateTrip(TripModel trip) async {
    await _database.update(
      'trips',
      trip.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[trip.id],
    );
  }

  @override
  Future<TripModel?> getActiveTrip() async {
    final List<Map<String, Object?>> rows = await _database.query(
      'trips',
      where: 'status = ?',
      whereArgs: <Object?>[TripStatus.active.name],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return TripModel.fromMap(rows.first);
  }

  @override
  Future<void> insertLocation(
    String tripId,
    TripLocationModel location,
  ) async {
    await _database.insert('locations', location.toMap(tripId));
  }

  @override
  Future<TripLocationModel?> getLastLocation(String tripId) async {
    final List<Map<String, Object?>> rows = await _database.query(
      'locations',
      where: 'trip_id = ?',
      whereArgs: <Object?>[tripId],
      orderBy: 'recorded_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return TripLocationModel.fromMap(rows.first);
  }
}
