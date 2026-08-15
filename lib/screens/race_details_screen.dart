import 'dart:async';

import 'package:flutter/material.dart';

import '../models/race.dart';
import '../theme/app_theme.dart';

class RaceDetailsScreen extends StatefulWidget {
  const RaceDetailsScreen({super.key, required this.race});

  final Race race;

  @override
  State<RaceDetailsScreen> createState() => _RaceDetailsScreenState();
}

class _RaceDetailsScreenState extends State<RaceDetailsScreen> {
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

    return Scaffold(
      appBar: AppBar(title: Text('Round ${race.round}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Hero(
            tag: 'race-${race.round}',
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: AppDecorations.heroGradient(radius: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _RoundBadge(round: race.round),
                        const Spacer(),
                        const Icon(
                          Icons.sports_motorsports,
                          color: Colors.white38,
                          size: 42,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      race.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${race.circuit} • ${race.country}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _Countdown(race: race, now: _now),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Weekend schedule',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Times shown in your local timezone • provisional schedule',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 14),
          ...race.sessions.map(
            (session) => _SessionTile(session: session, now: _now),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.darkCard(),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.f1Red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Session times are an offline preview and may change. Refresh official event information before race weekend.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                      height: 1.4,
                    ),
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

class _RoundBadge extends StatelessWidget {
  const _RoundBadge({required this.round});

  final int round;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        'ROUND $round',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.race, required this.now});

  final Race race;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    if (race.isCompletedAt(now)) {
      return const _StatusPill(
        icon: Icons.flag,
        label: 'RACE COMPLETE',
        color: Colors.white70,
      );
    }
    if (race.isWeekendAt(now)) {
      final remaining = race.raceDate.difference(now.toUtc());
      if (remaining.isNegative) {
        return const _StatusPill(
          icon: Icons.circle,
          label: 'RACE LIVE',
          color: Color(0xFF35D07F),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StatusPill(
            icon: Icons.bolt,
            label: 'RACE WEEKEND',
            color: Color(0xFF35D07F),
          ),
          const SizedBox(height: 12),
          _CountdownBoxes(duration: remaining),
        ],
      );
    }
    return _CountdownBoxes(duration: race.raceDate.difference(now.toUtc()));
  }
}

class _CountdownBoxes extends StatelessWidget {
  const _CountdownBoxes({required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final days = safe.inDays;
    final hours = safe.inHours.remainder(24);
    final minutes = safe.inMinutes.remainder(60);
    final seconds = safe.inSeconds.remainder(60);

    return Row(
      children: [
        _TimeBox(value: days, label: 'DAYS'),
        const SizedBox(width: 8),
        _TimeBox(value: hours, label: 'HRS'),
        const SizedBox(width: 8),
        _TimeBox(value: minutes, label: 'MIN'),
        const SizedBox(width: 8),
        _TimeBox(value: seconds, label: 'SEC'),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(65),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Text(
              value.toString().padLeft(2, '0'),
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white54,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 7),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.now});

  final RaceSession session;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = session.dateTime.toLocal();
    final isPast = now.isAfter(local.add(const Duration(hours: 2)));
    final isLive =
        now.isAfter(local) && now.isBefore(local.add(const Duration(hours: 2)));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: AppDecorations.darkCard(radius: 14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(
              color: isLive
                  ? const Color(0xFF35D07F)
                  : isPast
                  ? Colors.white24
                  : AppColors.f1Red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isPast ? Colors.white54 : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(local),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(local),
            style: theme.textTheme.labelLarge?.copyWith(
              color: isPast ? Colors.white38 : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (isLive) ...[
            const SizedBox(width: 8),
            const Text(
              'LIVE',
              style: TextStyle(
                color: Color(0xFF35D07F),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatDate(DateTime value) =>
    '${_weekdays[value.weekday - 1]}, ${_months[value.month - 1]} ${value.day}';

String _formatTime(DateTime value) {
  final hour = value.hour == 0
      ? 12
      : value.hour > 12
      ? value.hour - 12
      : value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}
