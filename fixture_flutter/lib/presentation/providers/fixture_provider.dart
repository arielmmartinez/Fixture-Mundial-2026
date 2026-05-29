import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/fixture_entities.dart';
import '../../domain/repositories/fixture_repository.dart';
import '../../core/utils/notification_service.dart';

class FilterState {
  final String query;
  final String group;
  final String teamId;
  final String stadium;
  final String city;
  final String country;
  final String day;
  final bool onlyFavorites;

  FilterState({
    this.query = '',
    this.group = 'Todos',
    this.teamId = 'Todos',
    this.stadium = 'Todos',
    this.city = 'Todos',
    this.country = 'Todos',
    this.day = 'Todos',
    this.onlyFavorites = false,
  });

  FilterState copyWith({
    String? query,
    String? group,
    String? teamId,
    String? stadium,
    String? city,
    String? country,
    String? day,
    bool? onlyFavorites,
  }) {
    return FilterState(
      query: query ?? this.query,
      group: group ?? this.group,
      teamId: teamId ?? this.teamId,
      stadium: stadium ?? this.stadium,
      city: city ?? this.city,
      country: country ?? this.country,
      day: day ?? this.day,
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
    );
  }
}

class FixtureProvider extends ChangeNotifier {
  final FixtureRepository repository;

  List<Match> _allMatches = [];
  List<Team> _allTeams = [];
  List<Stadium> _allStadiums = [];

  FilterState _filterState = FilterState();
  bool _use24HourFormat = true;
  bool _isLoading = false;
  int _daysToWorldCup = 0;
  Timer? _countdownTimer;

  FixtureProvider({required this.repository}) {
    _use24HourFormat = repository.getUse24HourFormat();
    _startCountdown();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await NotificationService().init();
    await NotificationService().requestPermissions();
  }

  // --- Getters ---
  List<Match> get allMatches => _allMatches;
  List<Team> get allTeams => _allTeams;
  List<Stadium> get allStadiums => _allStadiums;
  FilterState get filterState => _filterState;
  bool get use24HourFormat => _use24HourFormat;
  bool get isLoading => _isLoading;
  int get daysToWorldCup => _daysToWorldCup;

  // --- Load Data ---
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allMatches = await repository.getMatches();
      _allTeams = await repository.getTeams();
      _allStadiums = await repository.getStadiums();
    } catch (e) {
      print('Error loading data in Provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Filtered Matches ---
  List<Match> get filteredMatches {
    return _allMatches.filter((match) {
      final matchesQuery = _filterState.query.isEmpty ||
          match.stadium.toLowerCase().contains(_filterState.query.toLowerCase()) ||
          match.city.toLowerCase().contains(_filterState.query.toLowerCase()) ||
          match.homeTeam.toLowerCase().contains(_filterState.query.toLowerCase()) ||
          match.awayTeam.toLowerCase().contains(_filterState.query.toLowerCase());

      final matchesGroup = _filterState.group == 'Todos' || match.group == _filterState.group;
      final matchesTeam = _filterState.teamId == 'Todos' ||
          match.homeTeam == _filterState.teamId ||
          match.awayTeam == _filterState.teamId;
      final matchesStadium = _filterState.stadium == 'Todos' || match.stadium == _filterState.stadium;
      final matchesCity = _filterState.city == 'Todos' || match.city == _filterState.city;
      final matchesCountry = _filterState.country == 'Todos' || match.country == _filterState.country;
      final matchesDay = _filterState.day == 'Todos' || match.date == _filterState.day;
      final matchesFavorites = !_filterState.onlyFavorites || match.isFavorite;

      return matchesQuery &&
          matchesGroup &&
          matchesTeam &&
          matchesStadium &&
          matchesCity &&
          matchesCountry &&
          matchesDay &&
          matchesFavorites;
    }).toList();
  }

  // --- Standings Auto-Calculation ---
  Map<String, List<StandingRow>> get groupStandings {
    final Map<String, List<StandingRow>> standings = {};

    // Group teams by their group
    final Map<String, List<Team>> groups = {};
    for (var team in _allTeams) {
      groups.putIfAbsent(team.group, () => []).add(team);
    }

    groups.forEach((groupName, groupTeams) {
      final List<StandingRow> rows = groupTeams.map((team) {
        int played = 0;
        int won = 0;
        int drawn = 0;
        int lost = 0;
        int goalsFor = 0;
        int goalsAgainst = 0;
        int points = 0;

        final teamMatches = _allMatches.where((m) {
          return m.group == groupName &&
              m.status == 'finalizado' &&
              (m.homeTeam == team.id || m.awayTeam == team.id);
        });

        for (var m in teamMatches) {
          played++;
          if (m.homeTeam == team.id) {
            goalsFor += m.homeScore;
            goalsAgainst += m.awayScore;
            if (m.homeScore > m.awayScore) {
              won++;
              points += 3;
            } else if (m.homeScore == m.awayScore) {
              drawn++;
              points += 1;
            } else {
              lost++;
            }
          } else {
            goalsFor += m.awayScore;
            goalsAgainst += m.homeScore;
            if (m.awayScore > m.homeScore) {
              won++;
              points += 3;
            } else if (m.awayScore == m.homeScore) {
              drawn++;
              points += 1;
            } else {
              lost++;
            }
          }
        }

        return StandingRow(
          teamId: team.id,
          teamName: team.name,
          teamFlag: team.flag,
          played: played,
          won: won,
          drawn: drawn,
          lost: lost,
          goalsFor: goalsFor,
          goalsAgainst: goalsAgainst,
          goalDifference: goalsFor - goalsAgainst,
          points: points,
        );
      }).toList();

      // Sort standing rows following precise tie-breaker rules
      rows.sort((a, b) {
        // 1. Points (descending)
        if (b.points != a.points) {
          return b.points.compareTo(a.points);
        }
        // 2. Goal Difference (descending)
        if (b.goalDifference != a.goalDifference) {
          return b.goalDifference.compareTo(a.goalDifference);
        }
        // 3. Goals For (descending)
        if (b.goalsFor != a.goalsFor) {
          return b.goalsFor.compareTo(a.goalsFor);
        }
        // 4. FIFA ranking (ascending, lower is better)
        final rankingA = _allTeams.firstWhere((t) => t.id == a.teamId).ranking;
        final rankingB = _allTeams.firstWhere((t) => t.id == b.teamId).ranking;
        return rankingA.compareTo(rankingB);
      });

      standings[groupName] = rows;
    });

    return standings;
  }

  // --- Actions ---
  Future<void> toggleFavorite(String matchId) async {
    await repository.toggleFavorite(matchId);
    await loadData();
  }

  Future<void> toggleReminder(String matchId) async {
    await repository.toggleReminder(matchId);
    await loadData();
    try {
      final updatedMatch = _allMatches.firstWhere((m) => m.id == matchId);
      if (updatedMatch.reminderEnabled) {
        await NotificationService().scheduleMatchNotification(updatedMatch);
      } else {
        await NotificationService().cancelMatchNotification(updatedMatch);
      }
    } catch (e) {
      print('Error scheduling/cancelling notification: $e');
    }
  }

  Future<void> updateScore(String matchId, int homeScore, int awayScore, String status) async {
    await repository.updateScore(matchId, homeScore, awayScore, status);
    await loadData();
  }

  Future<void> toggleTeamFollowing(String teamId) async {
    await repository.toggleTeamFollowing(teamId);
    await loadData();
  }

  Future<void> toggleTimeFormat() async {
    _use24HourFormat = !_use24HourFormat;
    await repository.saveUse24HourFormat(_use24HourFormat);
    notifyListeners();
  }

  Future<void> resetSimulation() async {
    await repository.resetSimulation();
    await loadData();
  }

  // --- Filter Mutators ---
  void setSearchQuery(String query) {
    _filterState = _filterState.copyWith(query: query);
    notifyListeners();
  }

  void setGroupFilter(String group) {
    _filterState = _filterState.copyWith(group: group);
    notifyListeners();
  }

  void setTeamFilter(String teamId) {
    _filterState = _filterState.copyWith(teamId: teamId);
    notifyListeners();
  }

  void setStadiumFilter(String stadium) {
    _filterState = _filterState.copyWith(stadium: stadium);
    notifyListeners();
  }

  void setCityFilter(String city) {
    _filterState = _filterState.copyWith(city: city);
    notifyListeners();
  }

  void setCountryFilter(String country) {
    _filterState = _filterState.copyWith(country: country);
    notifyListeners();
  }

  void setDayFilter(String day) {
    _filterState = _filterState.copyWith(day: day);
    notifyListeners();
  }

  void setFavoritesOnly(bool favoritesOnly) {
    _filterState = _filterState.copyWith(onlyFavorites: favoritesOnly);
    notifyListeners();
  }

  void clearAllFilters() {
    _filterState = FilterState();
    notifyListeners();
  }

  // --- Countdown Logic ---
  void _startCountdown() {
    final targetDate = DateTime(2026, 6, 11);

    void updateDays() {
      final now = DateTime.now();
      final diff = targetDate.difference(now);
      final days = diff.inDays;
      _daysToWorldCup = days < 0 ? 0 : days;
      notifyListeners();
    }

    updateDays();
    _countdownTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      updateDays();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

extension _IterableFilter<T> on List<T> {
  List<T> filter(bool Function(T element) test) {
    final List<T> result = [];
    for (var element in this) {
      if (test(element)) {
        result.add(element);
      }
    }
    return result;
  }
}
