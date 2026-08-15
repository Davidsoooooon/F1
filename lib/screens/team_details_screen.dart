import 'package:flutter/material.dart';

import '../data/career_data.dart';
import '../data/drivers_data.dart';
import '../models/driver.dart';
import '../models/team.dart';
import 'driver_details_screen.dart';

class TeamDetailsScreen extends StatelessWidget {
  const TeamDetailsScreen({super.key, required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drivers = driversData
        .where((driver) => team.drivers.contains(driver.name))
        .toList();
    final career = teamCareerData[team.id];

    return Scaffold(
      appBar: AppBar(title: Text(team.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TeamHero(team: team),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE4E4E7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team Profile',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _InfoChip(
                      icon: Icons.person,
                      label: 'Team Principal',
                      value: team.principal,
                      accent: team.color,
                    ),
                    _InfoChip(
                      icon: Icons.public,
                      label: 'Base',
                      value: team.base,
                      accent: team.color,
                    ),
                    _InfoChip(
                      icon: Icons.bolt,
                      label: 'Power Unit',
                      value: team.powerUnit,
                      accent: team.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (career != null) ...[
            const SizedBox(height: 20),
            _TeamHistorySection(team: team, career: career),
            const SizedBox(height: 20),
            _TrophyCabinet(team: team, career: career),
            const SizedBox(height: 20),
            _TeamAchievements(team: team, career: career),
          ],
          const SizedBox(height: 20),
          Text(
            'Driver Lineup',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...drivers.map(
            (driver) => _DriverLineupCard(
              driver: driver,
              accent: team.color,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DriverDetailsScreen(driver: driver),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamHero extends StatelessWidget {
  const _TeamHero({required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Image.asset(
            team.bannerAsset,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(height: 200, color: team.color.withAlpha(30));
            },
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withAlpha(20),
                  Colors.black.withAlpha(180),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: team.color.withAlpha(230),
                  child: const Icon(
                    Icons.sports_motorsports,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        team.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withAlpha(70)),
      ),
      constraints: const BoxConstraints(minWidth: 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverLineupCard extends StatelessWidget {
  const _DriverLineupCard({
    required this.driver,
    required this.accent,
    required this.onTap,
  });

  final Driver driver;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E4E7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 84,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 26,
              backgroundColor: accent.withAlpha(28),
              child: ClipOval(
                child: driver.photoAsset == null
                    ? Text(
                        driver.name.substring(0, 1),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      )
                    : Image.asset(
                        driver.photoAsset!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            driver.name.substring(0, 1),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: accent,
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
                    driver.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    driver.nationality,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withAlpha(18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                driver.number == null ? 'TBD' : '#${driver.number}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamHistorySection extends StatelessWidget {
  const _TeamHistorySection({required this.team, required this.career});

  final Team team;
  final TeamCareerProfile career;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: team.color.withAlpha(90)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: team.color),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Team History',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            career.history,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrophyCabinet extends StatelessWidget {
  const _TrophyCabinet({required this.team, required this.career});

  final Team team;
  final TeamCareerProfile career;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trophy Cabinet',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TrophyTile(
                icon: Icons.workspace_premium,
                value: career.championships.toString(),
                label: 'Constructors’\nTitles',
                accent: team.color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TrophyTile(
                icon: Icons.emoji_events,
                value: career.wins.toString(),
                label: 'Grand Prix\nWins',
                accent: team.color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TrophyTile(
                icon: Icons.stacked_line_chart,
                value: career.podiums.toString(),
                label: 'Podium\nFinishes',
                accent: team.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          'First entry: ${career.firstEntry} • Updated $careerDataUpdated',
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.white38),
        ),
      ],
    );
  }
}

class _TrophyTile extends StatelessWidget {
  const _TrophyTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: accent.withAlpha(22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withAlpha(70)),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 7),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white54,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamAchievements extends StatelessWidget {
  const _TeamAchievements({required this.team, required this.career});

  final Team team;
  final TeamCareerProfile career;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Major Achievements',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ...career.achievements.map(
          (achievement) => Container(
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2C2C2E)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: team.color, size: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    achievement,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
