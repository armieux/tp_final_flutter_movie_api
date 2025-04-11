import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_data_provider.dart';
import 'favorites_view.dart';
import 'statistics_view.dart';
import 'theme_settings_view.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, child) {
          final statsData = userDataProvider.statistics;
          final isDataAvailable = userDataProvider.favorites.isNotEmpty ||
              userDataProvider.watchedEpisodes.isNotEmpty ||
              userDataProvider.ratings.isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar and stats summary
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Télé-spectateur',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isDataAvailable
                                ? 'Vous avez regardé ${statsData['totalEpisodesWatched'] ?? 0} épisodes de ${statsData['uniqueShowsWatched'] ?? 0} séries différentes'
                                : 'Suivez vos séries préférées et gardez une trace de votre visionnage',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Statistiques rapides
                if (isDataAvailable)
                  _buildQuickStats(statsData),

                const SizedBox(height: 24),

                // User menu
                _buildUserMenu(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> statsData) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mes statistiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _statItem(
                    Icons.favorite,
                    'Favoris',
                    '${statsData['favoritesCount'] ?? 0}',
                    Colors.red[400]!,
                  ),
                ),
                Expanded(
                  child: _statItem(
                    Icons.movie,
                    'Épisodes vus',
                    '${statsData['totalEpisodesWatched'] ?? 0}',
                    Colors.green[400]!,
                  ),
                ),
                Expanded(
                  child: _statItem(
                    Icons.star,
                    'Note moyenne',
                    '${(statsData['averageRating'] as double? ?? 0).toStringAsFixed(1)}/5',
                    Colors.amber[400]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mon compte',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),

        _menuItem(
          context,
          Icons.favorite,
          'Mes séries favorites',
          'Gérez votre liste de séries préférées',
              () => Navigator.pushNamed(context, FavoritesView.routeName),
        ),

        _menuItem(
          context,
          Icons.analytics,
          'Mes statistiques',
          'Consultez vos statistiques de visionnage',
              () => Navigator.pushNamed(context, StatisticsView.routeName),
        ),

        _menuItem(
          context,
          Icons.color_lens,
          'Thèmes et apparence',
          'Personnalisez l\'apparence de l\'application',
              () => Navigator.pushNamed(context, ThemeSettingsView.routeName),
        ),

        _menuItem(
          context,
          Icons.settings,
          'Paramètres',
          'Gérez les paramètres de l\'application',
              () => Navigator.pushNamed(context, '/settings'),
        ),
      ],
    );
  }

  Widget _menuItem(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}