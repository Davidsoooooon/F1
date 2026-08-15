import 'dart:async';

import 'package:flutter/material.dart';

import '../data/drivers_data.dart';
import '../data/products_data.dart';
import '../data/races_data.dart';
import '../data/teams_data.dart';
import '../models/product.dart';
import '../models/race.dart';
import '../screens/race_details_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nextIndex = racesData.indexWhere((race) => !race.isCompletedAt(now));
    final nextRace = nextIndex == -1 ? racesData.last : racesData[nextIndex];
    final previewRaces = nextIndex == -1
        ? racesData.reversed.take(3)
        : racesData.skip(nextIndex).take(3);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFE10600),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text('F1 2026'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NextRaceHero(
            race: nextRace,
            onTap: () => _openRace(context, nextRace),
          ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Teams', onTap: () => onNavigate(1)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: teamsData.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final team = teamsData[index];
                return _TeamBannerTile(
                  teamName: team.name,
                  asset: team.bannerAsset,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Drivers', onTap: () => onNavigate(2)),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: driversData.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final driver = driversData[index];
                return _DriverMiniCard(
                  name: driver.name,
                  team: driver.team,
                  number: driver.number,
                  photoAsset: driver.photoAsset,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Race Calendar', onTap: () => onNavigate(3)),
          const SizedBox(height: 12),
          ...previewRaces.map(
            (race) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openRace(context, race),
                child: _RacePreviewCard(
                  round: race.round,
                  name: race.name,
                  circuit: race.circuit,
                  date: race.date,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'Standings', onTap: () => onNavigate(4)),
          const SizedBox(height: 12),
          const _StandingsPreview(),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Shop', onTap: () => onNavigate(5)),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: productsData.length > 6 ? 6 : productsData.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = productsData[index];
                return _ShopPreviewCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openRace(BuildContext context, Race race) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RaceDetailsScreen(race: race),
      ),
    );
  }
}

class _NextRaceHero extends StatefulWidget {
  const _NextRaceHero({required this.race, required this.onTap});

  final Race race;
  final VoidCallback onTap;

  @override
  State<_NextRaceHero> createState() => _NextRaceHeroState();
}

class _NextRaceHeroState extends State<_NextRaceHero> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final race = widget.race;
    final theme = Theme.of(context);
    final remaining = race.raceDate.difference(_now.toUtc());
    final safe = remaining.isNegative ? Duration.zero : remaining;
    final isWeekend = race.isWeekendAt(_now);
    final isComplete = race.isCompletedAt(_now);

    return Hero(
      tag: 'race-${race.round}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(20),
            decoration: AppDecorations.heroGradient(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(24),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isWeekend ? Icons.bolt : Icons.schedule,
                            size: 13,
                            color: isWeekend
                                ? const Color(0xFF65E6A5)
                                : Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isComplete
                                ? 'SEASON FINALE'
                                : isWeekend
                                ? 'RACE WEEKEND'
                                : 'NEXT RACE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'ROUND ${race.round}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  race.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${race.circuit} • ${race.date}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 18),
                if (!isComplete) ...[
                  Row(
                    children: [
                      _HeroTime(value: safe.inDays, label: 'DAYS'),
                      const SizedBox(width: 8),
                      _HeroTime(
                        value: safe.inHours.remainder(24),
                        label: 'HRS',
                      ),
                      const SizedBox(width: 8),
                      _HeroTime(
                        value: safe.inMinutes.remainder(60),
                        label: 'MIN',
                      ),
                      const SizedBox(width: 8),
                      _HeroTime(
                        value: safe.inSeconds.remainder(60),
                        label: 'SEC',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    const Icon(Icons.public, size: 16, color: Colors.white54),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Times adapt to your local timezone',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    Text(
                      'VIEW WEEKEND  →',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroTime extends StatelessWidget {
  const _HeroTime({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(60),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Text(
              value.toString().padLeft(2, '0'),
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white38,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFE10600),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'SEE ALL →',
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFFE10600),
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _TeamBannerTile extends StatelessWidget {
  const _TeamBannerTile({required this.teamName, required this.asset});

  final String teamName;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Image.asset(
            asset,
            width: 200,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 120,
                color: const Color(0xFF1C1C1E),
              );
            },
          ),
          Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withAlpha(210),
                  Colors.black.withAlpha(30),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Text(
              teamName.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverMiniCard extends StatelessWidget {
  const _DriverMiniCard({
    required this.name,
    required this.team,
    required this.number,
    required this.photoAsset,
  });

  final String name;
  final String team;
  final int? number;
  final String? photoAsset;

  String get _initials {
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1);
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE10600).withAlpha(40),
            child: ClipOval(
              child: photoAsset == null
                  ? Text(
                      _initials,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE10600),
                      ),
                    )
                  : Image.asset(
                      photoAsset!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          _initials,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFE10600),
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            team,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE10600).withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number == null ? 'TBD' : '#$number',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE10600),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RacePreviewCard extends StatelessWidget {
  const _RacePreviewCard({
    required this.round,
    required this.name,
    required this.circuit,
    required this.date,
  });

  final int round;
  final String name;
  final String circuit;
  final String date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE10600),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                round.toString(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
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
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  circuit,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingsPreview extends StatelessWidget {
  const _StandingsPreview();

  static const _drivers = [
    ['1', 'Kimi Antonelli', '179'],
    ['2', 'George Russell', '154'],
    ['3', 'Lewis Hamilton', '147'],
  ];

  static const _constructors = [
    ['1', 'Mercedes', '333'],
    ['2', 'Ferrari', '255'],
    ['3', 'McLaren', '179'],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildRow(List<String> row) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                row[0],
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: row[0] == '1'
                      ? const Color(0xFFE10600)
                      : Colors.white54,
                ),
              ),
            ),
            Expanded(
              child: Text(
                row[1],
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              row[2],
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    Widget buildCard(String title, List<List<String>> rows) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2C2C2E)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            ...rows.map(buildRow),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            children: [
              buildCard('DRIVERS', _drivers),
              const SizedBox(height: 12),
              buildCard('CONSTRUCTORS', _constructors),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildCard('DRIVERS', _drivers)),
            const SizedBox(width: 12),
            Expanded(child: buildCard('CONSTRUCTORS', _constructors)),
          ],
        );
      },
    );
  }
}

class _ShopPreviewCard extends StatelessWidget {
  const _ShopPreviewCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: Image.asset(
                product.imageAsset ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: const Color(0xFF242426));
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              product.teamName,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Text(
              '\$${product.price.toStringAsFixed(0)}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE10600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
