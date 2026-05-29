class Team {
  final String id;
  final String name;
  final String shortName;
  final String flag;
  final String group;
  final String confederation;
  final int ranking;
  final bool isFollowing;

  Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.flag,
    required this.group,
    required this.confederation,
    required this.ranking,
    this.isFollowing = false,
  });

  Team copyWith({
    String? id,
    String? name,
    String? shortName,
    String? flag,
    String? group,
    String? confederation,
    int? ranking,
    bool? isFollowing,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      flag: flag ?? this.flag,
      group: group ?? this.group,
      confederation: confederation ?? this.confederation,
      ranking: ranking ?? this.ranking,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

class Stadium {
  final String id;
  final String name;
  final String city;
  final String country;
  final int capacity;
  final double latitude;
  final double longitude;
  final String description;
  final String imageUrl;

  Stadium({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.capacity,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.imageUrl,
  });
}

class Match {
  final String id;
  final int matchNumber;
  final String group;
  final String homeTeam;
  final String awayTeam;
  final String homeFlag;
  final String awayFlag;
  final String date;
  final String localTime;
  final String venueTime;
  final String stadium;
  final String city;
  final String country;
  final String venue;
  final String status; // "próximo", "en vivo", "finalizado"
  final int homeScore;
  final int awayScore;
  final bool isFavorite;
  final bool reminderEnabled;
  final double latitude;
  final double longitude;
  final String notes;

  Match({
    required this.id,
    required this.matchNumber,
    required this.group,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeFlag,
    required this.awayFlag,
    required this.date,
    required this.localTime,
    required this.venueTime,
    required this.stadium,
    required this.city,
    required this.country,
    required this.venue,
    required this.status,
    this.homeScore = 0,
    this.awayScore = 0,
    this.isFavorite = false,
    this.reminderEnabled = false,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.notes = '',
  });

  Match copyWith({
    String? id,
    int? matchNumber,
    String? group,
    String? homeTeam,
    String? awayTeam,
    String? homeFlag,
    String? awayFlag,
    String? date,
    String? localTime,
    String? venueTime,
    String? stadium,
    String? city,
    String? country,
    String? venue,
    String? status,
    int? homeScore,
    int? awayScore,
    bool? isFavorite,
    bool? reminderEnabled,
    double? latitude,
    double? longitude,
    String? notes,
  }) {
    return Match(
      id: id ?? this.id,
      matchNumber: matchNumber ?? this.matchNumber,
      group: group ?? this.group,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeFlag: homeFlag ?? this.homeFlag,
      awayFlag: awayFlag ?? this.awayFlag,
      date: date ?? this.date,
      localTime: localTime ?? this.localTime,
      venueTime: venueTime ?? this.venueTime,
      stadium: stadium ?? this.stadium,
      city: city ?? this.city,
      country: country ?? this.country,
      venue: venue ?? this.venue,
      status: status ?? this.status,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      isFavorite: isFavorite ?? this.isFavorite,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
    );
  }
}

class StandingRow {
  final String teamId;
  final String teamName;
  final String teamFlag;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int points;

  StandingRow({
    required this.teamId,
    required this.teamName,
    required this.teamFlag,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.points,
  });
}
