import '../../domain/entities/fixture_entities.dart';
import '../../domain/repositories/fixture_repository.dart';
import '../datasources/local_data_source.dart';

class FixtureRepositoryImpl implements FixtureRepository {
  final LocalDataSource localDataSource;

  FixtureRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Team>> getTeams() async {
    final baseModels = await localDataSource.getBaseTeams();
    return baseModels.map((teamModel) {
      final override = localDataSource.getTeamOverride(teamModel.id);
      final isFollowing = override?['isFollowing'] as bool? ?? false;
      return teamModel.toEntity(isFollowing: isFollowing);
    }).toList();
  }

  @override
  Future<List<Stadium>> getStadiums() async {
    final baseModels = await localDataSource.getBaseStadiums();
    return baseModels.map((stadiumModel) => stadiumModel.toEntity()).toList();
  }

  @override
  Future<List<Match>> getMatches() async {
    final baseModels = await localDataSource.getBaseMatches();
    return baseModels.map((matchModel) {
      final override = localDataSource.getMatchOverride(matchModel.id);
      final isFavorite = override?['isFavorite'] as bool? ?? false;
      final reminderEnabled = override?['reminderEnabled'] as bool? ?? false;
      final homeScoreOverride = override?['homeScore'] as int?;
      final awayScoreOverride = override?['awayScore'] as int?;
      final statusOverride = override?['status'] as String?;

      return matchModel.toEntity(
        isFavorite: isFavorite,
        reminderEnabled: reminderEnabled,
        homeScoreOverride: homeScoreOverride,
        awayScoreOverride: awayScoreOverride,
        statusOverride: statusOverride,
      );
    }).toList();
  }

  @override
  Future<void> toggleFavorite(String matchId) async {
    final currentOverride = localDataSource.getMatchOverride(matchId) ?? {};
    final currentFavorite = currentOverride['isFavorite'] as bool? ?? false;
    currentOverride['isFavorite'] = !currentFavorite;
    await localDataSource.saveMatchOverride(matchId, currentOverride);
  }

  @override
  Future<void> toggleReminder(String matchId) async {
    final currentOverride = localDataSource.getMatchOverride(matchId) ?? {};
    final currentReminder = currentOverride['reminderEnabled'] as bool? ?? false;
    currentOverride['reminderEnabled'] = !currentReminder;
    await localDataSource.saveMatchOverride(matchId, currentOverride);
  }

  @override
  Future<void> updateScore(String matchId, int homeScore, int awayScore, String status) async {
    final currentOverride = localDataSource.getMatchOverride(matchId) ?? {};
    currentOverride['homeScore'] = homeScore;
    currentOverride['awayScore'] = awayScore;
    currentOverride['status'] = status;
    await localDataSource.saveMatchOverride(matchId, currentOverride);
  }

  @override
  Future<void> toggleTeamFollowing(String teamId) async {
    final currentOverride = localDataSource.getTeamOverride(teamId) ?? {};
    final currentFollowing = currentOverride['isFollowing'] as bool? ?? false;
    currentOverride['isFollowing'] = !currentFollowing;
    await localDataSource.saveTeamOverride(teamId, currentOverride);
  }

  @override
  Future<void> resetSimulation() async {
    await localDataSource.clearAllMatchOverrides();
    await localDataSource.clearAllTeamOverrides();
  }

  @override
  bool getUse24HourFormat() {
    return localDataSource.getUse24HourFormat();
  }

  @override
  Future<void> saveUse24HourFormat(bool use24H) async {
    await localDataSource.saveUse24HourFormat(use24H);
  }
}
