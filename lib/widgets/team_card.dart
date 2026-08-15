import 'package:flutter/material.dart';

import '../models/team.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({super.key, required this.team, required this.onTap});

  final Team team;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              child: SizedBox(
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      team.bannerAsset,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: team.color.withAlpha(40),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withAlpha(210),
                            Colors.black.withAlpha(40),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 10,
                      child: Text(
                        team.name.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 36,
                        decoration: BoxDecoration(
                          color: team.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          team.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Principal: ${team.principal}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    team.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    team.drivers.join(' • '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white38,
                    ),
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
