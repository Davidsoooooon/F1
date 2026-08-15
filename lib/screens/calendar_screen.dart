import 'package:flutter/material.dart';

import '../data/races_data.dart';
import '../services/f1_api.dart';
import '../theme/app_theme.dart';
import '../widgets/calendar_card.dart';
import 'race_details_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final F1ApiService _api = F1ApiService();
  late final Future<LiveRace?> _latestRace = _api.fetchRaceResults();
  late final Future<List<LiveSeason>> _seasons = _api.fetchSeasons();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Race Calendar')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: const Color(0xFF111827),
                      padding: const EdgeInsets.all(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.asset(
                          'assets/banners/calendar_2026.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFE5E7EB),
                              alignment: Alignment.center,
                              child: const Text('2026 F1 Calendar'),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Season Schedule',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${racesData.length} rounds • 2026 season',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList.separated(
              itemCount: racesData.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final race = racesData[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => RaceDetailsScreen(race: race),
                      ),
                    );
                  },
                  child: CalendarCard(race: race),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest Race Results',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<LiveRace?>(
                    future: _latestRace,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return _LiveInfoCard(
                          message: snapshot.error.toString(),
                          icon: Icons.cloud_off,
                        );
                      }
                      final race = snapshot.data;
                      if (race == null) {
                        return const _LiveInfoCard(
                          message: 'No live race results available.',
                          icon: Icons.info_outline,
                        );
                      }
                      return _RaceResultsCard(race: race);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Seasons',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<LiveSeason>>(
                    future: _seasons,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return _LiveInfoCard(
                          message: snapshot.error.toString(),
                          icon: Icons.cloud_off,
                        );
                      }
                      final seasons = snapshot.data ?? [];
                      if (seasons.isEmpty) {
                        return const _LiveInfoCard(
                          message: 'No seasons returned by the API.',
                          icon: Icons.info_outline,
                        );
                      }
                      return SizedBox(
                        height: 60,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: seasons.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final season = seasons[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: AppDecorations.lightCard(radius: 14),
                              child: Row(
                                children: [
                                  const Icon(Icons.flag_outlined, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    season.year.toString(),
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.lightText,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RaceResultsCard extends StatelessWidget {
  const _RaceResultsCard({required this.race});

  final LiveRace race;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topResults = race.results.length > 5
        ? race.results.take(5)
        : race.results;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.lightCard(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            race.raceName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.lightText,
            ),
          ),
          if (race.date != null) ...[
            const SizedBox(height: 4),
            Text(
              race.date!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.lightMuted,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...topResults.map(
            (result) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      result.position.toString(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.driverName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightText,
                      ),
                    ),
                  ),
                  Text(
                    result.teamName.isEmpty ? '—' : result.teamName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveInfoCard extends StatelessWidget {
  const _LiveInfoCard({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
