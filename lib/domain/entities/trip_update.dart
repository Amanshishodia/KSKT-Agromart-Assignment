import 'package:equatable/equatable.dart';

import 'trip.dart';

class TripUpdate extends Equatable {
  const TripUpdate({required this.trip, required this.speedInMps});

  final Trip trip;
  final double speedInMps;

  @override
  List<Object?> get props => <Object?>[trip, speedInMps];
}
