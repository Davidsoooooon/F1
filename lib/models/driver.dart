class Driver {
  const Driver({
    required this.id,
    required this.name,
    required this.team,
    required this.nationality,
    required this.number,
    required this.bio,
    required this.wins,
    required this.podiums,
    required this.championships,
    required this.debutYear,
    this.photoAsset,
  });

  final String id;
  final String name;
  final String team;
  final String nationality;
  final int? number;
  final String bio;
  final int wins;
  final int podiums;
  final int championships;
  final int debutYear;
  final String? photoAsset;
}
