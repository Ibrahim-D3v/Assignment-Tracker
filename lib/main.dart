import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/assignment_provider.dart';
import 'providers/theme_provider.dart';
import 'models/assignment_model.dart';
import 'screens/dashboard_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/insights_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapter
  Hive.registerAdapter(AssignmentAdapter());

  // Initialize Provider before app launch to ensure Box is open
  final assignmentProvider = AssignmentProvider();
  await assignmentProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: assignmentProvider),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const AssignmentManagerApp(),
    ),
  );
}

class AssignmentManagerApp extends StatelessWidget {
  const AssignmentManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Exact color specifications compiled from your design token chart
    const Color brandPrimary = Color(0xFF6F4E37);
    const Color brandSecondary = Color(0xFFA18262);
    const Color brandTertiary = Color(0xFF3E2723);
    const Color brandNeutralBg = Color(0xFFF5F0EA);
    const Color brandCardLight = Color(0xFFFFFFFF);

    // Dark-mode counterparts matching your asset parameters
    const Color brandPrimaryDark = Color(0xFFFFD4B9);
    const Color brandSecondaryDark = Color(0xFF8C6D53);
    const Color brandSurfaceDark = Color(0xFF2C2017);
    const Color brandCardDark = Color(0xFF3E2723);

    return MaterialApp(
      title: 'EduCalm',
      debugShowCheckedModeBanner: false,

      // ==========================================
      // LIGHT THEME (COMPATIBLE MATERIAL 2)
      // ==========================================
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: brandPrimary,
        scaffoldBackgroundColor: brandNeutralBg,
        cardColor: brandCardLight,
        canvasColor: brandNeutralBg,

        appBarTheme: const AppBarTheme(
          backgroundColor: brandNeutralBg,
          elevation: 0,
          iconTheme: IconThemeData(color: brandPrimary),
          titleTextStyle: TextStyle(
            color: brandPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        cardTheme: const CardThemeData(
          color: brandCardLight,
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        ),

        textTheme: const TextTheme(
          titleLarge: TextStyle(color: brandTertiary, fontWeight: FontWeight.bold, fontSize: 24),
          bodyLarge: TextStyle(color: brandTertiary, fontSize: 16),
          bodyMedium: TextStyle(color: brandTertiary, fontSize: 14),
          bodySmall: TextStyle(color: brandSecondary, fontSize: 12),
        ),

        colorScheme: const ColorScheme.light(
          primary: brandPrimary,
          secondary: brandSecondary,
          surface: brandCardLight,
          onSurface: brandTertiary,
        ),
      ),

      // ==========================================
      // DARK THEME (COMPATIBLE MATERIAL 2)
      // ==========================================
      darkTheme: ThemeData(
        useMaterial3: false,
        primaryColor: brandPrimaryDark,
        scaffoldBackgroundColor: const Color(0xFF1D1B18),
        cardColor: brandCardDark,
        canvasColor: brandSurfaceDark,

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1D1B18),
          elevation: 0,
          iconTheme: IconThemeData(color: brandPrimaryDark),
          titleTextStyle: TextStyle(
            color: brandPrimaryDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        cardTheme: const CardThemeData(
          color: brandCardDark,
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        ),

        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Color(0xFFF5F0EA), fontWeight: FontWeight.bold, fontSize: 24),
          bodyLarge: TextStyle(color: Color(0xFFF5F0EA), fontSize: 16),
          bodyMedium: TextStyle(color: Color(0xFFF5F0EA), fontSize: 14),
          bodySmall: TextStyle(color: brandSecondaryDark, fontSize: 12),
        ),

        colorScheme: const ColorScheme.dark(
          primary: brandPrimaryDark,
          secondary: brandSecondaryDark,
          surface: brandCardDark,
          onSurface: Color(0xFFF5F0EA),
        ),
      ),

      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      home: const MainNavigationShell(),
    );
  }
}

// ==========================================
// CENTRAL BOTTOM NAVIGATION FRAMEWORK
// ==========================================
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const FocusScreen(),
    const InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: theme.scaffoldBackgroundColor,
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.4),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer),
              label: 'Focus',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Insights',
            ),
          ],
        ),
      ),
    );
  }
}