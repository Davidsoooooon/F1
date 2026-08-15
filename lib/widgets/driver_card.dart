import 'package:flutter/material.dart';

import '../models/driver.dart';

class DriverCard extends StatelessWidget {
  const DriverCard({super.key, required this.driver, required this.onTap});

  final Driver driver;
  final VoidCallback onTap;

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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2C2C2E)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withAlpha(160), Colors.black],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(12),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _DriverPhoto(
                            asset: driver.photoAsset,
                            initials: _initials,
                            radius: 26,
                            borderColor: Colors.white,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(160),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(
                              driver.number == null
                                  ? 'TBD'
                                  : '#${driver.number}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
                          color: accent.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: accent.withAlpha(60)),
                        ),
                        child: Text(
                          driver.team,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: accent,
                            letterSpacing: 0.3,
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
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverPhoto extends StatelessWidget {
  const _DriverPhoto({
    required this.asset,
    required this.initials,
    required this.radius,
    this.borderColor,
  });

  final String? asset;
  final String initials;
  final double radius;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor ?? Colors.transparent, width: 2),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE10600).withAlpha(31),
        child: ClipOval(
          child: asset == null
              ? Text(
                  initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE10600),
                  ),
                )
              : Image.asset(
                  asset!,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      initials,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE10600),
                      ),
                    );
                  },
                ),
        ),
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
