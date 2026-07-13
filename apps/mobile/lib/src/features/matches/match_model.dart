class NbaTeam {
  const NbaTeam({
    required this.id,
    required this.name,
    required this.abbreviation,
    this.city,
    this.logoUrl,
    this.conference,
  });

  final int id;
  final String name;
  final String abbreviation;
  final String? city;
  final String? logoUrl;
  final String? conference;

  factory NbaTeam.fromJson(Map<String, dynamic> json) {
    return NbaTeam(
      id: json['id'] as int,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String,
      city: json['city'] as String?,
      logoUrl: json['logo_url'] as String?,
      conference: json['conference'] as String?,
    );
  }
}

class NbaMatch {
  const NbaMatch({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.startTime,
    required this.status,
    required this.homeScore,
    required this.awayScore,
    this.period,
    this.clock,
  });

  final int id;
  final NbaTeam homeTeam;
  final NbaTeam awayTeam;
  final DateTime startTime;
  final String status;
  final int homeScore;
  final int awayScore;
  final String? period;
  final String? clock;

  factory NbaMatch.fromJson(Map<String, dynamic> json) {
    return NbaMatch(
      id: json['id'] as int,
      homeTeam: NbaTeam.fromJson(json['home_team'] as Map<String, dynamic>),
      awayTeam: NbaTeam.fromJson(json['away_team'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['start_time'] as String).toLocal(),
      status: json['status'] as String,
      homeScore: json['home_score'] as int,
      awayScore: json['away_score'] as int,
      period: json['period'] as String?,
      clock: json['clock'] as String?,
    );
  }

  NbaMatch copyWithLiveScore(Map<String, dynamic> json) {
    return NbaMatch(
      id: id,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      startTime: startTime,
      status: json['status'] as String? ?? status,
      homeScore: json['home_score'] as int? ?? homeScore,
      awayScore: json['away_score'] as int? ?? awayScore,
      period: json['period'] as String? ?? period,
      clock: json['clock'] as String? ?? clock,
    );
  }

  String get matchup => '${awayTeam.abbreviation} @ ${homeTeam.abbreviation}';

  String get scoreText => '$awayScore - $homeScore';

  bool get isLive => status.toLowerCase() == 'live';
}
