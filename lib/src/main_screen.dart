import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/shows/popular_shows_view.dart';
import 'features/shows/search_shows_view.dart';
import 'features/user/favorites_view.dart';
import 'features/user/user_profile_view.dart';
import 'providers/theme_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PopularShowsView(),
    const SearchShowsView(),
    const FavoritesView(),
    const UserProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        // Adaptive layout based on screen size
        final isTablet = MediaQuery.of(context).size.width > 600;

        return Scaffold(
          body: isTablet
          // Tablet: use a side navigation rail
              ? Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                labelType: NavigationRailLabelType.selected,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    selectedIcon: Icon(Icons.home),
                    label: Text('Accueil'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.search),
                    selectedIcon: Icon(Icons.search),
                    label: Text('Recherche'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    selectedIcon: Icon(Icons.favorite),
                    label: Text('Favoris'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Profil'),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: _screens[_selectedIndex],
              ),
            ],
          )
          // Phone: use bottom navigation bar
              : _screens[_selectedIndex],
          bottomNavigationBar: isTablet
              ? null // No bottom navigation for tablets
              : NavigationBar(
            onDestinationSelected: _onItemTapped,
            selectedIndex: _selectedIndex,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Accueil',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Recherche',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_outline),
                selectedIcon: Icon(Icons.favorite),
                label: 'Favoris',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}