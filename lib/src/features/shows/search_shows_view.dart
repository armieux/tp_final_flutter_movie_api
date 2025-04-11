import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../models/tv_show.dart';
import '../../services/tv_show_service.dart';
import '../../providers/user_data_provider.dart';
import 'show_details_view.dart';

class SearchShowsView extends StatefulWidget {
  const SearchShowsView({super.key});

  static const routeName = '/search';

  @override
  State<SearchShowsView> createState() => _SearchShowsViewState();
}

class _SearchShowsViewState extends State<SearchShowsView> {
  final TvShowService _tvShowService = TvShowService();
  final TextEditingController _searchController = TextEditingController();
  List<TvShow> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMoreResults = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreResults && _searchResults.isNotEmpty) {
        _loadMoreResults();
      }
    }
  }

  Future<void> _searchShows() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _currentPage = 1;
      _searchResults = [];
    });

    try {
      final results = await _tvShowService.searchShows(query, _currentPage);
      setState(() {
        _searchResults = results;
        _hasMoreResults = results.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to search shows: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _currentPage++;
      final moreResults = await _tvShowService.searchShows(_searchController.text.trim(), _currentPage);
      setState(() {
        _searchResults.addAll(moreResults);
        _hasMoreResults = moreResults.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load more results: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher une série'),
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher par titre...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onSubmitted: (_) => _searchShows(),
                ),
              ),
              Expanded(
                child: _buildSearchResults(userDataProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(UserDataProvider userDataProvider) {
    if (_isLoading && _searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)));
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(
        child: Text('Aucun résultat trouvé. Essayez un autre terme de recherche.'),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('Entrez un terme de recherche pour trouver des séries'),
      );
    }

    // Detect if we're on a tablet
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (isTablet) {
      // Grid view for tablets
      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _searchResults.length + (_isLoading && _hasMoreResults ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _searchResults.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final show = _searchResults[index];

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                ShowDetailsView.routeName,
                arguments: show.permalink,
              );
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Stack(
                children: [
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
                            Text(
                              '${show.network} • ${show.status}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Favorite badge in top-right corner
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
        },
      );
    } else {
      // List view for phones
      return ListView.builder(
        controller: _scrollController,
        itemCount: _searchResults.length + (_isLoading && _hasMoreResults ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _searchResults.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final show = _searchResults[index];

          // Watched episodes count
          Widget watchedBadge = const SizedBox.shrink();
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
                    '$watchedCount vus',
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
          );

          return ListTile(
            leading: Hero(
              tag: 'show_${show.id}',
              child: CircleAvatar(
                backgroundImage: show.thumbnailPath.isNotEmpty
                    ? CachedNetworkImageProvider(show.thumbnailPath)
                    : null,
                child: show.thumbnailPath.isEmpty
                    ? const Icon(Icons.tv)
                    : null,
              ),
            ),
            title: Text(show.name),
            subtitle: Row(
              children: [
                Flexible(
                  child: Text('${show.network} • ${show.status}'),
                ),
                const SizedBox(width: 8),
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
                          '$watchedCount vus',
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<bool>(
                  future: userDataProvider.isFavorite(show.id),
                  builder: (context, snapshot) {
                    final isFavorite = snapshot.data ?? false;
                    if (isFavorite) {
                      return const Icon(Icons.favorite, color: Colors.red, size: 16);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                ShowDetailsView.routeName,
                arguments: show.permalink,
              );
            },
          );
        },
      );
    }
  }
}