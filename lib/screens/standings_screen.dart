import 'package:flutter/material.dart';

import '../data/drivers_data.dart';
import '../data/teams_data.dart';
import '../models/team.dart';
import '../services/f1_api.dart';
import '../theme/app_theme.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  final F1ApiService _api = F1ApiService();
  late Future<List<LiveDriverStanding>> _liveDrivers;
  late Future<List<LiveConstructorStanding>> _liveConstructors;
  DateTime? _lastRefresh;

  @override
  void initState() {
    super.initState();
    _lastRefresh = DateTime.now();
    _liveDrivers = _api.fetchDriverStandings();
    _liveConstructors = _api.fetchConstructorStandings();
  }

  Future<void> _refreshStandings() async {
    setState(() {
      _lastRefresh = DateTime.now();
      _liveDrivers = _api.fetchDriverStandings();
      _liveConstructors = _api.fetchConstructorStandings();
    });
    try {
      await Future.wait([_liveDrivers, _liveConstructors]);
    } catch (_) {
      // Individual sections render their own static fallback state.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const driverRows = [
      ['1', 'Kimi Antonelli', 'Mercedes', '179'],
      ['2', 'George Russell', 'Mercedes', '154'],
      ['3', 'Lewis Hamilton', 'Ferrari', '147'],
      ['4', 'Charles Leclerc', 'Ferrari', '108'],
      ['5', 'Lando Norris', 'McLaren', '97'],
      ['6', 'Oscar Piastri', 'McLaren', '82'],
      ['7', 'Max Verstappen', 'Red Bull', '76'],
      ['8', 'Isack Hadjar', 'Red Bull', '52'],
      ['9', 'Pierre Gasly', 'Alpine', '42'],
      ['10', 'Liam Lawson', 'Racing Bulls', '39'],
    ];

    const constructorRows = [
      ['1', 'Mercedes', '333'],
      ['2', 'Ferrari', '255'],
      ['3', 'McLaren', '179'],
      ['4', 'Red Bull', '128'],
      ['5', 'Alpine', '60'],
      ['6', 'Racing Bulls', '59'],
      ['7', 'Haas', '21'],
      ['8', 'Williams', '11'],
      ['9', 'Audi', '6'],
      ['10', 'Aston Martin', '1'],
      ['11', 'Cadillac', '0'],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Standings'),
        actions: [
          IconButton(
            tooltip: 'Refresh standings',
            onPressed: _refreshStandings,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStandings,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.heroGradient(radius: 16),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.white, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHAMPIONSHIP',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white54,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '2026 STANDINGS',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _lastRefresh == null
                              ? 'Live feed ready'
                              : 'Last refreshed ${_formatClock(_lastRefresh!)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _LiveStandingsSection(
              title: 'Drivers Standings',
              isDriver: true,
              future: _liveDrivers,
              fallbackRows: driverRows,
            ),
            const SizedBox(height: 24),
            _LiveStandingsSection(
              title: 'Constructors Standings',
              isDriver: false,
              future: _liveConstructors,
              fallbackRows: constructorRows,
            ),
          ],
        ),
      ),
    );
  }

  String _formatClock(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _LiveStandingsSection extends StatelessWidget {
  const _LiveStandingsSection({
    required this.title,
    required this.isDriver,
    required this.future,
    required this.fallbackRows,
  });

  final String title;
  final bool isDriver;
  final Future<List> future;
  final List<List<String>> fallbackRows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final rows = snapshot.data ?? [];
            if (snapshot.hasError || rows.isEmpty) {
              return Column(
                children: [
                  const _LiveErrorCard(
                    message:
                        'Live standings unavailable. Showing the latest static snapshot.',
                  ),
                  const SizedBox(height: 12),
                  ..._buildFallbackRows(context),
                ],
              );
            }
            return Column(
              children: [
                const _LiveStatusCard(),
                const SizedBox(height: 12),
                ...rows.map((item) {
                  if (isDriver) {
                    final standing = item as LiveDriverStanding;
                    final team = _teamFromId(standing.teamId);
                    return _StandingsRow(
                      position: standing.position.toString(),
                      name: standing.driverName,
                      team: team?.name ?? '—',
                      points: standing.points.toString(),
                      highlight: standing.position == 1,
                      photoAsset: _driverPhoto(standing.driverName),
                      bannerAsset: null,
                    );
                  } else {
                    final standing = item as LiveConstructorStanding;
                    final team =
                        _teamFromId(standing.teamId) ??
                        _teamFromName(standing.teamName);
                    return _StandingsRow(
                      position: standing.position.toString(),
                      name: standing.teamName,
                      points: standing.points.toString(),
                      highlight: standing.position == 1,
                      photoAsset: null,
                      bannerAsset:
                          team?.bannerAsset ?? _teamBanner(standing.teamName),
                    );
                  }
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildFallbackRows(BuildContext context) {
    return fallbackRows.map((row) {
      final position = row[0];
      final name = row[1];
      final team = isDriver ? row[2] : null;
      final points = isDriver ? row[3] : row[2];
      return _StandingsRow(
        position: position,
        name: name,
        team: team,
        points: points,
        highlight: position == '1',
        photoAsset: isDriver ? _driverPhoto(name) : null,
        bannerAsset: isDriver ? null : _teamBanner(name),
      );
    }).toList();
  }
}

class _LiveStatusCard extends StatelessWidget {
  const _LiveStatusCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppDecorations.darkCard(radius: 14),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Live API data loaded',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(Icons.wifi_tethering, size: 18, color: Colors.white38),
        ],
      ),
    );
  }
}

class _LiveErrorCard extends StatelessWidget {
  const _LiveErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.darkCard(radius: 14),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.white38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingsRow extends StatelessWidget {
  const _StandingsRow({
    required this.position,
    required this.name,
    required this.points,
    this.team,
    this.highlight = false,
    this.photoAsset,
    this.bannerAsset,
  });

  final String position;
  final String name;
  final String points;
  final String? team;
  final bool highlight;
  final String? photoAsset;
  final String? bannerAsset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFF1E0A0A) : AppColors.f1Card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? AppColors.f1Red.withAlpha(180)
              : AppColors.f1Border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: highlight
                  ? const Color(0xFFE10600)
                  : const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                position,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (bannerAsset != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                bannerAsset!,
                width: 84,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 84,
                    height: 48,
                    color: const Color(0xFFE5E7EB),
                  );
                },
              ),
            )
          else
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE10600).withAlpha(28),
              child: photoAsset == null
                  ? Text(
                      name.substring(0, 1),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE10600),
                      ),
                    )
                  : ClipOval(
                      child: Image.asset(
                        photoAsset!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            name.substring(0, 1),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE10600),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (team != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    team!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$points pts',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String? _driverPhoto(String name) {
  try {
    return driversData.firstWhere((driver) => driver.name == name).photoAsset;
  } catch (_) {
    return null;
  }
}

String? _teamBanner(String teamName) {
  switch (teamName) {
    case 'Red Bull':
      return teamsData.firstWhere((t) => t.id == 'redbull').bannerAsset;
    case 'McLaren':
      return teamsData.firstWhere((t) => t.id == 'mclaren').bannerAsset;
    case 'Ferrari':
      return teamsData.firstWhere((t) => t.id == 'ferrari').bannerAsset;
    case 'Mercedes':
      return teamsData.firstWhere((t) => t.id == 'mercedes').bannerAsset;
    case 'Aston Martin':
      return teamsData.firstWhere((t) => t.id == 'astonmartin').bannerAsset;
    case 'Williams':
      return teamsData.firstWhere((t) => t.id == 'williams').bannerAsset;
    case 'Cadillac':
      return teamsData.firstWhere((t) => t.id == 'cadillac').bannerAsset;
    case 'Alpine':
      return teamsData.firstWhere((t) => t.id == 'alpine').bannerAsset;
    case 'Audi':
      return teamsData.firstWhere((t) => t.id == 'audi').bannerAsset;
    case 'Haas':
      return teamsData.firstWhere((t) => t.id == 'haas').bannerAsset;
    case 'Racing Bulls':
      return teamsData.firstWhere((t) => t.id == 'racingbulls').bannerAsset;
    default:
      return null;
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

Team? _teamFromName(String? name) {
  if (name == null) return null;
  final normalized = _normalizeKey(name);
  try {
    return teamsData.firstWhere(
      (team) => _normalizeKey(team.name) == normalized,
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
