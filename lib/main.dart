import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/home_provider.dart';
import 'providers/search_provider.dart';
import 'providers/lists_provider.dart';
import 'screens/home_screen.dart';
import 'screens/lists_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ListsProvider()),
      ],
      child: const ImdbApp(),
    ),
  );
}

class ImdbApp extends StatefulWidget {
  const ImdbApp({super.key});

  @override
  State<ImdbApp> createState() => _ImdbAppState();
}

class _ImdbAppState extends State<ImdbApp> {
  bool _isDark = true;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineSearch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(primary: Colors.amber.shade700),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: ColorScheme.dark(
          primary: Colors.amber.shade700,
          surface: const Color(0xFF1A1A1A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0D0D),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const HomeScreen(),
            const ListsScreen(),
            SettingsScreen(
              isDark: _isDark,
              onToggleTheme: () => setState(() => _isDark = !_isDark),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Entdecken',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_outlined),
              selectedIcon: Icon(Icons.list),
              label: 'Meine Listen',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Einstellungen',
            ),
          ],
        ),
      ),
    );
  }
}
