package com.example.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.room.Room
import com.example.data.FixtureDatabase
import com.example.data.FixtureRepository
import com.example.model.*
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

// Unified state for filters to bypass Flow combine multi-arity limits
data class FilterState(
    val query: String = "",
    val group: String = "Todos",
    val teamId: String = "Todos",
    val stadium: String = "Todos",
    val city: String = "Todos",
    val country: String = "Todos",
    val day: String = "Todos",
    val onlyFavorites: Boolean = false
)

class FixtureViewModel(application: Application) : AndroidViewModel(application) {

    private val db = Room.databaseBuilder(
        application,
        FixtureDatabase::class.java, "fixture_db"
    ).build()

    private val repository = FixtureRepository(application, db.fixtureDao())

    // --- State Injections for UI ---
    val allMatches: StateFlow<List<Match>> = repository.getMatchesFlow()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val allTeams: StateFlow<List<Team>> = repository.getTeamsFlow()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val allStadiums: StateFlow<List<Stadium>> = repository.getStadiumsFlow()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    // --- Unified Filter State ---
    private val _filterState = MutableStateFlow(FilterState())
    val filterState = _filterState.asStateFlow()

    // --- Saved Configuration Prefs ---
    private val _use24HourFormat = MutableStateFlow(true)
    val use24HourFormat = _use24HourFormat.asStateFlow()

    fun toggleTimeFormat() {
        _use24HourFormat.value = !_use24HourFormat.value
    }

    // --- Filtered Matches Logic ---
    val filteredMatches: StateFlow<List<Match>> = combine(
        allMatches,
        _filterState
    ) { matches, filters ->
        matches.filter { match ->
            val matchesQuery = filters.query.isEmpty() ||
                    match.stadium.contains(filters.query, ignoreCase = true) ||
                    match.city.contains(filters.query, ignoreCase = true) ||
                    match.homeTeam.contains(filters.query, ignoreCase = true) ||
                    match.awayTeam.contains(filters.query, ignoreCase = true)

            val matchesGroup = filters.group == "Todos" || match.group == filters.group
            val matchesTeam = filters.teamId == "Todos" || match.homeTeam == filters.teamId || match.awayTeam == filters.teamId
            val matchesStadium = filters.stadium == "Todos" || match.stadium == filters.stadium
            val matchesCity = filters.city == "Todos" || match.city == filters.city
            val matchesCountry = filters.country == "Todos" || match.country == filters.country
            val matchesDay = filters.day == "Todos" || match.date == filters.day
            val matchesFavorites = !filters.onlyFavorites || match.isFavorite

            matchesQuery && matchesGroup && matchesTeam && matchesStadium && matchesCity && matchesCountry && matchesDay && matchesFavorites
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // --- Standings Auto-Calculation ---
    val groupStandings: StateFlow<Map<String, List<StandingRow>>> = combine(
        allTeams,
        allMatches
    ) { teams, matches ->
        val groups = teams.groupBy { it.group }
        val finalMap = mutableMapOf<String, List<StandingRow>>()

        groups.forEach { (groupName, groupTeams) ->
            val rows = groupTeams.map { team ->
                var played = 0
                var won = 0
                var drawn = 0
                var lost = 0
                var goalsFor = 0
                var goalsAgainst = 0
                var points = 0

                val teamMatches = matches.filter { m ->
                    m.group == groupName && m.status == "finalizado" && (m.homeTeam == team.id || m.awayTeam == team.id)
                }

                teamMatches.forEach { m ->
                    played++
                    if (m.homeTeam == team.id) {
                        goalsFor += m.homeScore
                        goalsAgainst += m.awayScore
                        when {
                            m.homeScore > m.awayScore -> {
                                won++
                                points += 3
                            }
                            m.homeScore == m.awayScore -> {
                                drawn++
                                points += 1
                            }
                            else -> lost++
                        }
                    } else {
                        goalsFor += m.awayScore
                        goalsAgainst += m.homeScore
                        when {
                            m.awayScore > m.homeScore -> {
                                won++
                                points += 3
                            }
                            m.awayScore == m.homeScore -> {
                                drawn++
                                points += 1
                            }
                            else -> lost++
                        }
                    }
                }

                StandingRow(
                    teamId = team.id,
                    teamName = team.name,
                    teamFlag = team.flag,
                    played = played,
                    won = won,
                    drawn = drawn,
                    lost = lost,
                    goalsFor = goalsFor,
                    goalsAgainst = goalsAgainst,
                    goalDifference = goalsFor - goalsAgainst,
                    points = points
                )
            }.sortedWith(
                compareByDescending<StandingRow> { it.points }
                    .thenByDescending { it.goalDifference }
                    .thenByDescending { it.goalsFor }
                    .then { a, b ->
                        val rankingA = teams.find { it.id == a.teamId }?.ranking ?: 100
                        val rankingB = teams.find { it.id == b.teamId }?.ranking ?: 100
                        rankingA.compareTo(rankingB)
                    }
            )
            finalMap[groupName] = rows
        }
        finalMap
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyMap())

    // --- Interactive Operations ---
    fun toggleFavorite(matchId: String) {
        viewModelScope.launch {
            repository.toggleFavorite(matchId)
        }
    }

    fun toggleReminder(matchId: String) {
        viewModelScope.launch {
            repository.toggleReminder(matchId)
        }
    }

    fun updateScore(matchId: String, homeScore: Int, awayScore: Int, status: String) {
        viewModelScope.launch {
            repository.updateScore(matchId, homeScore, awayScore, status)
        }
    }

    fun toggleTeamFollowing(teamId: String) {
        viewModelScope.launch {
            repository.toggleTeamFollowing(teamId)
        }
    }

    fun resetSimulation() {
        viewModelScope.launch {
            repository.resetAllOverrides()
        }
    }

    // --- Search & Filter Mutators ---
    fun setSearchQuery(query: String) {
        _filterState.value = _filterState.value.copy(query = query)
    }

    fun setGroupFilter(group: String) {
        _filterState.value = _filterState.value.copy(group = group)
    }

    fun setTeamFilter(teamId: String) {
        _filterState.value = _filterState.value.copy(teamId = teamId)
    }

    fun setStadiumFilter(stadium: String) {
        _filterState.value = _filterState.value.copy(stadium = stadium)
    }

    fun setCityFilter(city: String) {
        _filterState.value = _filterState.value.copy(city = city)
    }

    fun setCountryFilter(country: String) {
        _filterState.value = _filterState.value.copy(country = country)
    }

    fun setDayFilter(day: String) {
        _filterState.value = _filterState.value.copy(day = day)
    }

    fun setFavoritesOnly(favoritesOnly: Boolean) {
        _filterState.value = _filterState.value.copy(onlyFavorites = favoritesOnly)
    }

    // Clear all filters to default
    fun clearAllFilters() {
        _filterState.value = FilterState()
    }

    // Countdown Logic (Target: June 11, 2026)
    val daysToWorldCup: StateFlow<Long> = flow {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val targetDate = sdf.parse("2026-06-11") ?: Date()

        while (true) {
            val today = Calendar.getInstance().time
            val diff = targetDate.time - today.time
            val days = diff / (1000 * 60 * 60 * 24)
            val cleanDays = if (days < 0) 0L else days
            emit(cleanDays)
            kotlinx.coroutines.delay(60000)
        }
    }.stateIn(viewModelScope, SharingStarted.Lazily, 13L)
}
