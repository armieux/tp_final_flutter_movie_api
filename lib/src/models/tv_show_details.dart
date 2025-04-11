import 'tv_show_episode.dart';

class TvShowDetails {
  final int id;
  final String name;
  final String permalink;
  final String url;
  final String description;
  final String descriptionSource;
  final String startDate;
  final String? endDate;
  final String country;
  final String status;
  final int runtime;
  final String network;
  final String? youtubeLink;
  final String imagePath;
  final String thumbnailPath;
  final String rating;
  final int ratingCount;
  final List<String> genres;
  final List<String> pictures;
  final List<TvShowEpisode> episodes;

  TvShowDetails({
    required this.id,
    required this.name,
    required this.permalink,
    required this.url,
    required this.description,
    required this.descriptionSource,
    required this.startDate,
    this.endDate,
    required this.country,
    required this.status,
    required this.runtime,
    required this.network,
    this.youtubeLink,
    required this.imagePath,
    required this.thumbnailPath,
    required this.rating,
    required this.ratingCount,
    required this.genres,
    required this.pictures,
    required this.episodes,
  });

  factory TvShowDetails.fromJson(Map<String, dynamic> json) {
    // Récupérer les épisodes avec gestion de null
    List<TvShowEpisode> episodes = [];
    if (json['episodes'] != null) {
      episodes = (json['episodes'] as List)
          .map((episode) => TvShowEpisode.fromJson(episode))
          .toList();
    }

    // Récupérer les genres avec gestion de null
    List<String> genres = [];
    if (json['genres'] != null) {
      genres = List<String>.from(json['genres']);
    }

    // Récupérer les images avec gestion de null
    List<String> pictures = [];
    if (json['pictures'] != null) {
      pictures = List<String>.from(json['pictures']);
    }

    return TvShowDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sans nom',
      permalink: json['permalink'] ?? '',
      url: json['url'] ?? '',
      description: json['description'] ?? '',
      descriptionSource: json['description_source'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      country: json['country'] ?? '',
      status: json['status'] ?? '',
      runtime: json['runtime'] ?? 0,
      network: json['network'] ?? '',
      youtubeLink: json['youtube_link'],
      imagePath: json['image_path'] ?? '',
      thumbnailPath: json['image_thumbnail_path'] ?? '',
      rating: json['rating']?.toString() ?? '0',
      ratingCount: int.tryParse(json['rating_count']?.toString() ?? '0') ?? 0,
      genres: genres,
      pictures: pictures,
      episodes: episodes,
    );
  }
}