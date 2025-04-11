import 'package:hive/hive.dart';

// Modèle pour les favoris
class FavoriteShow {
  final int id;
  final String name;
  final String thumbnailPath;
  final String permalink;
  final DateTime dateAdded;

  FavoriteShow({
    required this.id,
    required this.name,
    required this.thumbnailPath,
    required this.permalink,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnailPath': thumbnailPath,
      'permalink': permalink,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory FavoriteShow.fromJson(Map<String, dynamic> json) {
    return FavoriteShow(
      id: json['id'],
      name: json['name'],
      thumbnailPath: json['thumbnailPath'],
      permalink: json['permalink'],
      dateAdded: DateTime.parse(json['dateAdded']),
    );
  }
}

// Modèle pour le suivi des épisodes
class WatchedEpisode {
  final int showId;
  final String showName;
  final int season;
  final int episode;
  final String episodeName;
  final DateTime watchedDate;

  WatchedEpisode({
    required this.showId,
    required this.showName,
    required this.season,
    required this.episode,
    required this.episodeName,
    required this.watchedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'showId': showId,
      'showName': showName,
      'season': season,
      'episode': episode,
      'episodeName': episodeName,
      'watchedDate': watchedDate.toIso8601String(),
    };
  }

  factory WatchedEpisode.fromJson(Map<String, dynamic> json) {
    return WatchedEpisode(
      showId: json['showId'],
      showName: json['showName'],
      season: json['season'],
      episode: json['episode'],
      episodeName: json['episodeName'],
      watchedDate: DateTime.parse(json['watchedDate']),
    );
  }

  // Identifiant unique pour cet épisode
  String get uniqueId => '$showId-$season-$episode';
}

// Modèle pour les notes personnelles
class ShowRating {
  final int showId;
  final String showName;
  final String thumbnailPath;
  final double rating;
  final String? notes;
  final DateTime ratedDate;

  ShowRating({
    required this.showId,
    required this.showName,
    required this.thumbnailPath,
    required this.rating,
    this.notes,
    required this.ratedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'showId': showId,
      'showName': showName,
      'thumbnailPath': thumbnailPath,
      'rating': rating,
      'notes': notes,
      'ratedDate': ratedDate.toIso8601String(),
    };
  }

  factory ShowRating.fromJson(Map<String, dynamic> json) {
    return ShowRating(
      showId: json['showId'],
      showName: json['showName'],
      thumbnailPath: json['thumbnailPath'],
      rating: json['rating'].toDouble(),
      notes: json['notes'],
      ratedDate: DateTime.parse(json['ratedDate']),
    );
  }
}

// Modèle pour les thèmes personnalisés
class UserTheme {
  final String name;
  final int primaryColorValue;
  final int secondaryColorValue;
  final bool isDark;

  UserTheme({
    required this.name,
    required this.primaryColorValue,
    required this.secondaryColorValue,
    required this.isDark,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'primaryColorValue': primaryColorValue,
      'secondaryColorValue': secondaryColorValue,
      'isDark': isDark,
    };
  }

  factory UserTheme.fromJson(Map<String, dynamic> json) {
    return UserTheme(
      name: json['name'],
      primaryColorValue: json['primaryColorValue'],
      secondaryColorValue: json['secondaryColorValue'],
      isDark: json['isDark'],
    );
  }
}