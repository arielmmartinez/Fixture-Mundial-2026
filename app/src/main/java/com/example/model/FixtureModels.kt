package com.example.model

import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class Team(
    val id: String,          // e.g. "MEX"
    val name: String,        // e.g. "México"
    val shortName: String,   // e.g. "MEX"
    val flag: String,        // e.g. "🇲🇽"
    val group: String,       // e.g. "A"
    val confederation: String, // e.g. "CONCACAF"
    val ranking: Int,
    val isFollowing: Boolean = false // Set locally by user
)

@JsonClass(generateAdapter = true)
data class Stadium(
    val id: String,
    val name: String,
    val city: String,
    val country: String,
    val capacity: Int,
    val latitude: Double,
    val longitude: Double,
    val description: String,
    val imageUrl: String
)

@JsonClass(generateAdapter = true)
data class Match(
    val id: String,
    val matchNumber: Int,
    val group: String,
    val homeTeam: String, // "MEX"
    val awayTeam: String, // "ECU"
    val homeFlag: String,
    val awayFlag: String,
    val date: String,     // e.g. "2026-06-11"
    val localTime: String, // e.g. "18:00"
    val venueTime: String, // e.g. "18:00"
    val stadium: String,
    val city: String,
    val country: String,
    val venue: String,
    val status: String,    // "próximo", "en vivo", "finalizado"
    val homeScore: Int = 0,
    val awayScore: Int = 0,
    val isFavorite: Boolean = false,
    val reminderEnabled: Boolean = false,
    val latitude: Double = 0.0,
    val longitude: Double = 0.0,
    val notes: String = ""
)

// Dynamic stats calculated from matches
data class StandingRow(
    val teamId: String,
    val teamName: String,
    val teamFlag: String,
    val played: Int,
    val won: Int,
    val drawn: Int,
    val lost: Int,
    val goalsFor: Int,
    val goalsAgainst: Int,
    val goalDifference: Int,
    val points: Int
)

@JsonClass(generateAdapter = true)
data class FixtureData(
    val teams: List<Team>,
    val stadiums: List<Stadium>,
    val matches: List<Match>
)
