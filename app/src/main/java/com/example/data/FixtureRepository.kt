package com.example.data

import android.content.Context
import com.example.model.*
import com.squareup.moshi.Moshi
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flow
import java.io.InputStream

class FixtureRepository(
    private val context: Context,
    private val dao: FixtureDao
) {
    private val moshi = Moshi.Builder()
        .addLast(KotlinJsonAdapterFactory())
        .build()

    private val fixtureAdapter = moshi.adapter(FixtureData::class.java)

    // Parse base data once from local assets asset file.
    private val baseData: FixtureData by lazy {
        try {
            val jsonString = context.assets.open("fixture_2026.json").use { inputStream ->
                inputStream.bufferedReader().use { it.readText() }
            }
            fixtureAdapter.fromJson(jsonString) ?: FixtureData(emptyList(), emptyList(), emptyList())
        } catch (e: Exception) {
            e.printStackTrace()
            FixtureData(emptyList(), emptyList(), emptyList())
        }
    }

    // Expose flow of Combined Matches (base + overrides)
    fun getMatchesFlow(): Flow<List<Match>> {
        return dao.getMatchOverridesFlow().combine(flow { emit(baseData.matches) }) { overrides, baseList ->
            val overrideMap = overrides.associateBy { it.matchId }
            baseList.map { match ->
                val override = overrideMap[match.id]
                if (override != null) {
                    match.copy(
                        homeScore = override.homeScore,
                        awayScore = override.awayScore,
                        status = override.status,
                        isFavorite = override.isFavorite,
                        reminderEnabled = override.reminderEnabled
                    )
                } else {
                    match
                }
            }
        }
    }

    // Expose flow of Combined Teams (base + overrides)
    fun getTeamsFlow(): Flow<List<Team>> {
        return dao.getTeamOverridesFlow().combine(flow { emit(baseData.teams) }) { overrides, baseList ->
            val overrideMap = overrides.associateBy { it.teamId }
            baseList.map { team ->
                val override = overrideMap[team.id]
                if (override != null) {
                    team.copy(isFollowing = override.isFollowing)
                } else {
                    team
                }
            }
        }
    }

    // Expose flow of Stadiums (static)
    fun getStadiumsFlow(): Flow<List<Stadium>> {
        return flow {
            emit(baseData.stadiums)
        }
    }

    // Write a Match Override
    suspend fun saveMatchOverride(match: Match) {
        val entity = MatchOverrideEntity(
            matchId = match.id,
            homeScore = match.homeScore,
            awayScore = match.awayScore,
            status = match.status,
            isFavorite = match.isFavorite,
            reminderEnabled = match.reminderEnabled
        )
        dao.insertMatchOverride(entity)
    }

    // Toggle match favorite status
    suspend fun toggleFavorite(matchId: String) {
        val matches = getMatchesList()
        val match = matches.find { it.id == matchId } ?: return
        val updated = match.copy(isFavorite = !match.isFavorite)
        saveMatchOverride(updated)
    }

    // Toggle match reminder status
    suspend fun toggleReminder(matchId: String) {
        val matches = getMatchesList()
        val match = matches.find { it.id == matchId } ?: return
        val updated = match.copy(reminderEnabled = !match.reminderEnabled)
        saveMatchOverride(updated)
    }

    // Update Score
    suspend fun updateScore(matchId: String, homeScore: Int, awayScore: Int, status: String) {
        val matches = getMatchesList()
        val match = matches.find { it.id == matchId } ?: return
        val updated = match.copy(
            homeScore = homeScore,
            awayScore = awayScore,
            status = status
        )
        saveMatchOverride(updated)
    }

    // Toggle Team following
    suspend fun toggleTeamFollowing(teamId: String) {
        val teams = getTeamsList()
        val team = teams.find { it.id == teamId } ?: return
        val entity = TeamOverrideEntity(
            teamId = team.id,
            isFollowing = !team.isFollowing
        )
        dao.insertTeamOverride(entity)
    }

    // Reset all overrides
    suspend fun resetAllOverrides() {
        dao.clearAllMatchOverrides()
        dao.clearAllTeamOverrides()
    }

    // Helper to get raw snapshot list (for internal edits)
    private suspend fun getMatchesList(): List<Match> {
        val overrides = dao.getMatchOverrides().associateBy { it.matchId }
        return baseData.matches.map { match ->
            val ov = overrides[match.id]
            if (ov != null) {
                match.copy(
                    homeScore = ov.homeScore,
                    awayScore = ov.awayScore,
                    status = ov.status,
                    isFavorite = ov.isFavorite,
                    reminderEnabled = ov.reminderEnabled
                )
            } else {
                match
            }
        }
    }

    private suspend fun getTeamsList(): List<Team> {
        val overrides = dao.getTeamOverrides().associateBy { it.teamId }
        return baseData.teams.map { team ->
            val ov = overrides[team.id]
            if (ov != null) {
                team.copy(isFollowing = ov.isFollowing)
            } else {
                team
            }
        }
    }
}
