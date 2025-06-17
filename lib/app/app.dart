import 'package:flutter/material.dart';
import '../pages/home/home_page.dart';
import '../pages/market/market_page.dart';
import '../pages/strategy/strategy_page.dart';
import '../pages/portfolio/portfolio_page.dart';
import '../pages/profile/profile_page.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScaffold(),
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MarketPage(),
    const PortfolioPage(),
    const StrategyPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Market'),
          NavigationDestination(
              icon: Icon(Icons.psychology), label: 'Strategy'),
          NavigationDestination(
              icon: Icon(Icons.pie_chart), label: 'Portfolio'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
