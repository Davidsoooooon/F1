import 'package:flutter/material.dart';

import '../data/career_data.dart';
import '../models/driver.dart';

class DriverDetailsScreen extends StatelessWidget {
  const DriverDetailsScreen({super.key, required this.driver});

  final Driver driver;

  String get _initials {
    final parts = driver.name.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1);
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _teamAccent(driver.team);
    final career = driverCareerData[driver.id];
    final stats = [
      _StatValue(
        label: 'Wins',
        value: driver.wins.toString(),
        icon: Icons.emoji_events,
      ),
      _StatValue(
        label: 'Podiums',
        value: driver.podiums.toString(),
        icon: Icons.stacked_line_chart,
      ),
      _StatValue(
        label: 'Titles',
        value: driver.championships.toString(),
        icon: Icons.workspace_premium,
      ),
      _StatValue(
        label: 'Debut',
        value: driver.debutYear.toString(),
        icon: Icons.flag,
      ),
      _StatValue(
        label: 'Nation',
        value: driver.nationality,
        icon: Icons.public,
      ),
      _StatValue(
        label: 'Car No.',
        value: driver.number == null ? 'TBD' : driver.number.toString(),
        icon: Icons.tag,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(driver.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent,
                  accent.withAlpha(180),
                  const Color(0xFF101010),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withAlpha(51),
                  child: ClipOval(
                    child: driver.photoAsset == null
                        ? Text(
                            _initials,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          )
                        : Image.asset(
                            driver.photoAsset!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                _initials,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              driver.team,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              driver.nationality,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(28),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          driver.number == null
                              ? 'Car No. TBD'
                              : 'Car No. ${driver.number}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Bio',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(driver.bio, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          Text(
            'Key Stats',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 800 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.7,
                ),
                itemBuilder: (context, index) {
                  final stat = stats[index];
                  return _StatTile(
                    label: stat.label,
                    value: stat.value,
                    icon: stat.icon,
                    accent: accent,
                  );
                },
              );
            },
          ),
          if (career != null) ...[
            const SizedBox(height: 22),
            Text(
              'Career Achievements',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: accent.withAlpha(80)),
              ),
              child: Text(
                career.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...career.achievements.map(
              (achievement) =>
                  _AchievementTile(achievement: achievement, accent: accent),
            ),
            const SizedBox(height: 4),
            Text(
              'Career records updated $careerDataUpdated • Formula1.com',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white38,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatValue {
  const _StatValue({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withAlpha(28),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement, required this.accent});

  final String achievement;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_outlined, color: accent, size: 20),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              achievement,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _teamAccent(String team) {
  switch (team) {
    case 'McLaren':
      return const Color(0xFFFF8700);
    case 'Mercedes':
      return const Color(0xFF00D2BE);
    case 'Red Bull':
      return const Color(0xFF1E41FF);
    case 'Ferrari':
      return const Color(0xFFE10600);
    case 'Williams':
      return const Color(0xFF005AFF);
    case 'Racing Bulls':
      return const Color(0xFF1F3EFF);
    case 'Aston Martin':
      return const Color(0xFF006F62);
    case 'Audi':
      return const Color(0xFF2C2C2C);
    case 'Cadillac':
      return const Color(0xFF0B3D91);
    case 'Alpine':
      return const Color(0xFF0090FF);
    case 'Haas':
      return const Color(0xFF7A7F84);
    default:
      return const Color(0xFFE10600);
  }
}
