import 'package:flutter/material.dart';

import '../data/drivers_data.dart';
import '../data/teams_data.dart';
import '../models/driver.dart';
import '../models/team.dart';
import '../services/f1_api.dart';
import '../theme/app_theme.dart';
import '../widgets/driver_card.dart';
import 'driver_details_screen.dart';

enum DriversView { static, live }

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  DriversView _view = DriversView.static;
  final F1ApiService _api = F1ApiService();
  late final Future<List<LiveDriver>> _liveDrivers = _api.fetchDrivers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drivers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<DriversView>(
              segments: const [
                ButtonSegment(
                  value: DriversView.static,
                  label: Text('2026 Grid'),
                  icon: Icon(Icons.list_alt),
                ),
                ButtonSegment(
                  value: DriversView.live,
                  label: Text('Live API'),
                  icon: Icon(Icons.wifi_tethering),
                ),
              ],
              selected: {_view},
              onSelectionChanged: (value) {
                setState(() => _view = value.first);
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _view == DriversView.static
                ? _StaticDriversGrid(drivers: driversData)
                : _LiveDriversList(future: _liveDrivers),
          ),
        ],
      ),
    );
  }
}

class _StaticDriversGrid extends StatelessWidget {
  const _StaticDriversGrid({required this.drivers});

  final List<Driver> drivers;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100
            ? 4
            : width >= 800
            ? 3
            : 2;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: drivers.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            final driver = drivers[index];
            return DriverCard(
              driver: driver,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DriverDetailsScreen(driver: driver),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LiveDriversList extends StatelessWidget {
  const _LiveDriversList({required this.future});

  final Future<List<LiveDriver>> future;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<LiveDriver>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _LiveErrorCard(message: snapshot.error.toString());
        }
        final drivers = snapshot.data ?? [];
        if (drivers.isEmpty) {
          return const _LiveErrorCard(message: 'No live drivers found.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: drivers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final driver = drivers[index];
            final localDriver = _driverFromId(driver.driverId);
            final team =
                _teamFromId(driver.teamId) ?? _teamFromName(localDriver?.team);
            final accent = team?.color ?? const Color(0xFFE10600);
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: AppDecorations.lightCard(),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withAlpha(24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        driver.number == 0 ? '—' : driver.number.toString(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.fullName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          team?.name ?? driver.teamId ?? 'Team TBA',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.lightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withAlpha(18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      driver.nationality,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LiveErrorCard extends StatelessWidget {
  const _LiveErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.black54),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

Team? _teamFromId(String? teamId) {
  if (teamId == null) return null;
  final normalized = _normalizeKey(teamId);
  try {
    return teamsData.firstWhere(
      (team) =>
          _normalizeKey(team.id) == normalized ||
          _normalizeKey(team.name) == normalized,
    );
  } catch (_) {
    return null;
  }
}

Driver? _driverFromId(String driverId) {
  try {
    return driversData.firstWhere((driver) => driver.id == driverId);
  } catch (_) {
    return null;
  }
}

Team? _teamFromName(String? name) {
  if (name == null) return null;
  try {
    return teamsData.firstWhere(
      (team) =>
          _normalizeKey(team.name).contains(_normalizeKey(name)) ||
          _normalizeKey(
            name,
          ).contains(_normalizeKey(team.name).split('formula').first),
    );
  } catch (_) {
    return null;
  }
}

String _normalizeKey(String value) {
  return value
      .toLowerCase()
      .replaceAll(' ', '')
      .replaceAll('-', '')
      .replaceAll('_', '');
}
