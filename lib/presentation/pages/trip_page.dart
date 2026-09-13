import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/trip_bloc.dart';
import '../widgets/metric_tile.dart';

class TripPage extends StatelessWidget {
  const TripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KSKT Agromart')),
      body: BlocConsumer<TripBloc, TripState>(
        listenWhen: (TripState previous, TripState current) =>
            current.errorMessage != null &&
            previous.errorMessage != current.errorMessage,
        listener: (BuildContext context, TripState state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        },
        builder: (BuildContext context, TripState state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _StatusHeader(state: state),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: MetricTile(
                        label: 'Distance',
                        value: (state.distanceInMeters / 1000)
                            .toStringAsFixed(2),
                        unit: 'km',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricTile(
                        label: 'Speed',
                        value: (state.currentSpeedInMps * 3.6)
                            .toStringAsFixed(1),
                        unit: 'km/h',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: MetricTile(
                        label: 'Max speed',
                        value:
                            (state.maxSpeedInMps * 3.6).toStringAsFixed(1),
                        unit: 'km/h',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricTile(
                        label: 'Duration',
                        value: _duration(state),
                        unit: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _LocationCard(state: state),
                const Spacer(),
                _ActionBar(state: state),
              ],
            ),
          );
        },
      ),
    );
  }

  String _duration(TripState state) {
    final Duration duration = state.trip?.duration ?? Duration.zero;
    final String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours}:$minutes:$seconds';
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.state});

  final TripState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String label = switch (state.status) {
      TripStatusView.tracking => 'Trip in progress',
      TripStatusView.paused => 'Trip paused',
      TripStatusView.completed => 'Trip completed',
      TripStatusView.error => 'Cannot start trip',
      _ => 'No active trip',
    };

    return Row(
      children: <Widget>[
        Icon(
          state.isTracking
              ? Icons.navigation
              : state.isPaused
                  ? Icons.pause_circle_filled
                  : Icons.pause_circle_outline,
          color: state.isTracking
              ? Colors.green
              : state.isPaused
                  ? Colors.orange
                  : theme.colorScheme.outline,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: theme.textTheme.titleMedium),
              if (state.trip != null)
                Text(
                  state.trip!.id,
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.state});

  final TripState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String coordinates = state.lastLocation == null
        ? 'Waiting for GPS'
        : '${state.lastLocation!.latitude.toStringAsFixed(5)}, '
            '${state.lastLocation!.longitude.toStringAsFixed(5)}';
    final String accuracy = state.lastLocation == null
        ? '-'
        : '${state.lastLocation!.accuracyInMeters.toStringAsFixed(0)} m';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Current location', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(coordinates),
            const SizedBox(height: 4),
            Text('Accuracy: $accuracy', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.state});

  final TripState state;

  @override
  Widget build(BuildContext context) {
    final TripBloc bloc = context.read<TripBloc>();

    if (state.isTracking) {
      return SizedBox(
        height: 52,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => bloc.add(const TripEnded()),
          child: const Text('End Trip'),
        ),
      );
    }

    if (state.isPaused) {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => bloc.add(const TripResumed()),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Resume Trip'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => bloc.add(const TripSettingsOpened()),
                    child: const Text('Open Settings'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => bloc.add(const TripEnded()),
                    child: const Text('End Trip'),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: () => bloc.add(const TripStarted()),
        child: const Text('Start Trip'),
      ),
    );
  }
}
