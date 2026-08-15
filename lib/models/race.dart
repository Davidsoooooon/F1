class Race {
  const Race({
    required this.round,
    required this.name,
    required this.circuit,
    required this.country,
    required this.date,
    required this.raceDateIso,
  });

  final int round;
  final String name;
  final String circuit;
  final String country;
  final String date;
  final String raceDateIso;

  DateTime get raceDate => DateTime.parse('${raceDateIso}T13:00:00Z');

  DateTime get weekendStart => raceDate.subtract(const Duration(days: 2));

  List<RaceSession> get sessions => [
    RaceSession(
      name: 'Practice 1',
      dateTime: weekendStart.subtract(const Duration(hours: 2)),
    ),
    RaceSession(
      name: 'Practice 2',
      dateTime: weekendStart.add(const Duration(hours: 2)),
    ),
    RaceSession(
      name: 'Practice 3',
      dateTime: raceDate.subtract(const Duration(days: 1, hours: 3)),
    ),
    RaceSession(
      name: 'Qualifying',
      dateTime: raceDate.subtract(const Duration(days: 1)),
    ),
    RaceSession(name: 'Race', dateTime: raceDate),
  ];

  bool isCompletedAt(DateTime now) =>
      now.toUtc().isAfter(raceDate.add(const Duration(hours: 3)));

  bool isWeekendAt(DateTime now) {
    final utcNow = now.toUtc();
    return !utcNow.isBefore(weekendStart) &&
        !utcNow.isAfter(raceDate.add(const Duration(hours: 3)));
  }
}

class RaceSession {
  const RaceSession({required this.name, required this.dateTime});

  final String name;
  final DateTime dateTime;
}
