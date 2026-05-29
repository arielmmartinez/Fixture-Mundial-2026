import '../../domain/entities/fixture_entities.dart';

class TeamModel {
  final String id;
  final String name;
  final String shortName;
  final String flag;
  final String group;
  final String confederation;
  final int ranking;

  TeamModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.flag,
    required this.group,
    required this.confederation,
    required this.ranking,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      flag: json['flag'] as String,
      group: json['group'] as String,
      confederation: json['confederation'] as String,
      ranking: json['ranking'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'flag': flag,
      'group': group,
      'confederation': confederation,
      'ranking': ranking,
    };
  }

  Team toEntity({bool isFollowing = false}) {
    return Team(
      id: id,
      name: name,
      shortName: shortName,
      flag: flag,
      group: group,
      confederation: confederation,
      ranking: ranking,
      isFollowing: isFollowing,
    );
  }
}

class StadiumModel {
  final String id;
  final String name;
  final String city;
  final String country;
  final int capacity;
  final double latitude;
  final double longitude;
  final String description;
  final String imageUrl;

  StadiumModel({
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

  factory StadiumModel.fromJson(Map<String, dynamic> json) {
    return StadiumModel(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      capacity: json['capacity'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'capacity': capacity,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  Stadium toEntity() {
    return Stadium(
      id: id,
      name: name,
      city: city,
      country: country,
      capacity: capacity,
      latitude: latitude,
      longitude: longitude,
      description: description,
      imageUrl: imageUrl,
    );
  }
}

class MatchModel {
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
  final String status;
  final int homeScore;
  final int awayScore;
  final double latitude;
  final double longitude;
  final String notes;

  MatchModel({
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
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.notes = '',
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      matchNumber: json['matchNumber'] as int,
      group: json['group'] as String,
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      homeFlag: json['homeFlag'] as String,
      awayFlag: json['awayFlag'] as String,
      date: json['date'] as String,
      localTime: json['localTime'] as String,
      venueTime: json['venueTime'] as String,
      stadium: json['stadium'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      venue: json['venue'] as String,
      status: json['status'] as String,
      homeScore: json['homeScore'] as int? ?? 0,
      awayScore: json['awayScore'] as int? ?? 0,
      latitude: (json['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0.0).toDouble(),
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchNumber': matchNumber,
      'group': group,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeFlag': homeFlag,
      'awayFlag': awayFlag,
      'date': date,
      'localTime': localTime,
      'venueTime': venueTime,
      'stadium': stadium,
      'city': city,
      'country': country,
      'venue': venue,
      'status': status,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
    };
  }

  Match toEntity({
    bool isFavorite = false,
    bool reminderEnabled = false,
    int? homeScoreOverride,
    int? awayScoreOverride,
    String? statusOverride,
  }) {
    return Match(
      id: id,
      matchNumber: matchNumber,
      group: group,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeFlag: homeFlag,
      awayFlag: awayFlag,
      date: date,
      localTime: localTime,
      venueTime: venueTime,
      stadium: stadium,
      city: city,
      country: country,
      venue: venue,
      status: statusOverride ?? status,
      homeScore: homeScoreOverride ?? homeScore,
      awayScore: awayScoreOverride ?? awayScore,
      isFavorite: isFavorite,
      reminderEnabled: reminderEnabled,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
    );
  }
}
