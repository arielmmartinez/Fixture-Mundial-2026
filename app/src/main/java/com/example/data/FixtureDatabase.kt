package com.example.data

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Entity(tableName = "match_overrides")
data class MatchOverrideEntity(
    @PrimaryKey val matchId: String,
    val homeScore: Int,
    val awayScore: Int,
    val status: String,
    val isFavorite: Boolean,
    val reminderEnabled: Boolean
)

@Entity(tableName = "team_overrides")
data class TeamOverrideEntity(
    @PrimaryKey val teamId: String,
    val isFollowing: Boolean
)

@Dao
interface FixtureDao {
    @Query("SELECT * FROM match_overrides")
    fun getMatchOverridesFlow(): Flow<List<MatchOverrideEntity>>

    @Query("SELECT * FROM match_overrides")
    suspend fun getMatchOverrides(): List<MatchOverrideEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMatchOverride(override: MatchOverrideEntity)

    @Query("SELECT * FROM team_overrides")
    fun getTeamOverridesFlow(): Flow<List<TeamOverrideEntity>>

    @Query("SELECT * FROM team_overrides")
    suspend fun getTeamOverrides(): List<TeamOverrideEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTeamOverride(override: TeamOverrideEntity)

    @Query("DELETE FROM match_overrides")
    suspend fun clearAllMatchOverrides()

    @Query("DELETE FROM team_overrides")
    suspend fun clearAllTeamOverrides()
}

@Database(entities = [MatchOverrideEntity::class, TeamOverrideEntity::class], version = 1, exportSchema = false)
abstract class FixtureDatabase : RoomDatabase() {
    abstract fun fixtureDao(): FixtureDao
}
