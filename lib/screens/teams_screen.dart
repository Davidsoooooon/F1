import 'package:flutter/material.dart';

import '../data/teams_data.dart';
import '../models/team.dart';
import '../services/f1_api.dart';
import '../widgets/team_card.dart';
import 'team_details_screen.dart';

enum TeamsView { static, live }

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  TeamsView _view = TeamsView.static;
  final F1ApiService _api = F1ApiService();
  late final Future<List<LiveTeam>> _liveTeams = _api.fetchTeams();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teams')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<TeamsView>(
              segments: const [
                ButtonSegment(
                  value: TeamsView.static,
                  label: Text('2026 Grid'),
                  icon: Icon(Icons.flag),
                ),
                ButtonSegment(
                  value: TeamsView.live,
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
            child: _view == TeamsView.static
                ? _StaticTeamsList(teams: teamsData)
                : _LiveTeamsList(future: _liveTeams),
          ),
        ],
      ),
    );
  }
}

class _StaticTeamsList extends StatelessWidget {
  const _StaticTeamsList({required this.teams});

  final List<Team> teams;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final team = teams[index];
        return TeamCard(
          team: team,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TeamDetailsScreen(team: team)),
            );
          },
        );
      },
    );
  }
}

class _LiveTeamsList extends StatelessWidget {
  const _LiveTeamsList({required this.future});

  final Future<List<LiveTeam>> future;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<LiveTeam>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _LiveErrorCard(message: snapshot.error.toString());
        }
        final teams = snapshot.data ?? [];
        if (teams.isEmpty) {
          return const _LiveErrorCard(message: 'No live teams found.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final team = teams[index];
            final local = _teamFromId(team.teamId);
            final accent = local?.color ?? const Color(0xFFE10600);
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2C2C2E)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: local?.bannerAsset == null
                        ? Container(
                            width: 64,
                            height: 44,
                            color: accent.withAlpha(20),
                            child: const Icon(Icons.shield_outlined),
                          )
                        : Image.asset(
                            local!.bannerAsset,
                            width: 64,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.teamName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          team.nationality ?? 'Nationality TBA',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
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
                      team.firstAppearance == 0
                          ? 'Since —'
                          : 'Since ${team.firstAppearance}',
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
            const Icon(Icons.cloud_off, size: 48, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
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

String _normalizeKey(String value) {
  return value
      .toLowerCase()
      .replaceAll(' ', '')
      .replaceAll('-', '')
      .replaceAll('_', '');
}
