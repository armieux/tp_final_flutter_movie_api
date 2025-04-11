import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tp_final_flutter_movie_api/src/models/tv_show.dart';

import '../../providers/user_data_provider.dart';
import '../../models/user_data.dart';
import '../shows/show_details_view.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  static const routeName = '/favorites';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Séries Favorites'),
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, child) {
          final favorites = userDataProvider.favorites;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vous n\'avez pas encore de série favorite',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('Découvrir des séries'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout
              if (constraints.maxWidth > 600) {
                // Tablet layout: grid view
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    return _buildFavoriteCard(context, favorites[index]);
                  },
                );
              } else {
                // Phone layout: list view
                return ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    return _buildFavoriteListItem(
                      context,
                      favorites[index],
                      userDataProvider,
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, FavoriteShow show) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'show_${show.id}',
                child: CachedNetworkImage(
                  imageUrl: show.thumbnailPath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
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
                    'Ajouté le ${_formatDate(show.dateAdded)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteListItem(
      BuildContext context,
      FavoriteShow show,
      UserDataProvider userDataProvider,
      ) {
    return Dismissible(
      key: Key('favorite_${show.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        userDataProvider.toggleFavorite(
          // We need to convert to TvShow format
          // This is a bit of a hack since we don't have the full TvShow object
          TvShowAdapter(
            id: show.id,
            name: show.name,
            thumbnailPath: show.thumbnailPath,
            permalink: show.permalink,
          ) as TvShow,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${show.name} retiré des favoris'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Annuler',
              onPressed: () {
                userDataProvider.toggleFavorite(
                  TvShowAdapter(
                    id: show.id,
                    name: show.name,
                    thumbnailPath: show.thumbnailPath,
                    permalink: show.permalink,
                  ) as TvShow,
                );
              },
            ),
          ),
        );
      },
      child: ListTile(
        leading: Hero(
          tag: 'show_${show.id}',
          child: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(show.thumbnailPath),
          ),
        ),
        title: Text(show.name),
        subtitle: Text('Ajouté le ${_formatDate(show.dateAdded)}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pushNamed(
            context,
            ShowDetailsView.routeName,
            arguments: show.permalink,
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// Adapter class to convert FavoriteShow to TvShow format
class TvShowAdapter {
  final int id;
  final String name;
  final String thumbnailPath;
  final String permalink;
  final String startDate;
  final String? endDate;
  final String country;
  final String network;
  final String status;

  TvShowAdapter({
    required this.id,
    required this.name,
    required this.thumbnailPath,
    required this.permalink,
    this.startDate = '',
    this.endDate,
    this.country = 'Unknown',
    this.network = 'Unknown',
    this.status = 'Unknown',
  });
}