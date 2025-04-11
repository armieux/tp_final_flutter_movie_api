import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../models/tv_show.dart';
import '../../services/tv_show_service.dart';
import '../../providers/user_data_provider.dart';
import 'show_details_view.dart';

class PopularShowsView extends StatefulWidget {
  const PopularShowsView({super.key});

  static const routeName = '/';

  @override
  State<PopularShowsView> createState() => _PopularShowsViewState();
}

class _PopularShowsViewState extends State<PopularShowsView> {
  final TvShowService _tvShowService = TvShowService();
  late Future<List<TvShow>> _popularShows;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  final List<TvShow> _shows = [];

  @override
  void initState() {
    super.initState();
    _loadPopularShows();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadMoreShows();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPopularShows() async {
    setState(() {
      _popularShows = _tvShowService.getPopularShows(_currentPage);
    });

    final shows = await _popularShows;
    setState(() {
      _shows.addAll(shows);
    });
  }

  Future<void> _loadMoreShows() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    final moreShows = await _tvShowService.getPopularShows(_currentPage);

    setState(() {
      _shows.addAll(moreShows);
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshShows() async {
    setState(() {
      _currentPage = 1;
      _shows.clear();
    });
    await _loadPopularShows();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Séries Populaires'),
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, child) {
          return RefreshIndicator(
            onRefresh: _refreshShows,
            child: _shows.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid with more columns on larger screens
                final crossAxisCount = constraints.maxWidth > 900
                    ? 4  // Extra large screens (tablets in landscape)
                    : constraints.maxWidth > 600
                    ? 3  // Large screens (tablets)
                    : 2;  // Default for phones

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _shows.length + (_isLoadingMore ? crossAxisCount : 0),
                  itemBuilder: (context, index) {
                    if (index >= _shows.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final show = _shows[index];
                    return _buildShowCard(context, show, userDataProvider);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildShowCard(BuildContext context, TvShow show, UserDataProvider userDataProvider) {
    return GestureDetector(
      onTap: () {
        if (show.permalink.isNotEmpty) {
          Navigator.pushNamed(
            context,
            ShowDetailsView.routeName,
            arguments: show.permalink,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'afficher les détails de cette série')),
          );
        }
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: [
            // Show image
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Hero(
                    tag: 'show_${show.id}',
                    child: show.thumbnailPath.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: show.thumbnailPath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error),
                      ),
                    )
                        : const Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        show.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${show.network} • ${show.status}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Watched episodes indicator
                          FutureBuilder<int>(
                            future: userDataProvider.getWatchedEpisodesCount(show.id),
                            builder: (context, snapshot) {
                              final watchedCount = snapshot.data ?? 0;
                              if (watchedCount > 0) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green[400],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$watchedCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Favorite icon in the top-right corner
            Positioned(
              top: 4,
              right: 4,
              child: FutureBuilder<bool>(
                future: userDataProvider.isFavorite(show.id),
                builder: (context, snapshot) {
                  final isFavorite = snapshot.data ?? false;
                  if (isFavorite) {
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}