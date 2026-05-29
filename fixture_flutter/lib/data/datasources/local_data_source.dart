import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/fixture_models.dart';

abstract class LocalDataSource {
  Future<void> init();
  Future<List<TeamModel>> getBaseTeams();
  Future<List<StadiumModel>> getBaseStadiums();
  Future<List<MatchModel>> getBaseMatches();

  // Match Overrides
  Map<String, dynamic>? getMatchOverride(String matchId);
  Future<void> saveMatchOverride(String matchId, Map<String, dynamic> overrideData);
  Future<void> clearAllMatchOverrides();

  // Team Overrides
  Map<String, dynamic>? getTeamOverride(String teamId);
  Future<void> saveTeamOverride(String teamId, Map<String, dynamic> overrideData);
  Future<void> clearAllTeamOverrides();

  // Settings
  bool getUse24HourFormat();
  Future<void> saveUse24HourFormat(bool use24H);
}

class LocalDataSourceImpl implements LocalDataSource {
  late Box _matchOverridesBox;
  late Box _teamOverridesBox;
  late Box _settingsBox;

  static const String _matchBoxName = 'match_overrides';
  static const String _teamBoxName = 'team_overrides';
  static const String _settingsBoxName = 'settings_box';

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _matchOverridesBox = await Hive.openBox(_matchBoxName);
    _teamOverridesBox = await Hive.openBox(_teamBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  @override
  Future<List<TeamModel>> getBaseTeams() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/fixture_2026.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> teamsList = jsonMap['teams'] as List<dynamic>;
      return teamsList.map((t) => TeamModel.fromJson(t as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error parsing teams from assets: $e');
      return [];
    }
  }

  @override
  Future<List<StadiumModel>> getBaseStadiums() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/fixture_2026.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> stadiumsList = jsonMap['stadiums'] as List<dynamic>;
      return stadiumsList.map((s) => StadiumModel.fromJson(s as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error parsing stadiums from assets: $e');
      return [];
    }
  }

  @override
  Future<List<MatchModel>> getBaseMatches() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/fixture_2026.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> matchesList = jsonMap['matches'] as List<dynamic>;
      return matchesList.map((m) => MatchModel.fromJson(m as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error parsing matches from assets: $e');
      return [];
    }
  }

  // --- Match Overrides (Simulaciones, Favoritos y Recordatorios) ---
  @override
  Map<String, dynamic>? getMatchOverride(String matchId) {
    final data = _matchOverridesBox.get(matchId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  @override
  Future<void> saveMatchOverride(String matchId, Map<String, dynamic> overrideData) async {
    await _matchOverridesBox.put(matchId, overrideData);
  }

  @override
  Future<void> clearAllMatchOverrides() async {
    await _matchOverridesBox.clear();
  }

  // --- Team Overrides (Seguir selecciones) ---
  @override
  Map<String, dynamic>? getTeamOverride(String teamId) {
    final data = _teamOverridesBox.get(teamId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  @override
  Future<void> saveTeamOverride(String teamId, Map<String, dynamic> overrideData) async {
    await _teamOverridesBox.put(teamId, overrideData);
  }

  @override
  Future<void> clearAllTeamOverrides() async {
    await _teamOverridesBox.clear();
  }

  // --- Settings (Formato de hora 24h) ---
  @override
  bool getUse24HourFormat() {
    return _settingsBox.get('use24HourFormat', defaultValue: true) as bool;
  }

  @override
  Future<void> saveUse24HourFormat(bool use24H) async {
    await _settingsBox.put('use24HourFormat', use24H);
  }
}
