import 'package:flutter/material.dart';
import 'screens/calendar_screen.dart';
import 'screens/drivers_screen.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/standings_screen.dart';
import 'screens/teams_screen.dart';
import 'state/shop_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const F1App());
}

class F1App extends StatelessWidget {
  const F1App({super.key});

  static final ShopState _shopState = ShopState();

  @override
  Widget build(BuildContext context) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.f1Red,
      brightness: Brightness.dark,
    );

    return ShopScope(
      notifier: _shopState,
      child: MaterialApp(
        title: 'F1 2026 Info',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: baseScheme.copyWith(
            primary: AppColors.f1Red,
            secondary: const Color(0xFFFF4444),
            surface: AppColors.f1Card,
            surfaceContainerHighest: const Color(0xFF242426),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
          ),
          scaffoldBackgroundColor: AppColors.f1Black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0A0A0A),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 24,
              letterSpacing: 1.2,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          cardTheme: CardThemeData(
            color: AppColors.f1Card,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF2C2C2E)),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: const Color(0xFF111111),
            indicatorColor: AppColors.f1Red.withAlpha(60),
            labelTextStyle: const WidgetStatePropertyAll(
              TextStyle(
                fontSize: 10.5,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: AppColors.f1Red);
              }
              return const IconThemeData(color: Colors.white38);
            }),
          ),
          textTheme: const TextTheme(
            displaySmall: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            titleLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            titleMedium: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            titleSmall: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            bodyMedium: TextStyle(color: Colors.white70),
            bodySmall: TextStyle(color: Colors.white54),
            labelLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            labelMedium: TextStyle(color: Colors.white70),
            labelSmall: TextStyle(color: Colors.white54),
          ),
        ),
        home: _StartupGate(shopState: _shopState),
      ),
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate({required this.shopState});

  final ShopState shopState;

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      widget.shopState.load(),
      Future<void>.delayed(const Duration(milliseconds: 1700)),
    ]);
    if (mounted) setState(() => _isReady = true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 550),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: _isReady
          ? const AppShell(key: ValueKey('app-shell'))
          : const LoadingScreen(key: ValueKey('loading-screen')),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(onNavigate: (index) => setState(() => _currentIndex = index)),
    const TeamsScreen(),
    const DriversScreen(),
    const CalendarScreen(),
    const StandingsScreen(),
    const ShopScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;
          return NavigationBar(
            height: 68,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups),
                label: 'Teams',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Drivers',
              ),
              NavigationDestination(
                icon: const Icon(Icons.event_note_outlined),
                selectedIcon: const Icon(Icons.event_note),
                label: compact ? 'Races' : 'Calendar',
                tooltip: 'Race Calendar',
              ),
              NavigationDestination(
                icon: const Icon(Icons.emoji_events_outlined),
                selectedIcon: const Icon(Icons.emoji_events),
                label: compact ? 'Ranks' : 'Standings',
                tooltip: 'Championship Standings',
              ),
              const NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: 'Shop',
              ),
            ],
          );
        },
      ),
    );
  }
}
