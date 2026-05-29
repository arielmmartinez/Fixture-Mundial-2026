import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/bento_theme.dart';
import 'data/datasources/local_data_source.dart';
import 'data/repositories/fixture_repository_impl.dart';
import 'domain/repositories/fixture_repository.dart';
import 'presentation/providers/fixture_provider.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/fixture/fixture_screen.dart';
import 'presentation/groups/groups_screen.dart';
import 'presentation/teams/teams_screen.dart';
import 'presentation/stadiums/stadiums_screen.dart';
import 'presentation/favorites/favorites_screen.dart';
import 'presentation/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    if (message.contains('ListTile background color or ink splashes may be invisible')) {
      return;
    }
    FlutterError.presentError(details);
  };

  // Initialize Data Source & Hive Box Storage
  final localDataSource = LocalDataSourceImpl();
  await localDataSource.init();

  final repository = FixtureRepositoryImpl(localDataSource: localDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FixtureProvider>(
          create: (_) => FixtureProvider(repository: repository)..loadData(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundial 2026',
      debugShowCheckedModeBanner: false,
      theme: BentoTheme.lightTheme,
      darkTheme: BentoTheme.darkTheme,
      themeMode: ThemeMode.system, // Enforce dark/light mode following OS settings
      home: const MainNavigationFrame(),
    );
  }
}

class MainNavigationFrame extends StatefulWidget {
  const MainNavigationFrame({Key? key}) : super(key: key);

  @override
  _MainNavigationFrameState createState() => _MainNavigationFrameState();
}

class _MainNavigationFrameState extends State<MainNavigationFrame> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FixtureProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? BentoColors.bentoBorderDark : BentoColors.bentoBorderLight;

    // Screens list
    final List<Widget> screens = [
      HomeScreen(onNavigate: (index) {
        setState(() {
          _currentIndex = index;
        });
      }),
      const FixtureScreen(),
      const GroupsScreen(),
      const TeamsScreen(),
      const StadiumsScreen(),
      const FavoritesScreen(),
      const SettingsScreen(),
    ];

    // Navigation Labels
    final List<String> titles = [
      'Inicio',
      'Fixture',
      'Grupos',
      'Selecciones',
      'Estadios',
      'Favoritos',
      'Configuración',
    ];

    return Scaffold(
      appBar: null, // Removed default appBar to enforce cinematic full screen edge-to-edge layout
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
      bottomNavigationBar: Container(
        height: 74,
        decoration: BoxDecoration(
          color: BentoColors.pitchDark,
          border: const Border(
            top: BorderSide(color: BentoColors.bentoBorderLight, width: 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: BentoColors.soccerGreen.withOpacity(0.08),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Inicio'),
              _buildNavItem(1, Icons.calendar_month_outlined, Icons.calendar_month, 'Fixture'),
              _buildNavItem(2, Icons.format_list_bulleted, Icons.format_list_bulleted_rounded, 'Grupos'),
              _buildNavItem(3, Icons.flag_outlined, Icons.flag, 'Países'),
              _buildNavItem(4, Icons.place_outlined, Icons.place, 'Estadios'),
              _buildNavItem(5, Icons.star_border, Icons.star, 'Favoritos'),
              _buildNavItem(6, Icons.settings_outlined, Icons.settings, 'Ajustes'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? BentoColors.soccerGreen.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? BentoColors.soccerGreen : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: BentoColors.soccerGreen.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  color: isSelected ? BentoColors.soccerGreen : BentoColors.bentoSlate500,
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.black : FontWeight.bold,
                  color: isSelected ? BentoColors.soccerGreen : BentoColors.bentoSlate500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  }
}
