package com.example.ui

import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.model.*
import com.example.viewmodel.FixtureViewModel
import java.util.Locale
import androidx.compose.animation.core.spring
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.BorderStroke
import com.example.ui.theme.*


// Enumerated list of 8 primary app sections
enum class AppSection(val label: String) {
    INICIO("Inicio"),
    FIXTURE("Fixture"),
    GRUPOS("Grupos"),
    SELECCIONES("Sedes/Países"),
    ESTADIOS("Estadios"),
    FAVORITOS("Mis Favoritos"),
    CONFIGURACION("Configuración")
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainLayoutScreen(
    viewModel: FixtureViewModel,
    modifier: Modifier = Modifier
) {
    var currentSection by remember { mutableStateOf(AppSection.INICIO) }
    var selectedMatchDetail by remember { mutableStateOf<Match?>(null) }
    val context = LocalContext.current

    val matches by viewModel.allMatches.collectAsStateWithLifecycle()
    val filteredMatches by viewModel.filteredMatches.collectAsStateWithLifecycle()
    val teams by viewModel.allTeams.collectAsStateWithLifecycle()
    val stadiums by viewModel.allStadiums.collectAsStateWithLifecycle()
    val standings by viewModel.groupStandings.collectAsStateWithLifecycle()
    val use24H by viewModel.use24HourFormat.collectAsStateWithLifecycle()
    val daysCount by viewModel.daysToWorldCup.collectAsStateWithLifecycle()

    val filterState by viewModel.filterState.collectAsStateWithLifecycle()
    val searchQuery = filterState.query
    val selectedGroup = filterState.group
    val selectedTeamId = filterState.teamId
    val selectedStadium = filterState.stadium
    val selectedCity = filterState.city
    val selectedCountry = filterState.country
    val selectedDay = filterState.day

    val isDark = isSystemInDarkTheme()
    val borderColor = if (isDark) BentoBorderDark else BentoBorderLight

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(
                            text = "Mundial 2026",
                            fontWeight = FontWeight.Black,
                            fontSize = 22.sp,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(8.dp))
                                .background(Color(0xFF10B981))
                                .padding(horizontal = 8.dp, vertical = 3.dp)
                        ) {
                            Text(
                                text = "FASE DE GRUPOS",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.ExtraBold,
                                color = Color.White
                            )
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.background,
                    titleContentColor = MaterialTheme.colorScheme.onBackground
                ),
                actions = {
                    if (currentSection == AppSection.FIXTURE) {
                        IconButton(onClick = { viewModel.clearAllFilters() }) {
                            Icon(Icons.Default.ClearAll, contentDescription = "Limpiar Filtros", tint = MaterialTheme.colorScheme.onBackground)
                        }
                    }
                }
            )
        },
        bottomBar = {
            NavigationBar(
                containerColor = MaterialTheme.colorScheme.background,
                tonalElevation = 0.dp,
                modifier = Modifier
                    .border(width = 1.dp, color = borderColor)
                    .testTag("app_navigation_bar")
            ) {
                // Navigation components
                AppSection.values().forEach { section ->
                    val isSelected = currentSection == section
                    val icon = when (section) {
                        AppSection.INICIO -> Icons.Default.Home
                        AppSection.FIXTURE -> Icons.Default.DateRange
                        AppSection.GRUPOS -> Icons.Default.List
                        AppSection.SELECCIONES -> Icons.Default.Flag
                        AppSection.ESTADIOS -> Icons.Default.Place
                        AppSection.FAVORITOS -> Icons.Default.Star
                        AppSection.CONFIGURACION -> Icons.Default.Settings
                    }

                    NavigationBarItem(
                        selected = isSelected,
                        onClick = { currentSection = section },
                        icon = { Icon(icon, contentDescription = section.label) },
                        label = {
                            Text(
                                text = section.label,
                                fontSize = 10.sp,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = Color(0xFF10B981),
                            selectedTextColor = Color(0xFF10B981),
                            indicatorColor = Color(0xFF10B981).copy(alpha = 0.15f),
                            unselectedIconColor = BentoSlate500,
                            unselectedTextColor = BentoSlate500
                        )
                    )
                }
            }
        },
        modifier = modifier
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .background(MaterialTheme.colorScheme.background)
        ) {
            Crossfade(
                targetState = currentSection,
                animationSpec = spring(),
                label = "Secciones"
            ) { section ->
                when (section) {
                    AppSection.INICIO -> {
                        HomeScreen(
                            daysCount = daysCount,
                            matches = matches,
                            viewModel = viewModel,
                            onMatchClick = { selectedMatchDetail = it },
                            onGoToFixture = { currentSection = AppSection.FIXTURE },
                            onGoToFavorites = { currentSection = AppSection.FAVORITOS },
                            onGoToGroups = { currentSection = AppSection.GRUPOS }
                        )
                    }
                    AppSection.FIXTURE -> {
                        FixtureScreen(
                            filteredMatches = filteredMatches,
                            teams = teams,
                            stadiums = stadiums,
                            searchQuery = searchQuery,
                            selectedGroup = selectedGroup,
                            selectedTeamId = selectedTeamId,
                            selectedStadium = selectedStadium,
                            selectedCity = selectedCity,
                            selectedCountry = selectedCountry,
                            selectedDay = selectedDay,
                            viewModel = viewModel,
                            onMatchClick = { selectedMatchDetail = it }
                        )
                    }
                    AppSection.GRUPOS -> {
                        GroupsScreen(
                            standings = standings,
                            matches = matches,
                            onMatchClick = { selectedMatchDetail = it }
                        )
                    }
                    AppSection.SELECCIONES -> {
                        TeamsScreen(
                            teams = teams,
                            matches = matches,
                            viewModel = viewModel,
                            onMatchClick = { selectedMatchDetail = it }
                        )
                    }
                    AppSection.ESTADIOS -> {
                        StadiumsScreen(
                            stadiums = stadiums,
                            matches = matches,
                            onMatchClick = { selectedMatchDetail = it }
                        )
                    }
                    AppSection.FAVORITOS -> {
                        FavoritesScreen(
                            matches = matches,
                            teams = teams,
                            viewModel = viewModel,
                            onMatchClick = { selectedMatchDetail = it }
                        )
                    }
                    AppSection.CONFIGURACION -> {
                        SettingsScreen(
                            use24H = use24H,
                            viewModel = viewModel
                        )
                    }
                }
            }

            // Custom detailed sheet/dialog
            selectedMatchDetail?.let { match ->
                val fullMatch = matches.find { it.id == match.id } ?: match
                MatchDetailDialog(
                    match = fullMatch,
                    use24H = use24H,
                    onDismiss = { selectedMatchDetail = null },
                    onToggleFavorite = { viewModel.toggleFavorite(match.id) },
                    onToggleReminder = { viewModel.toggleReminder(match.id) },
                    onUpdateScore = { hs, ascore, st ->
                        viewModel.updateScore(match.id, hs, ascore, st)
                        Toast.makeText(context, "Partido simulado exitosamente", Toast.LENGTH_SHORT).show()
                    }
                )
            }
        }
    }
}

// ==========================================
// 1. HOME / INICIO SCREEN (Bento Grid Theme)
// ==========================================
@Composable
fun HomeScreen(
    daysCount: Long,
    matches: List<Match>,
    viewModel: FixtureViewModel,
    onMatchClick: (Match) -> Unit,
    onGoToFixture: () -> Unit,
    onGoToFavorites: () -> Unit,
    onGoToGroups: () -> Unit
) {
    val isDark = isSystemInDarkTheme()
    val borderColor = if (isDark) BentoBorderDark else BentoBorderLight

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // --- BENTO BLOCK 1: Premium Countdown Card (Full-width grid head) ---
        item {
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .border(
                        width = 1.dp,
                        color = borderColor,
                        shape = RoundedCornerShape(32.dp)
                    ),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF0F172A)), // Deep Slate 900
                shape = RoundedCornerShape(32.dp)
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(24.dp)
                ) {
                    Column {
                        Text(
                            text = "CUENTA REGRESIVA",
                            fontSize = 10.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = Color(0xFF34D399), // Emerald 400
                            letterSpacing = 1.5.sp
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.Start
                        ) {
                            Text(
                                text = "$daysCount DÍAS",
                                fontSize = 42.sp,
                                fontWeight = FontWeight.Black,
                                fontStyle = androidx.compose.ui.text.font.FontStyle.Italic,
                                color = Color.White,
                                letterSpacing = (-1).sp
                            )
                        }
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Para el pitazo inicial en el Estadio Azteca",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium,
                            color = Color(0xFF94A3B8) // Slate 400
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Fase de grupos: 11 al 27 de junio de 2026",
                            fontSize = 11.sp,
                            color = Color(0xFF64748B) // Slate 500
                        )
                    }
                }
            }
        }

        // --- BENTO BLOCK 2 & 3: Side-by-Side Cards (col-span-1 in HTML) ---
        item {
            val nextMatch = matches.firstOrNull { it.status == "próximo" } ?: matches.firstOrNull()
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Next Match Bento Box
                Card(
                    modifier = Modifier
                        .weight(1f)
                        .height(136.dp)
                        .clickable { nextMatch?.let { onMatchClick(it) } }
                        .border(
                            width = 1.dp,
                            color = borderColor,
                            shape = RoundedCornerShape(28.dp)
                        ),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surface
                    ),
                    shape = RoundedCornerShape(28.dp)
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(16.dp),
                        verticalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = "PRÓXIMO DESTACADO",
                            fontSize = 9.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = BentoSlate500,
                            letterSpacing = 1.sp
                        )

                        if (nextMatch != null) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceEvenly,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text(nextMatch.homeFlag, fontSize = 24.sp)
                                    Spacer(modifier = Modifier.height(2.dp))
                                    Text(
                                        text = nextMatch.homeTeam.take(3).uppercase(Locale.getDefault()),
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Black,
                                        color = MaterialTheme.colorScheme.onSurface
                                    )
                                }

                                Text(
                                    text = "VS",
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Black,
                                    fontStyle = androidx.compose.ui.text.font.FontStyle.Italic,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.3f)
                                )

                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text(nextMatch.awayFlag, fontSize = 24.sp)
                                    Spacer(modifier = Modifier.height(2.dp))
                                    Text(
                                        text = nextMatch.awayTeam.take(3).uppercase(Locale.getDefault()),
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Black,
                                        color = MaterialTheme.colorScheme.onSurface
                                    )
                                }
                            }
                        } else {
                            Text("No Programado", fontSize = 11.sp, color = BentoSlate500)
                        }
                    }
                }

                // Group Stages Bento Box
                Card(
                    modifier = Modifier
                        .weight(1f)
                        .height(136.dp)
                        .clickable { onGoToGroups() }
                        .border(
                            width = 1.dp,
                            color = if (isDark) Color(0xFF049669) else Color(0xFF34D399),
                            shape = RoundedCornerShape(28.dp)
                        ),
                    colors = CardDefaults.cardColors(containerColor = Color(0xFF10B981)), // Emerald Green
                    shape = RoundedCornerShape(28.dp)
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(16.dp),
                        verticalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = "FASE DE GRUPOS",
                            fontSize = 9.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = Color.White.copy(alpha = 0.85f),
                            letterSpacing = 1.sp
                        )
                        Column {
                            Text(
                                text = "12 Grupos",
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Black,
                                color = Color.White
                            )
                            Spacer(modifier = Modifier.height(1.dp))
                            Text(
                                text = "48 países buscando la copa.",
                                fontSize = 10.sp,
                                color = Color.White.copy(alpha = 0.9f),
                                lineHeight = 12.sp
                            )
                        }
                    }
                }
            }
        }

        // --- BENTO BLOCK 4: Shortcut Navigation Bar (Primary Actions) ---
        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Button(
                    onClick = onGoToFixture,
                    shape = RoundedCornerShape(16.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF0F172A)), // Rich Deep Slate matches countdown
                    modifier = Modifier
                        .weight(1f)
                        .height(48.dp)
                ) {
                    Icon(Icons.Default.DateRange, contentDescription = "Fixture", tint = Color.White)
                    Spacer(modifier = Modifier.width(6.dp))
                    Text("Fixture completo", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color.White)
                }
                OutlinedButton(
                    onClick = onGoToFavorites,
                    border = BorderStroke(1.dp, borderColor),
                    shape = RoundedCornerShape(16.dp),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = MaterialTheme.colorScheme.onBackground),
                    modifier = Modifier
                        .weight(1f)
                        .height(48.dp)
                ) {
                    Icon(Icons.Default.Star, contentDescription = "Favoritos", tint = Color(0xFF10B981))
                    Spacer(modifier = Modifier.width(6.dp))
                    Text("Favoritos", fontSize = 12.sp, fontWeight = FontWeight.Bold)
                }
            }
        }

        // --- BENTO BLOCK 5: Header and Opening Matches ---
        val openingMatches = matches.take(5)
        item {
            Column {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Partidos de Apertura",
                        fontWeight = FontWeight.Black,
                        fontSize = 18.sp,
                        color = MaterialTheme.colorScheme.onBackground
                    )
                    Text(
                        text = "Ver todos",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF10B981),
                        modifier = Modifier
                            .clickable { onGoToFixture() }
                            .padding(4.dp)
                    )
                }
                Spacer(modifier = Modifier.height(10.dp))
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    openingMatches.forEach { match ->
                        MatchCardInline(
                            match = match,
                            onMatchClick = onMatchClick,
                            onToggleFavorite = { viewModel.toggleFavorite(match.id) }
                        )
                    }
                }
            }
        }

        // --- BENTO BLOCK 6: Local Persistence/Offline Mode Bento Box ---
        item {
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .border(
                        width = 1.dp,
                        color = borderColor,
                        shape = RoundedCornerShape(24.dp)
                    ),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f)
                ),
                shape = RoundedCornerShape(24.dp)
            ) {
                Column(modifier = Modifier.padding(20.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.Info,
                            contentDescription = "Soporte Offline",
                            tint = Color(0xFF10B981),
                            modifier = Modifier.size(18.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "Modo Offline Activo",
                            fontWeight = FontWeight.Bold,
                            fontSize = 13.sp,
                            color = MaterialTheme.colorScheme.onBackground
                        )
                    }
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "El fixture y las simulaciones se guardan de manera local. Puedes simular marcadores o configurar alarmas sin conexión a internet.",
                        fontSize = 11.sp,
                        lineHeight = 15.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }

        // --- BENTO BLOCK 7: Footer Legal Disclaimer ---
        item {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 12.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Esta aplicación no está afiliada ni patrocinada por la FIFA.",
                    fontSize = 10.sp,
                    color = BentoSlate500,
                    textAlign = TextAlign.Center
                )
                Text(
                    text = "Fixture y sedes sujetos a modificaciones oficiales.",
                    fontSize = 10.sp,
                    color = BentoSlate500,
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

// ==========================================
// 2. FIXTURE (MATCHES LIST WITH FILTERS)
// ==========================================
@Composable
fun FixtureScreen(
    filteredMatches: List<Match>,
    teams: List<Team>,
    stadiums: List<Stadium>,
    searchQuery: String,
    selectedGroup: String,
    selectedTeamId: String,
    selectedStadium: String,
    selectedCity: String,
    selectedCountry: String,
    selectedDay: String,
    viewModel: FixtureViewModel,
    onMatchClick: (Match) -> Unit
) {
    var showFiltersSheet by remember { mutableStateOf(false) }

    Column(modifier = Modifier.fillMaxSize()) {
        // Search & Filter header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            TextField(
                value = searchQuery,
                onValueChange = { viewModel.setSearchQuery(it) },
                placeholder = { Text("Buscar selección, estadio, ciudad...") },
                leadingIcon = { Icon(Icons.Default.Search, contentDescription = "Buscar") },
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = MaterialTheme.colorScheme.surface,
                    unfocusedContainerColor = MaterialTheme.colorScheme.surface,
                    disabledContainerColor = MaterialTheme.colorScheme.surface
                ),
                singleLine = true,
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(8.dp))
            )

            Button(
                onClick = { showFiltersSheet = !showFiltersSheet },
                colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
            ) {
                Icon(Icons.Default.FilterList, "Filtros")
                Spacer(modifier = Modifier.width(4.dp))
                Text("Filtrar")
            }
        }

        // Show/Hide filter options banner
        if (showFiltersSheet) {
            ElevatedCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp),
                colors = CardDefaults.elevatedCardColors(containerColor = MaterialTheme.colorScheme.surface)
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text("Filtros de Búsqueda", fontWeight = FontWeight.Bold, fontSize = 16.sp)

                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("Grupo: ", fontWeight = FontWeight.Bold, modifier = Modifier.width(80.dp))
                        ScrollablePillRow(
                            options = listOf("Todos") + ('A'..'L').map { "Grupo $it" },
                            selected = if (selectedGroup == "Todos") "Todos" else "Grupo $selectedGroup",
                            onSelect = {
                                if (it == "Todos") viewModel.setGroupFilter("Todos")
                                else viewModel.setGroupFilter(it.replace("Grupo ", ""))
                            }
                        )
                    }

                    // Filter 2: Host country
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("Sede: ", fontWeight = FontWeight.Bold, modifier = Modifier.width(80.dp))
                        ScrollablePillRow(
                            options = listOf("Todos", "México", "USA", "Canadá"),
                            selected = selectedCountry,
                            onSelect = { viewModel.setCountryFilter(it) }
                        )
                    }

                    // Clear filters
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "${filteredMatches.size} partidos encontrados",
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        TextButton(
                            onClick = {
                                viewModel.clearAllFilters()
                                showFiltersSheet = false
                            }
                        ) {
                            Text("Limpiar todo", color = MaterialTheme.colorScheme.error)
                        }
                    }
                }
            }
        }

        // Match list
        if (filteredMatches.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("⚽", fontSize = 48.sp)
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        "No se encontraron partidos con los filtros aplicados",
                        textAlign = TextAlign.Center,
                        color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f),
                        modifier = Modifier.padding(horizontal = 32.dp)
                    )
                }
            }
        } else {
            LazyColumn(
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.fillMaxSize()
            ) {
                items(filteredMatches) { match ->
                    MatchCard(
                        match = match,
                        onMatchClick = onMatchClick,
                        onToggleFavorite = { viewModel.toggleFavorite(match.id) },
                        onToggleReminder = { viewModel.toggleReminder(match.id) }
                    )
                }
            }
        }
    }
}

// Helper scrollable rows for filters
@Composable
fun ScrollablePillRow(
    options: List<String>,
    selected: String,
    onSelect: (String) -> Unit
) {
    LazyRow(
        horizontalArrangement = Arrangement.spacedBy(6.dp),
        contentPadding = PaddingValues(end = 12.dp)
    ) {
        items(options) { opt ->
            val isSelected = opt == selected
            Box(
                modifier = Modifier
                    .clip(CircleShape)
                    .background(
                        if (isSelected) MaterialTheme.colorScheme.primary
                        else MaterialTheme.colorScheme.surfaceVariant
                    )
                    .clickable { onSelect(opt) }
                    .padding(horizontal = 14.dp, vertical = 6.dp)
            ) {
                Text(
                    text = opt,
                    color = if (isSelected) Color.White else MaterialTheme.colorScheme.onSurfaceVariant,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

// Dynamic helper function extension to cast width nicely if needed
private fun Int.dp() = this.dp

// ==========================================
// 3. MATCH COMPONENT CARD (LARGE)
// ==========================================
@Composable
fun MatchCard(
    match: Match,
    onMatchClick: (Match) -> Unit,
    onToggleFavorite: () -> Unit,
    onToggleReminder: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isDark = isSystemInDarkTheme()
    val borderColor = if (isDark) BentoBorderDark else BentoBorderLight

    Card(
        modifier = modifier
            .fillMaxWidth()
            .clickable { onMatchClick(match) }
            .border(
                width = 1.dp,
                color = borderColor,
                shape = RoundedCornerShape(24.dp)
            )
            .testTag("match_card_${match.id}"),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        shape = RoundedCornerShape(24.dp)
    ) {
        Column(modifier = Modifier.padding(18.dp)) {
            // Group and status header
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(8.dp))
                            .background(Color(0xFF10B981).copy(alpha = 0.15f))
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text(
                            text = "GRUPO ${match.group}",
                            color = Color(0xFF10B981),
                            fontWeight = FontWeight.ExtraBold,
                            fontSize = 10.sp
                        )
                    }
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Partido #${match.matchNumber}",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Medium,
                        color = BentoSlate500
                    )
                }

                // Match status chip
                val statusColor = when (match.status) {
                    "en vivo" -> Color.Red
                    "finalizado" -> Color.Gray
                    else -> Color(0xFF10B981)
                }
                Box(
                    modifier = Modifier
                        .clip(CircleShape)
                        .background(statusColor.copy(alpha = 0.12f))
                        .padding(horizontal = 10.dp, vertical = 4.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        if (match.status == "en vivo") {
                            Box(
                                modifier = Modifier
                                    .size(6.dp)
                                    .clip(CircleShape)
                                    .background(Color.Red)
                            )
                        }
                        Text(
                            text = match.status.uppercase(Locale.getDefault()),
                            color = statusColor,
                            fontWeight = FontWeight.ExtraBold,
                            fontSize = 9.sp,
                            letterSpacing = 0.5.sp
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Scoreboard Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Home Team
                Row(
                    modifier = Modifier.weight(1.2f),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(match.homeFlag, fontSize = 28.sp)
                    Spacer(modifier = Modifier.width(10.dp))
                    Text(
                        text = match.homeTeam,
                        fontWeight = FontWeight.Bold,
                        fontSize = 16.sp,
                        color = MaterialTheme.colorScheme.onSurface,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                // Live Results / Versus Core
                Row(
                    modifier = Modifier.weight(1f),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    if (match.status != "próximo") {
                        Text(
                            text = "${match.homeScore}",
                            fontSize = 24.sp,
                            fontWeight = FontWeight.Black,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                        Spacer(modifier = Modifier.width(10.dp))
                        Text(
                            text = "-",
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
                        )
                        Spacer(modifier = Modifier.width(10.dp))
                        Text(
                            text = "${match.awayScore}",
                            fontSize = 24.sp,
                            fontWeight = FontWeight.Black,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                    } else {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(
                                text = match.localTime,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Black,
                                color = Color(0xFF10B981)
                            )
                            val cleanShortDate = if (match.date.length >= 10) match.date.substring(5) else match.date
                            Text(
                                text = cleanShortDate,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold,
                                color = BentoSlate500
                            )
                        }
                    }
                }

                // Away Team
                Row(
                    modifier = Modifier.weight(1.2f),
                    horizontalArrangement = Arrangement.End,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = match.awayTeam,
                        fontWeight = FontWeight.Bold,
                        fontSize = 16.sp,
                        color = MaterialTheme.colorScheme.onSurface,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Spacer(modifier = Modifier.width(10.dp))
                    Text(match.awayFlag, fontSize = 28.sp)
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Stadium, city, and action buttons footer
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Arena / City tag
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.weight(1f)
                ) {
                    Icon(
                        Icons.Default.Place,
                        contentDescription = "Ubicación",
                        tint = BentoSlate500,
                        modifier = Modifier.size(14.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "${match.stadium}, ${match.city} (${match.country})",
                        fontSize = 11.sp,
                        color = BentoSlate500,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                // Interactive icons
                Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    IconButton(
                        onClick = onToggleReminder,
                        modifier = Modifier.size(36.dp)
                    ) {
                        Icon(
                            imageVector = if (match.reminderEnabled) Icons.Default.NotificationsActive else Icons.Default.NotificationsNone,
                            contentDescription = "Establecer alarma",
                            tint = if (match.reminderEnabled) Color(0xFF10B981) else BentoSlate500,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                    IconButton(
                        onClick = onToggleFavorite,
                        modifier = Modifier.size(36.dp)
                    ) {
                        Icon(
                            imageVector = if (match.isFavorite) Icons.Default.Star else Icons.Default.StarBorder,
                            contentDescription = "Favorito",
                            tint = if (match.isFavorite) Color(0xFFF59E0B) else BentoSlate500,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }
        }
    }
}

// Inline list card (used in home & throughout lists, styled like the tailored Bento HTML preview)
@Composable
fun MatchCardInline(
    match: Match,
    onMatchClick: (Match) -> Unit,
    onToggleFavorite: () -> Unit
) {
    val isDark = isSystemInDarkTheme()
    val borderColor = if (isDark) BentoBorderDark else BentoBorderLight

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onMatchClick(match) }
            .border(
                width = 1.dp,
                color = borderColor,
                shape = RoundedCornerShape(20.dp)
            ),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        shape = RoundedCornerShape(20.dp)
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Left Box: Date graphic block
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(RoundedCornerShape(14.dp))
                    .background(if (isDark) Color(0xFF1E293B) else Color(0xFFF1F5F9))
                    .border(
                        width = 1.dp,
                        color = borderColor,
                        shape = RoundedCornerShape(14.dp)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    val monthStr = when {
                        match.date.length >= 7 -> when (match.date.substring(5, 7)) {
                            "06" -> "JUN"
                            "07" -> "JUL"
                            else -> "JUN"
                        }
                        else -> "JUN"
                    }
                    val dayStr = when {
                        match.date.length >= 10 -> match.date.substring(8, 10)
                        else -> "11"
                    }
                    Text(
                        text = monthStr,
                        fontSize = 9.sp,
                        fontWeight = FontWeight.ExtraBold,
                        color = BentoSlate500
                    )
                    Text(
                        text = dayStr,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Black,
                        color = MaterialTheme.colorScheme.onSurface,
                        lineHeight = 18.sp
                    )
                }
            }

            // Center Column: Team flag and name pairings
            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 12.dp),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Text(match.homeFlag, fontSize = 16.sp)
                    Text(
                        text = match.homeTeam,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                }
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Text(match.awayFlag, fontSize = 16.sp)
                    Text(
                        text = match.awayTeam,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                }
            }

            // Right Column: Live scores / Start times
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.End,
                modifier = Modifier.padding(end = 4.dp)
            ) {
                if (match.status != "próximo") {
                    Column(
                        horizontalAlignment = Alignment.End,
                        modifier = Modifier.padding(end = 8.dp)
                    ) {
                        Text(
                            text = "${match.homeScore} - ${match.awayScore}",
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Black,
                            color = if (match.status == "en vivo") Color.Red else MaterialTheme.colorScheme.onSurface
                        )
                        if (match.status == "en vivo") {
                            Text(
                                text = "EN VIVO",
                                fontSize = 8.sp,
                                fontWeight = FontWeight.ExtraBold,
                                color = Color.Red
                            )
                        } else {
                            Text(
                                text = "FINAL",
                                fontSize = 8.sp,
                                fontWeight = FontWeight.Bold,
                                color = BentoSlate500
                            )
                        }
                    }
                } else {
                    Column(
                        horizontalAlignment = Alignment.End,
                        modifier = Modifier.padding(end = 8.dp)
                    ) {
                        Text(
                            text = match.localTime,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Black,
                            color = Color(0xFF10B981)
                        )
                        Text(
                            text = match.city,
                            fontSize = 9.sp,
                            fontWeight = FontWeight.Bold,
                            color = BentoSlate500,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }

                // Favorite action
                IconButton(
                    onClick = onToggleFavorite,
                    modifier = Modifier.size(32.dp)
                ) {
                    Icon(
                        imageVector = if (match.isFavorite) Icons.Default.Star else Icons.Default.StarBorder,
                        contentDescription = "Favorito",
                        tint = if (match.isFavorite) Color(0xFFF59E0B) else BentoSlate500,
                        modifier = Modifier.size(18.dp)
                    )
                }
            }
        }
    }
}

// ==========================================
// 4. DETALLE DEL PARTIDO & RESULTS SIMULATOR
// ==========================================
@Composable
fun MatchDetailDialog(
    match: Match,
    use24H: Boolean,
    onDismiss: () -> Unit,
    onToggleFavorite: () -> Unit,
    onToggleReminder: () -> Unit,
    onUpdateScore: (Int, Int, String) -> Unit
) {
    var isSimulating by remember { mutableStateOf(false) }
    var homeSimScore by remember { mutableStateOf(match.homeScore) }
    var awaySimScore by remember { mutableStateOf(match.awayScore) }
    var simStatus by remember { mutableStateOf(match.status) }

    val context = LocalContext.current

    Dialog(onDismissRequest = onDismiss) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp)
                .testTag("match_detail_dialog"),
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
        ) {
            LazyColumn(
                modifier = Modifier.padding(20.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Header details
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                "MUNDIAL FIFA 2026",
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.primary,
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                "Grupo ${match.group} · Partido ${match.matchNumber}",
                                style = MaterialTheme.typography.bodyMedium,
                                fontWeight = FontWeight.SemiBold
                            )
                        }
                        IconButton(onClick = onDismiss) {
                            Icon(Icons.Default.Close, contentDescription = "Cerrar")
                        }
                    }
                }

                // Match Board
                item {
                    Card(
                        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceEvenly,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text(match.homeFlag, fontSize = 48.sp)
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(match.homeTeam, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                                }

                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    if (match.status != "próximo") {
                                        Text(
                                            "${match.homeScore} - ${match.awayScore}",
                                            fontSize = 32.sp,
                                            fontWeight = FontWeight.Black
                                        )
                                        Spacer(modifier = Modifier.height(4.dp))
                                        Badge(containerColor = if (match.status == "en vivo") Color.Red else Color.LightGray) {
                                            Text(match.status.uppercase(), modifier = Modifier.padding(2.dp))
                                        }
                                    } else {
                                        Text(
                                            "VS",
                                            fontSize = 24.sp,
                                            fontWeight = FontWeight.Black,
                                            color = MaterialTheme.colorScheme.primary.copy(alpha = 0.7f)
                                        )
                                    }
                                }

                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text(match.awayFlag, fontSize = 48.sp)
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(match.awayTeam, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                                }
                            }
                        }
                    }
                }

                // Interactive state row
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceEvenly
                    ) {
                        Button(
                            onClick = onToggleFavorite,
                            colors = ButtonDefaults.buttonColors(
                                containerColor = if (match.isFavorite) MaterialTheme.colorScheme.secondary else MaterialTheme.colorScheme.surfaceVariant
                            ),
                            shape = RoundedCornerShape(10.dp)
                        ) {
                            Icon(
                                if (match.isFavorite) Icons.Default.Star else Icons.Default.StarBorder,
                                contentDescription = "Favorito",
                                tint = if (match.isFavorite) Color.White else MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                if (match.isFavorite) "Favorito" else "Añadir Favorito",
                                color = if (match.isFavorite) Color.White else MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }

                        Button(
                            onClick = onToggleReminder,
                            colors = ButtonDefaults.buttonColors(
                                containerColor = if (match.reminderEnabled) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.surfaceVariant
                            ),
                            shape = RoundedCornerShape(10.dp)
                        ) {
                            Icon(
                                if (match.reminderEnabled) Icons.Default.NotificationsActive else Icons.Default.NotificationsNone,
                                contentDescription = "Alarma",
                                tint = if (match.reminderEnabled) Color.White else MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                if (match.reminderEnabled) "Recordatorio" else "Recordarme",
                                color = if (match.reminderEnabled) Color.White else MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }

                // Information & times
                item {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text("Detalles del Encuentro", fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        val fullDate = when (match.date) {
                            "2026-06-11" -> "Jueves 11 de Junio, 2026"
                            "2026-06-12" -> "Viernes 12 de Junio, 2026"
                            "2026-06-13" -> "Sábado 13 de Junio, 2026"
                            "2026-06-14" -> "Domingo 14 de Junio, 2026"
                            "2026-06-15" -> "Lunes 15 de Junio, 2026"
                            else -> "Junio, 2026"
                        }
                        DetailRow(Icons.Default.CalendarToday, "Fecha", fullDate)
                        DetailRow(Icons.Default.AccessTime, "Hora Sede", "${match.venueTime} (Hora Local)")
                        DetailRow(Icons.Default.AccessTime, "Hora Usuario", "${match.localTime} (Format 12/24h)")
                        DetailRow(Icons.Default.Place, "Estadio/Estadio", "${match.stadium}, ${match.city} (${match.country})")
                    }
                }

                // Simulated Map drawing instead of heavy external plugins! Best practice constraint
                item {
                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Text("Mapa Sede & Estadio", fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(120.dp)
                                .clip(RoundedCornerShape(8.dp))
                                .background(Color(0xFFE2E8F0))
                                .border(1.dp, Color.LightGray, RoundedCornerShape(8.dp)),
                            contentAlignment = Alignment.Center
                        ) {
                            Canvas(modifier = Modifier.fillMaxSize()) {
                                // Draw a stylized soccer field
                                val midX = size.width / 2
                                val midY = size.height / 2
                                drawRect(color = Color(0xFF38A169))
                                drawLine(color = Color.White, start = Offset(midX, 0f), end = Offset(midX, size.height), strokeWidth = 3f)
                                drawCircle(color = Color.White, radius = 25.dp.toPx(), center = Offset(midX, midY), style = androidx.compose.ui.graphics.drawscope.Stroke(3f))
                            }
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text("📍 Coord: ${match.latitude}, ${match.longitude}", fontWeight = FontWeight.Bold, color = Color.White, fontSize = 12.sp)
                                Spacer(modifier = Modifier.height(4.dp))
                                Text("Toca para abrir en Google Maps", fontSize = 10.sp, color = Color.White.copy(alpha = 0.9f))
                            }
                        }
                    }
                }

                // Interactive results predictor
                item {
                    if (!isSimulating) {
                        Button(
                            onClick = { isSimulating = true },
                            colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.secondary),
                            shape = RoundedCornerShape(10.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Icon(Icons.Default.Sports, "Simulador")
                            Spacer(modifier = Modifier.width(8.dp))
                            Text("Simular Resultado de Partido", color = MaterialTheme.colorScheme.onSecondary)
                        }
                    } else {
                        ElevatedCard(
                            colors = CardDefaults.elevatedCardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
                        ) {
                            Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                Text("Predictor / Simulador", fontWeight = FontWeight.Bold, fontSize = 13.sp)

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceAround,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    // Home score modifier
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        TextButton(onClick = { if (homeSimScore > 0) homeSimScore-- }) { Text("-", fontSize = 20.sp) }
                                        Text("$homeSimScore", fontSize = 22.sp, fontWeight = FontWeight.Bold)
                                        TextButton(onClick = { homeSimScore++ }) { Text("+", fontSize = 20.sp) }
                                    }

                                    Text("vs", fontSize = 14.sp)

                                    // Away score modifier
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        TextButton(onClick = { if (awaySimScore > 0) awaySimScore-- }) { Text("-", fontSize = 20.sp) }
                                        Text("$awaySimScore", fontSize = 22.sp, fontWeight = FontWeight.Bold)
                                        TextButton(onClick = { awaySimScore++ }) { Text("+", fontSize = 20.sp) }
                                    }
                                }

                                // Status toggle list
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceEvenly
                                ) {
                                    listOf("próximo", "en vivo", "finalizado").forEach { st ->
                                        val sel = simStatus == st
                                        ElevatedFilterChip(
                                            selected = sel,
                                            onClick = { simStatus = st },
                                            label = { Text(st.uppercase()) }
                                        )
                                    }
                                }

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                                ) {
                                    Button(
                                        onClick = {
                                            isSimulating = false
                                            onUpdateScore(homeSimScore, awaySimScore, simStatus)
                                        },
                                        modifier = Modifier.weight(1f)
                                    ) {
                                        Text("Guardar")
                                    }
                                    TextButton(
                                        onClick = { isSimulating = false },
                                        modifier = Modifier.weight(1f)
                                    ) {
                                        Text("Cancelar", color = MaterialTheme.colorScheme.error)
                                    }
                                }
                            }
                        }
                    }
                }

                // Apple Calendar fake trigger
                item {
                    Button(
                        onClick = {
                            Toast.makeText(context, "Se agregó el evento al calendario del dispositivo", Toast.LENGTH_SHORT).show()
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = Color.Black),
                        shape = RoundedCornerShape(10.dp),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("📅 Agregar a Calendario")
                    }
                }

                // Share partido
                item {
                    Button(
                        onClick = {
                            Toast.makeText(context, "Enlace para compartir copiado al portapapeles", Toast.LENGTH_SHORT).show()
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.1f)),
                        shape = RoundedCornerShape(10.dp),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Icon(Icons.Default.Share, "Share", tint = MaterialTheme.colorScheme.primary)
                        Spacer(modifier = Modifier.width(6.dp))
                        Text("Compartir Partido", color = MaterialTheme.colorScheme.primary)
                    }
                }
            }
        }
    }
}

@Composable
fun DetailRow(icon: androidx.compose.ui.graphics.vector.ImageVector, title: String, value: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(icon, contentDescription = title, tint = MaterialTheme.colorScheme.primary, modifier = Modifier.size(16.dp))
        Spacer(modifier = Modifier.width(10.dp))
        Text("$title: ", fontWeight = FontWeight.Bold, fontSize = 12.sp)
        Text(value, fontSize = 12.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
    }
}


// ==========================================
// 5. GRUPOS / GROUPS SCREEN
// ==========================================
@Composable
fun GroupsScreen(
    standings: Map<String, List<StandingRow>>,
    matches: List<Match>,
    onMatchClick: (Match) -> Unit
) {
    val letters = ('A'..'L').map { it.toString() }
    var selectedGroupTab by remember { mutableStateOf("A") }

    Column(modifier = Modifier.fillMaxSize()) {
        ScrollableTabRow(
            selectedTabIndex = letters.indexOf(selectedGroupTab),
            containerColor = MaterialTheme.colorScheme.surface,
            edgePadding = 16.dp
        ) {
            letters.forEach { char ->
                Tab(
                    selected = selectedGroupTab == char,
                    onClick = { selectedGroupTab = char },
                    text = { Text("G-$char", fontWeight = FontWeight.Bold) }
                )
            }
        }

        LazyColumn(
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
            modifier = Modifier.fillMaxSize()
        ) {
            item {
                Text(
                    "Tabla de Posiciones - Grupo $selectedGroupTab",
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp,
                    color = MaterialTheme.colorScheme.onBackground
                )
            }

            // Standings table head
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                ) {
                    Column(modifier = Modifier.padding(12.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text("#", fontWeight = FontWeight.Bold, fontSize = 11.sp, modifier = Modifier.width(20.dp))
                            Text("Equipo", fontWeight = FontWeight.Bold, fontSize = 11.sp, modifier = Modifier.weight(1f))
                            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                Text("PJ", fontWeight = FontWeight.Bold, fontSize = 11.sp, modifier = Modifier.width(20.dp))
                                Text("G", fontWeight = FontWeight.Bold, fontSize = 11.sp, modifier = Modifier.width(20.dp))
                                Text("E", fontWeight = FontWeight.Bold, fontSize = 11.sp, modifier = Modifier.width(20.dp))
                                Text("P", fontWeight = FontWeight.Bold, fontSize = 11.sp, modifier = Modifier.width(20.dp))
                                Text("DG", fontWeight = FontWeight.Bold, fontSize = 11.sp, modifier = Modifier.width(24.dp))
                                Text("Pts", fontWeight = FontWeight.Bold, fontSize = 11.sp, color = MaterialTheme.colorScheme.primary, modifier = Modifier.width(24.dp))
                            }
                        }

                        HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

                        // Dynamic standing rows
                        val rows = standings[selectedGroupTab] ?: emptyList()
                        if (rows.isEmpty()) {
                            Text("No se cargaron datos", fontSize = 12.sp, modifier = Modifier.padding(8.dp))
                        } else {
                            rows.forEachIndexed { index, row ->
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(vertical = 4.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text("${index + 1}", fontSize = 12.sp, fontWeight = FontWeight.Bold, modifier = Modifier.width(20.dp))
                                    Row(
                                        modifier = Modifier.weight(1f),
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Text(row.teamFlag, fontSize = 16.sp)
                                        Spacer(modifier = Modifier.width(6.dp))
                                        Text(
                                            text = row.teamName,
                                            fontSize = 12.sp,
                                            fontWeight = FontWeight.SemiBold,
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis
                                        )
                                    }
                                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                        Text("${row.played}", fontSize = 12.sp, modifier = Modifier.width(20.dp))
                                        Text("${row.won}", fontSize = 12.sp, modifier = Modifier.width(20.dp))
                                        Text("${row.drawn}", fontSize = 12.sp, modifier = Modifier.width(20.dp))
                                        Text("${row.lost}", fontSize = 12.sp, modifier = Modifier.width(20.dp))
                                        Text(
                                            text = if (row.goalDifference > 0) "+${row.goalDifference}" else "${row.goalDifference}",
                                            fontSize = 12.sp,
                                            fontWeight = FontWeight.Bold,
                                            modifier = Modifier.width(24.dp)
                                        )
                                        Text(
                                            text = "${row.points}",
                                            fontSize = 12.sp,
                                            fontWeight = FontWeight.Black,
                                            color = MaterialTheme.colorScheme.primary,
                                            modifier = Modifier.width(24.dp)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Matches for Group
            item {
                Text(
                    "Partidos del Grupo $selectedGroupTab",
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp,
                    color = MaterialTheme.colorScheme.onBackground
                )
            }

            val groupMatches = matches.filter { it.group == selectedGroupTab }
            items(groupMatches) { match ->
                MatchCardInline(
                    match = match,
                    onMatchClick = onMatchClick,
                    onToggleFavorite = {}
                )
            }
        }
    }
}


// ==========================================
// 6. TEAMS & HOSTS SECTION
// ==========================================
@Composable
fun TeamsScreen(
    teams: List<Team>,
    matches: List<Match>,
    viewModel: FixtureViewModel,
    onMatchClick: (Match) -> Unit
) {
    var teamSearchQuery by remember { mutableStateOf("") }
    val filteredTeams = teams.filter { it.name.contains(teamSearchQuery, ignoreCase = true) }

    Column(modifier = Modifier.fillMaxSize()) {
        TextField(
            value = teamSearchQuery,
            onValueChange = { teamSearchQuery = it },
            placeholder = { Text("Buscar Selecciones...") },
            leadingIcon = { Icon(Icons.Default.Search, contentDescription = "Buscar") },
            singleLine = true,
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
                .clip(RoundedCornerShape(8.dp))
        )

        LazyColumn(
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
            modifier = Modifier.fillMaxSize()
        ) {
            items(filteredTeams) { team ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                ) {
                    Column(modifier = Modifier.padding(14.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Text(team.flag, fontSize = 32.sp)
                                Spacer(modifier = Modifier.width(12.dp))
                                Column {
                                    Text(team.name, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                                    Text(
                                        "Confederación: ${team.confederation} · ranking: #${team.ranking}",
                                        fontSize = 11.sp,
                                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                                    )
                                }
                            }

                            // Follow team action button
                            Button(
                                onClick = { viewModel.toggleTeamFollowing(team.id) },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = if (team.isFollowing) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.surfaceVariant
                                ),
                                shape = RoundedCornerShape(8.dp),
                                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
                            ) {
                                Icon(
                                    if (team.isFollowing) Icons.Default.Check else Icons.Default.Add,
                                    contentDescription = "Follow",
                                    tint = if (team.isFollowing) Color.White else MaterialTheme.colorScheme.onSurfaceVariant,
                                    modifier = Modifier.size(14.dp)
                                )
                                Spacer(modifier = Modifier.width(4.dp))
                                Text(
                                    if (team.isFollowing) "Siguiendo" else "Seguir",
                                    color = if (team.isFollowing) Color.White else MaterialTheme.colorScheme.onSurfaceVariant,
                                    fontSize = 11.sp
                                )
                            }
                        }

                        // Team Match List
                        val teamMatches = matches.filter { it.homeTeam == team.id || it.awayTeam == team.id }
                        if (teamMatches.isNotEmpty()) {
                            Spacer(modifier = Modifier.height(10.dp))
                            Text("Próximos Partidos:", fontSize = 11.sp, fontWeight = FontWeight.Bold)
                            Spacer(modifier = Modifier.height(4.dp))
                            LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                items(teamMatches) { m ->
                                    Box(
                                        modifier = Modifier
                                            .clip(RoundedCornerShape(8.dp))
                                            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                                            .clickable { onMatchClick(m) }
                                            .padding(8.dp)
                                    ) {
                                        Text(
                                            "${m.homeFlag} vs ${m.awayFlag} · ${m.date.substring(5)}",
                                            fontSize = 10.sp,
                                            fontWeight = FontWeight.Bold
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


// ==========================================
// 7. STADIUMS / SEDES LIST
// ==========================================
@Composable
fun StadiumsScreen(
    stadiums: List<Stadium>,
    matches: List<Match>,
    onMatchClick: (Match) -> Unit
) {
    LazyColumn(
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
        modifier = Modifier.fillMaxSize()
    ) {
        item {
            Text(
                "Estadios Sedes Mundial 2026",
                fontWeight = FontWeight.Bold,
                fontSize = 18.sp,
                color = MaterialTheme.colorScheme.onBackground
            )
        }

        items(stadiums) { stadium ->
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
            ) {
                Column {
                    // Stylized Header Banner representing Stadium
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(100.dp)
                            .background(
                                Brush.linearGradient(
                                    listOf(
                                        MaterialTheme.colorScheme.primary,
                                        MaterialTheme.colorScheme.secondary.copy(alpha = 0.7f)
                                    )
                                )
                            )
                            .padding(16.dp),
                        contentAlignment = Alignment.BottomStart
                    ) {
                        Column {
                            Text(
                                text = stadium.name.uppercase(),
                                color = Color.White,
                                fontWeight = FontWeight.Black,
                                fontSize = 18.sp
                            )
                            Text(
                                text = "${stadium.city}, ${stadium.country}",
                                color = Color.White.copy(alpha = 0.9f),
                                fontSize = 12.sp
                            )
                        }
                    }

                    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text(stadium.description, fontSize = 12.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)

                        HorizontalDivider(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.12f))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Column {
                                Text("Capacidad", fontWeight = FontWeight.Bold, fontSize = 10.sp)
                                Text("${stadium.capacity} espectadores", fontSize = 12.sp)
                            }
                            Column(horizontalAlignment = Alignment.End) {
                                Text("Ubicación", fontWeight = FontWeight.Bold, fontSize = 10.sp)
                                Text("${stadium.latitude}, ${stadium.longitude}", fontSize = 12.sp, color = MaterialTheme.colorScheme.primary)
                            }
                        }

                        // Fixtures scheduled at this arena
                        val scheduledMatches = matches.filter { it.stadium == stadium.name }
                        if (scheduledMatches.isNotEmpty()) {
                            Spacer(modifier = Modifier.height(4.dp))
                            Text("Partidos Programados:", fontWeight = FontWeight.Bold, fontSize = 11.sp, color = MaterialTheme.colorScheme.primary)
                            scheduledMatches.forEach { m ->
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clip(RoundedCornerShape(6.dp))
                                        .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f))
                                        .clickable { onMatchClick(m) }
                                        .padding(8.dp),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text("G-${m.group} · #${m.matchNumber}", fontSize = 10.sp, fontWeight = FontWeight.Bold)
                                    Text("${m.homeFlag} ${m.homeTeam}  vs  ${m.awayFlag} ${m.awayTeam}", fontSize = 11.sp, fontWeight = FontWeight.SemiBold)
                                    Text(m.date.substring(5), fontSize = 10.sp)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


// ==========================================
// 8. FAVORITES & NOTIFICATIONS
// ==========================================
@Composable
fun FavoritesScreen(
    matches: List<Match>,
    teams: List<Team>,
    viewModel: FixtureViewModel,
    onMatchClick: (Match) -> Unit
) {
    val favMatches = matches.filter { it.isFavorite }
    val favTeams = teams.filter { it.isFollowing }
    val remMatches = matches.filter { it.reminderEnabled }

    LazyColumn(
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
        modifier = Modifier.fillMaxSize()
    ) {
        // Starred matches
        item {
            Text(
                "Partidos Guardados",
                fontWeight = FontWeight.Bold,
                fontSize = 18.sp,
                color = MaterialTheme.colorScheme.onBackground
            )
        }

        if (favMatches.isEmpty()) {
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        "No tienes partidos marcados como favoritos. Pulsa sobre la estrella en cualquier tarjeta para agregarlo aquí.",
                        fontSize = 12.sp,
                        textAlign = TextAlign.Center,
                        color = Color.Gray
                    )
                }
            }
        } else {
            items(favMatches) { match ->
                MatchCard(
                    match = match,
                    onMatchClick = onMatchClick,
                    onToggleFavorite = { viewModel.toggleFavorite(match.id) },
                    onToggleReminder = { viewModel.toggleReminder(match.id) }
                )
            }
        }

        // Active notification reminders
        item {
            Text(
                "Recordatorios Activos 🔔",
                fontWeight = FontWeight.Bold,
                fontSize = 18.sp,
                color = MaterialTheme.colorScheme.onBackground
            )
        }

        if (remMatches.isEmpty()) {
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        "No tienes recordatorios activos. Pulsa sobre la campana en los partidos para programar alarmas de inicio antes del juego.",
                        fontSize = 12.sp,
                        textAlign = TextAlign.Center,
                        color = Color.Gray
                    )
                }
            }
        } else {
            items(remMatches) { m ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.08f))
                ) {
                    Row(
                        modifier = Modifier.padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.NotificationsActive, "Alarm", tint = MaterialTheme.colorScheme.primary)
                            Spacer(modifier = Modifier.width(10.dp))
                            Column {
                                Text("${m.homeFlag} vs ${m.awayFlag}", fontWeight = FontWeight.Bold, fontSize = 14.sp)
                                Text("Comienza el ${m.date} a las ${m.localTime}", fontSize = 11.sp, color = Color.Gray)
                            }
                        }
                        IconButton(onClick = { viewModel.toggleReminder(m.id) }) {
                            Icon(Icons.Default.Delete, "Eliminar Alarma", tint = Color.Red.copy(alpha = 0.7f))
                        }
                    }
                }
            }
        }

        // Followed teams
        item {
            Text(
                "Selecciones Seguidas",
                fontWeight = FontWeight.Bold,
                fontSize = 18.sp,
                color = MaterialTheme.colorScheme.onBackground
            )
        }

        if (favTeams.isEmpty()) {
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        "No estás siguiendo ninguna selección aún. Pulsa el botón Seguir en la pestaña Sedes/Países.",
                        fontSize = 12.sp,
                        textAlign = TextAlign.Center,
                        color = Color.Gray
                    )
                }
            }
        } else {
            items(favTeams) { team ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                ) {
                    Row(
                        modifier = Modifier.padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(team.flag, fontSize = 24.sp)
                            Spacer(modifier = Modifier.width(10.dp))
                            Text(team.name, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        }
                        IconButton(onClick = { viewModel.toggleTeamFollowing(team.id) }) {
                            Icon(Icons.Default.Close, "Unfollow", tint = Color.Gray)
                        }
                    }
                }
            }
        }
    }
}


// ==========================================
// 9. SETTINGS & DISCLAIMERS SECTION
// ==========================================
@Composable
fun SettingsScreen(
    use24H: Boolean,
    viewModel: FixtureViewModel
) {
    val context = LocalContext.current

    LazyColumn(
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
        modifier = Modifier.fillMaxSize()
    ) {
        item {
            Text(
                "Configuración de la App",
                fontWeight = FontWeight.Bold,
                fontSize = 18.sp,
                color = MaterialTheme.colorScheme.onBackground
            )
        }

        // Time format preference
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text("Formato Horario", fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Text(if (use24H) "Formato activo 24 horas (ej. 19:00)" else "Formato activo 12 horas (ej. 7:00 PM)", fontSize = 11.sp, color = Color.Gray)
                    }
                    Switch(
                        checked = use24H,
                        onCheckedChange = { viewModel.toggleTimeFormat() }
                    )
                }
            }
        }

        // Reset Simulator
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Simulador de Resultados", fontWeight = FontWeight.Bold, fontSize = 14.sp)
                        Text("¿Simulaste partidos y deseas restablecer los marcadores oficiales y favoritos por defecto?", fontSize = 11.sp, color = Color.Gray)
                    }
                    Button(
                        onClick = {
                            viewModel.resetSimulation()
                            Toast.makeText(context, "Se restableció el calendario de partidos oficial", Toast.LENGTH_SHORT).show()
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
                    ) {
                        Icon(Icons.Default.Refresh, "Restablecer")
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("Reset")
                    }
                }
            }
        }

        // Languages, zones parameters
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("Parámetros del Sistema", fontWeight = FontWeight.Bold, fontSize = 14.sp)

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text("Idioma del contenido", fontSize = 12.sp)
                        Text("Español (ES) 🇪🇸", fontWeight = FontWeight.Bold, fontSize = 12.sp, color = MaterialTheme.colorScheme.primary)
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text("Zona Horaria de Dispositivo", fontSize = 12.sp)
                        Text("Auto-Detectada UTC -5", fontWeight = FontWeight.Bold, fontSize = 12.sp, color = MaterialTheme.colorScheme.primary)
                    }

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text("Notificaciones de Lanzamiento", fontSize = 12.sp)
                        Text("Habilitado ✔", fontWeight = FontWeight.Bold, fontSize = 12.sp, color = MaterialTheme.colorScheme.primary)
                    }
                }
            }
        }

        // MANDATORY LEGAL DISCLAIMER - STRICT GUIDELINES COMPLIANCE
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Aviso Legal Importante", fontWeight = FontWeight.Bold, fontSize = 12.sp, color = Color.Gray)
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = "Esta aplicación es de carácter informativo y simulación construida con fines educativos y de consulta personal. Esta app no está afiliada, asociada, patrocinada de ningún modo por FIFA ni los entes reguladores de fútbol mundiales o nacionales. Las imágenes, marcas, banderas o denominaciones comerciales registradas de la FIFA se mencionan bajo fines meramente informativos y siguen siendo de su propiedad exclusiva. La información del fixture de partidos oficiales está sujeta a modificaciones.",
                        fontSize = 11.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        lineHeight = 15.sp,
                        textAlign = TextAlign.Justify
                    )
                }
            }
        }
    }
}
