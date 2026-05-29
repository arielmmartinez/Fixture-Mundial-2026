import '../entities/fixture_entities.dart';

abstract class FixtureRepository {
  Future<List<Team>> getTeams();
  Future<List<Stadium>> getStadiums();
  Future<List<Match>> getMatches();

  // Operaciones interactivas
  Future<void> toggleFavorite(String matchId);
  Future<void> toggleReminder(String matchId);
  Future<void> updateScore(String matchId, int homeScore, int awayScore, String status);
  Future<void> toggleTeamFollowing(String teamId);
  Future<void> resetSimulation();

  // Configuración
  bool getUse24HourFormat();
  Future<void> saveUse24HourFormat(bool use24H);
}
