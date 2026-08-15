import 'dart:convert';

import 'package:http/http.dart' as http;

class F1ApiService {
  F1ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _driversChampionshipUrl =
      'https://f1api.dev/api/current/drivers-championship';
  static const _constructorsChampionshipUrl =
      'https://f1api.dev/api/current/constructors-championship';
  static const _resultsUrl = 'https://f1api.dev/api/current/last/race';
  static const _driversUrl = 'https://f1api.dev/api/2026/drivers';
  static const _teamsUrl = 'https://f1api.dev/api/2026/teams';
  static const _seasonsUrl = 'https://f1api.dev/api/seasons';

  Future<List<LiveDriverStanding>> fetchDriverStandings() async {
    final data = await _getJson(_driversChampionshipUrl);
    final list = _asList(data['drivers_championship']);
    return list
        .map((item) {
          final driver = _asMap(item['driver']);
          final name = _joinName(
            driver['name']?.toString(),
            driver['surname']?.toString(),
          );
          return LiveDriverStanding(
            position: _toInt(item['position']),
            points: _toNum(item['points']),
            driverName: name,
            teamId: item['teamId']?.toString(),
          );
        })
        .where((item) => item.driverName.isNotEmpty)
        .toList();
  }

  Future<List<LiveConstructorStanding>> fetchConstructorStandings() async {
    final data = await _getJson(_constructorsChampionshipUrl);
    final list = _asList(data['constructors_championship']);
    return list
        .map((item) {
          final team = _asMap(item['team']);
          final teamName = team['teamName']?.toString() ?? '';
          return LiveConstructorStanding(
            position: _toInt(item['position']),
            points: _toNum(item['points']),
            teamId: item['teamId']?.toString(),
            teamName: teamName,
          );
        })
        .where((item) => item.teamName.isNotEmpty)
        .toList();
  }

  Future<List<LiveDriver>> fetchDrivers() async {
    final data = await _getJson(_driversUrl);
    final list = _asList(data['drivers']);
    return list
        .map((item) {
          return LiveDriver(
            driverId: item['driverId']?.toString() ?? '',
            name: item['name']?.toString() ?? '',
            surname: item['surname']?.toString() ?? '',
            nationality: item['nationality']?.toString() ?? '',
            number: _toInt(item['number']),
            teamId: item['teamId']?.toString(),
            shortName: item['shortName']?.toString(),
          );
        })
        .where(
          (item) =>
              item.name.isNotEmpty && _currentDriverIds.contains(item.driverId),
        )
        .toList();
  }

  Future<List<LiveTeam>> fetchTeams() async {
    final data = await _getJson(_teamsUrl);
    final list = _asList(data['teams'] ?? data['team']);
    return list
        .map((item) {
          return LiveTeam(
            teamId: item['teamId']?.toString() ?? '',
            teamName: item['teamName']?.toString() ?? '',
            nationality:
                item['teamNationality']?.toString() ??
                item['country']?.toString(),
            firstAppearance: _toInt(
              item['firstAppeareance'] ?? item['firstAppareance'],
            ),
          );
        })
        .where(
          (item) =>
              item.teamName.isNotEmpty && _currentTeamIds.contains(item.teamId),
        )
        .toList();
  }

  Future<LiveRace?> fetchRaceResults() async {
    final data = await _getJson(_resultsUrl);
    final races = data['races'];
    Map<String, dynamic>? race;
    if (races is Map<String, dynamic>) {
      race = races;
    } else if (races is List && races.isNotEmpty) {
      race = _asMap(races.first);
    } else if (data['race'] is List && (data['race'] as List).isNotEmpty) {
      race = _asMap((data['race'] as List).first);
    }

    if (race == null) return null;

    final resultsRaw =
        race['results'] ??
        race['raceResults'] ??
        race['result'] ??
        data['results'];
    final resultsList = _asList(resultsRaw);
    final results = resultsList
        .map((item) {
          final driver = _asMap(item['driver']);
          final team = _asMap(item['team']);
          return LiveRaceResult(
            position: _toInt(item['position']),
            driverName: _joinName(
              driver['name']?.toString(),
              driver['surname']?.toString(),
            ),
            teamName: team['teamName']?.toString() ?? '',
            time: item['time']?.toString() ?? item['raceTime']?.toString(),
          );
        })
        .where((item) => item.driverName.isNotEmpty)
        .toList();

    return LiveRace(
      round: _toInt(race['round']),
      raceName: race['raceName']?.toString() ?? 'Latest Race',
      date: race['date']?.toString(),
      results: results,
    );
  }

  Future<List<LiveSeason>> fetchSeasons() async {
    final data = await _getJson(_seasonsUrl);
    final list = _asList(data['championships']);
    return list
        .map((item) {
          return LiveSeason(
            year: _toInt(item['year']),
            name: item['championshipName']?.toString() ?? '',
          );
        })
        .where((item) => item.year > 0)
        .toList();
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Request failed: ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Unexpected response format');
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return const {};
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  num _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  String _joinName(String? first, String? last) {
    final parts = [
      if (first != null && first.isNotEmpty) first,
      if (last != null && last.isNotEmpty) last,
    ];
    return parts.join(' ').trim();
  }
}

const _currentDriverIds = {
  'norris',
  'piastri',
  'russell',
  'antonelli',
  'verstappen',
  'hadjar',
  'leclerc',
  'hamilton',
  'albon',
  'sainz',
  'lawson',
  'lindblad',
  'alonso',
  'stroll',
  'hulkenberg',
  'bortoleto',
  'bottas',
  'perez',
  'gasly',
  'colapinto',
  'ocon',
  'bearman',
};

const _currentTeamIds = {
  'mclaren',
  'mercedes',
  'red_bull',
  'ferrari',
  'williams',
  'rb',
  'racing_bulls',
  'aston_martin',
  'audi',
  'cadillac',
  'alpine',
  'haas',
};

class LiveDriverStanding {
  const LiveDriverStanding({
    required this.position,
    required this.points,
    required this.driverName,
    required this.teamId,
  });

  final int position;
  final num points;
  final String driverName;
  final String? teamId;
}

class LiveConstructorStanding {
  const LiveConstructorStanding({
    required this.position,
    required this.points,
    required this.teamId,
    required this.teamName,
  });

  final int position;
  final num points;
  final String? teamId;
  final String teamName;
}

class LiveDriver {
  const LiveDriver({
    required this.driverId,
    required this.name,
    required this.surname,
    required this.nationality,
    required this.number,
    required this.teamId,
    required this.shortName,
  });

  final String driverId;
  final String name;
  final String surname;
  final String nationality;
  final int number;
  final String? teamId;
  final String? shortName;

  String get fullName => '$name $surname'.trim();
}

class LiveTeam {
  const LiveTeam({
    required this.teamId,
    required this.teamName,
    required this.nationality,
    required this.firstAppearance,
  });

  final String teamId;
  final String teamName;
  final String? nationality;
  final int firstAppearance;
}

class LiveRace {
  const LiveRace({
    required this.round,
    required this.raceName,
    required this.date,
    required this.results,
  });

  final int round;
  final String raceName;
  final String? date;
  final List<LiveRaceResult> results;
}

class LiveRaceResult {
  const LiveRaceResult({
    required this.position,
    required this.driverName,
    required this.teamName,
    required this.time,
  });

  final int position;
  final String driverName;
  final String teamName;
  final String? time;
}

class LiveSeason {
  const LiveSeason({required this.year, required this.name});

  final int year;
  final String name;
}
