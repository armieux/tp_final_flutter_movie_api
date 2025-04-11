import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../models/tv_show_details.dart';
import '../../models/tv_show_episode.dart';
import '../../models/tv_show.dart';
import '../../models/user_data.dart';
import '../../services/tv_show_service.dart';
import '../../providers/user_data_provider.dart';

class ShowDetailsView extends StatefulWidget {
  const ShowDetailsView({super.key});

  static const routeName = '/show-details';

  @override
  State<ShowDetailsView> createState() => _ShowDetailsViewState();
}

class _ShowDetailsViewState extends State<ShowDetailsView> with SingleTickerProviderStateMixin {
  final TvShowService _tvShowService = TvShowService();
  late Future<TvShowDetails> _showDetailsFuture;
  late TabController _tabController;
  final _notesController = TextEditingController();
  double _userRating = 0;
  bool _isRatingDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context)?.settings.arguments;

    // Vérifier si les arguments sont null ou non
    if (routeArgs == null) {
      // Gérer le cas où il n'y a pas d'arguments
      setState(() {
        _showDetailsFuture = Future.error("Aucun identifiant de série fourni");
      });
      return;
    }

    // S'assurer que routeArgs est bien une String
    final showId = routeArgs.toString();
        _showDetailsFuture = _tvShowService.getShowDetails(showId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, child) {
        return Scaffold(
          body: FutureBuilder<TvShowDetails>(
            future: _showDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Affichage amélioré des erreurs
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur lors du chargement',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Retour'),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData) {
                return const Center(child: Text('Aucune donnée disponible'));
              }

              try {
                final show = snapshot.data!;

                // Convertir en TvShow pour certaines opérations
                final tvShow = TvShow(
                  id: show.id,
                  name: show.name,
                  permalink: show.permalink,
                  startDate: show.startDate,
                  endDate: show.endDate,
                  country: show.country,
                  network: show.network,
                  status: show.status,
                  thumbnailPath: show.thumbnailPath,
                );

                // Vérifier si la série est dans les favoris
                FutureBuilder<bool>(
                  future: userDataProvider.isFavorite(show.id),
                  builder: (context, snapshot) {
                    final isFavorite = snapshot.data ?? false;
                    return Container(); // Placeholder
                  },
                );

                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 300.0,
                        floating: false,
                        pinned: true,
                        actions: [
                          FutureBuilder<bool>(
                            future: userDataProvider.isFavorite(show.id),
                            builder: (context, snapshot) {
                              final isFavorite = snapshot.data ?? false;
                              return IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : null,
                                ),
                                onPressed: () {
                                  userDataProvider.toggleFavorite(tvShow);
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.star),
                            onPressed: () {
                              _showRatingDialog(context, tvShow, userDataProvider);
                            },
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            show.name,
                            style: const TextStyle(
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                            ),
                          ),
                          background: Hero(
                            tag: 'show_${show.id}',
                            child: CachedNetworkImage(
                              imageUrl: show.imagePath,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.error)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ratings row
                              Row(
                                children: [
                                  // API rating
                                  Icon(Icons.star, color: Colors.amber[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${show.rating}/10',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '(${show.ratingCount})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),

                                  const SizedBox(width: 20),

                                  // User rating if exists
                                  FutureBuilder<ShowRating?>(
                                    future: userDataProvider.getShowRating(show.id),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData && snapshot.data != null) {
                                        return Row(
                                          children: [
                                            Icon(Icons.star_rate, color: Colors.deepOrange[400]),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Votre note: ${snapshot.data!.rating}/5',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Status and genres
                              Wrap(
                                spacing: 8,
                                children: [
                                  Chip(
                                    label: Text(show.status),
                                    backgroundColor: _getStatusColor(show.status),
                                  ),
                                  ...show.genres.map((genre) => Chip(label: Text(genre))),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Show metadata
                              InfoRow(
                                icon: Icons.calendar_today,
                                label: 'Start Date',
                                value: show.startDate,
                              ),
                              if (show.endDate != null && show.endDate!.isNotEmpty)
                                InfoRow(
                                  icon: Icons.event_busy,
                                  label: 'End Date',
                                  value: show.endDate!,
                                ),
                              InfoRow(
                                icon: Icons.location_on,
                                label: 'Country',
                                value: show.country,
                              ),
                              InfoRow(
                                icon: Icons.business,
                                label: 'Network',
                                value: show.network,
                              ),
                              InfoRow(
                                icon: Icons.timer,
                                label: 'Runtime',
                                value: '${show.runtime} minutes',
                              ),

                              // Watched episodes stats
                              FutureBuilder<int>(
                                future: userDataProvider.getWatchedEpisodesCount(show.id),
                                builder: (context, snapshot) {
                                  final watchedCount = snapshot.data ?? 0;
                                  if (watchedCount > 0) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.visibility,
                                            color: Colors.green[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Vous avez regardé $watchedCount sur ${show.episodes.length} épisodes',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),

                              const SizedBox(height: 16),

                              // Description
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(show.description),

                              // User notes
                              FutureBuilder<ShowRating?>(
                                future: userDataProvider.getShowRating(show.id),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData && snapshot.data != null && snapshot.data!.notes != null && snapshot.data!.notes!.isNotEmpty) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Mes notes',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Card(
                                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                                          margin: EdgeInsets.zero,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(snapshot.data!.notes!),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: _SliverTabBarDelegate(
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'Episodes'),
                              Tab(text: 'Pictures'),
                              Tab(text: 'Stats'),
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEpisodesTab(show.id, show.name, show.episodes, userDataProvider),
                      _buildPicturesTab(show.pictures),
                      _buildWatchingStatsTab(context, show.id, userDataProvider),
                    ],
                  ),
                );

              } catch (e, stackTrace) {
                // Log l'erreur pour le débogage
                print('Erreur dans ShowDetailsView: $e');
                print('Stack trace: $stackTrace');

                // Afficher un message d'erreur
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text(
                        'Une erreur s\'est produite',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          e.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Retour'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  // Modification du widget _buildEpisodesTab dans show_details_view.dart

  Widget _buildEpisodesTab(
      int showId,
      String showName,
      List<TvShowEpisode> episodes,
      UserDataProvider userDataProvider,
      ) {
    // Vérification si la liste d'épisodes est vide
    if (episodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun épisode disponible',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Grouper les épisodes par saison
    final Map<int, List<TvShowEpisode>> episodesBySeason = {};

    try {
      for (var episode in episodes) {
        if (!episodesBySeason.containsKey(episode.season)) {
          episodesBySeason[episode.season] = [];
        }
        episodesBySeason[episode.season]!.add(episode);
      }

      final seasons = episodesBySeason.keys.toList()..sort();

      return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: seasons.length,
        itemBuilder: (context, index) {
          final season = seasons[index];
          final seasonEpisodes = episodesBySeason[season]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ExpansionTile(
              title: Text('Season $season'),
              subtitle: FutureBuilder<int>(
                future: _getWatchedEpisodesInSeason(userDataProvider, showId, season, seasonEpisodes),
                builder: (context, snapshot) {
                  final watchedCount = snapshot.data ?? 0;
                  return Text(
                    '$watchedCount/${seasonEpisodes.length} episodes watched',
                    style: TextStyle(
                      color: watchedCount == seasonEpisodes.length
                          ? Colors.green[700]
                          : watchedCount > 0
                          ? Colors.orange[700]
                          : Colors.grey[600],
                    ),
                  );
                },
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mark all episodes in this season as watched/unwatched
                  FutureBuilder<int>(
                    future: _getWatchedEpisodesInSeason(userDataProvider, showId, season, seasonEpisodes),
                    builder: (context, snapshot) {
                      final watchedCount = snapshot.data ?? 0;
                      final allWatched = watchedCount == seasonEpisodes.length;

                      return IconButton(
                        icon: Icon(
                          allWatched ? Icons.visibility_off : Icons.visibility,
                          color: allWatched ? Colors.red[400] : Colors.green[400],
                        ),
                        onPressed: () {
                          if (allWatched) {
                            userDataProvider.markSeasonAsUnwatched(showId, season);
                          } else {
                            userDataProvider.markSeasonAsWatched(showId, showName, season, seasonEpisodes);
                          }
                        },
                        tooltip: allWatched
                            ? 'Mark season as unwatched'
                            : 'Mark season as watched',
                      );
                    },
                  ),
                ],
              ),
              initiallyExpanded: index == 0, // Expand the first season by default
              children: seasonEpisodes.map((episode) {
                return FutureBuilder<bool>(
                  future: userDataProvider.isEpisodeWatched(showId, episode.season, episode.episode),
                  builder: (context, snapshot) {
                    final isWatched = snapshot.data ?? false;

                    return ListTile(
                      title: Text(
                        '${episode.episode}. ${episode.name}',
                        style: TextStyle(
                          decoration: isWatched ? TextDecoration.lineThrough : null,
                          color: isWatched ? Colors.grey[500] : null,
                        ),
                      ),
                      subtitle: Text('Air Date: ${_formatDate(episode.airDate)}'),
                      trailing: IconButton(
                        icon: Icon(
                          isWatched ? Icons.check_circle : Icons.check_circle_outline,
                          color: isWatched ? Colors.green[400] : Colors.grey[400],
                        ),
                        onPressed: () {
                          userDataProvider.toggleEpisodeWatched(showId, showName, episode);
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      );
    } catch (e) {
      print('Erreur dans _buildEpisodesTab: $e');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.orange[400]),
            const SizedBox(height: 16),
            const Text(
              'Erreur lors du chargement des épisodes',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              e.toString(),
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPicturesTab(List<String> pictures) {
    return pictures.isEmpty
        ? const Center(child: Text('No pictures available'))
        : LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid: more columns on larger screens
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: pictures.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                _showFullScreenImage(context, pictures[index]);
              },
              child: Hero(
                tag: 'picture_$index',
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: pictures[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.error)),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWatchingStatsTab(
      BuildContext context,
      int showId,
      UserDataProvider userDataProvider,
      ) {
    // This tab will show statistics about the user's watching habits for this show
    return FutureBuilder<int>(
      future: userDataProvider.getWatchedEpisodesCount(showId),
      builder: (context, snapshot) {
        final watchedCount = snapshot.data ?? 0;

        if (watchedCount == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Pas encore de statistiques',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Commencez à regarder des épisodes\npour suivre votre progression',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progression',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: watchedCount / snapshot.data!,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$watchedCount épisodes regardés',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Placeholder for future stats features
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activité de visionnage',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Cette section affichera bientôt des statistiques détaillées sur votre activité de visionnage pour cette série.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog(
      BuildContext context,
      TvShow show,
      UserDataProvider userDataProvider,
      ) async {
    // Prevent multiple dialog instances
    if (_isRatingDialogOpen) return;
    _isRatingDialogOpen = true;

    // Get current rating if exists
    final currentRating = await userDataProvider.getShowRating(show.id);
    if (currentRating != null) {
      _userRating = currentRating.rating;
      _notesController.text = currentRating.notes ?? '';
    } else {
      _userRating = 0;
      _notesController.clear();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Noter cette série'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Donnez votre avis sur cette série'),
                    const SizedBox(height: 16),
                    RatingBar.builder(
                      initialRating: _userRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _userRating = rating;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optionnel)',
                        border: OutlineInputBorder(),
                        hintText: 'Ajoutez vos commentaires sur cette série...',
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              actions: [
                if (currentRating != null)
                  TextButton(
                    onPressed: () {
                      userDataProvider.removeRating(show.id);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Supprimer'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: _userRating > 0
                      ? () {
                    userDataProvider.rateShow(
                      show,
                      _userRating,
                      notes: _notesController.text.isEmpty ? null : _notesController.text,
                    );
                    Navigator.of(context).pop();
                  }
                      : null,
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _isRatingDialogOpen = false;
    });
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return Colors.green[100]!;
      case 'ended':
        return Colors.red[100]!;
      case 'canceled/ended':
        return Colors.orange[100]!;
      case 'in development':
        return Colors.blue[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Future<int> _getWatchedEpisodesInSeason(
      UserDataProvider userDataProvider,
      int showId,
      int season,
      List<TvShowEpisode> episodes,
      ) async {
    int count = 0;
    for (var episode in episodes) {
      if (await userDataProvider.isEpisodeWatched(showId, season, episode.episode)) {
        count++;
      }
    }
    return count;
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}