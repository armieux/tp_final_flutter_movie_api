import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/user_data_provider.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  static const routeName = '/statistics';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Statistiques'),
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, child) {
          final statsData = userDataProvider.statistics;
          final hasData = (statsData['totalEpisodesWatched'] ?? 0) > 0;

          if (!hasData) {
            return _buildEmptyState();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Récapitulatif du visionnage
                    _buildWatchingSummary(context, statsData),

                    const SizedBox(height: 24),

                    // Top séries
                    if ((statsData['topShows'] as List).isNotEmpty)
                      _buildTopShows(context, statsData),

                    const SizedBox(height: 24),

                    // Graphiques
                    if (isTablet)
                    // Layout tablette : graphiques côte à côte
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildRatingDistribution(context, statsData),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildWeekdayDistribution(context, statsData),
                          ),
                        ],
                      )
                    else
                    // Layout téléphone : graphiques empilés
                      Column(
                        children: [
                          _buildRatingDistribution(context, statsData),
                          const SizedBox(height: 24),
                          _buildWeekdayDistribution(context, statsData),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Pas encore de statistiques disponibles',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez à suivre vos séries et à marquer\nles épisodes comme vus',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.movie),
            label: const Text('Découvrir des séries'),
            onPressed: () {
              Navigator.pushReplacementNamed(Navigator.of(navigatorKey.currentContext!).context, '/');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWatchingSummary(BuildContext context, Map<String, dynamic> statsData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Récapitulatif',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCounter(
                  context,
                  Icons.movie,
                  statsData['totalEpisodesWatched']?.toString() ?? '0',
                  'Épisodes',
                ),
                _buildStatCounter(
                  context,
                  Icons.tv,
                  statsData['uniqueShowsWatched']?.toString() ?? '0',
                  'Séries',
                ),
                _buildStatCounter(
                  context,
                  Icons.favorite,
                  statsData['favoritesCount']?.toString() ?? '0',
                  'Favoris',
                ),
                _buildStatCounter(
                  context,
                  Icons.star,
                  statsData['ratingsCount']?.toString() ?? '0',
                  'Notes',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCounter(
      BuildContext context,
      IconData icon,
      String value,
      String label,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTopShows(BuildContext context, Map<String, dynamic> statsData) {
    final topShows = statsData['topShows'] as List;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Séries les plus regardées',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...topShows.map((show) => _buildTopShowItem(context, show)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopShowItem(BuildContext context, Map<String, dynamic> show) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text('${topShows.indexOf(show) + 1}'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  show['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${show['episodesWatched']} épisodes regardés',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution(BuildContext context, Map<String, dynamic> statsData) {
    final ratingDistribution = statsData['ratingDistribution'] as List? ?? [];

    if (ratingDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCount = ratingDistribution
        .map<int>((item) => item['count'] as int)
        .fold(0, (prev, count) => count > prev ? count : prev);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribution des notes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxCount.toDouble() * 1.2,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('');
                          if (value % 1 != 0) return const Text('');
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${value.toInt()} ★',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: ratingDistribution.map((item) {
                    final rating = item['rating'] as int;
                    final count = item['count'] as int;

                    return BarChartGroupData(
                      x: rating,
                      barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          color: _getRatingColor(rating),
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayDistribution(BuildContext context, Map<String, dynamic> statsData) {
    final weekdayDistribution = statsData['weekdayDistribution'] as List? ?? [];

    if (weekdayDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activité par jour',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: weekdayDistribution
                      .map<int>((item) => item['count'] as int)
                      .fold(0, (prev, count) => count > prev ? count : prev)
                      .toDouble() * 1.2,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('');
                          if (value % 1 != 0) return const Text('');
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final weekdays = ['', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              weekdays[value.toInt()],
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: weekdayDistribution.map((item) {
                    final weekday = item['weekday'] as int;
                    final count = item['count'] as int;

                    return BarChartGroupData(
                      x: weekday,
                      barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          color: Theme.of(context).colorScheme.primary,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red[300]!;
      case 2:
        return Colors.orange[300]!;
      case 3:
        return Colors.yellow[600]!;
      case 4:
        return Colors.lightGreen[400]!;
      case 5:
        return Colors.green[400]!;
      default:
        return Colors.grey;
    }
  }
}

// NavigatorKey pour accéder au contexte depuis n'importe où
final navigatorKey = GlobalKey<NavigatorState>();

// Liste pour les tests
List<Map<String, dynamic>> get topShows => [
  {'id': 1, 'name': 'Game of Thrones', 'episodesWatched': 73},
  {'id': 2, 'name': 'Breaking Bad', 'episodesWatched': 62},
  {'id': 3, 'name': 'Stranger Things', 'episodesWatched': 34},
  {'id': 4, 'name': 'The Walking Dead', 'episodesWatched': 28},
  {'id': 5, 'name': 'The Office', 'episodesWatched': 25},
];