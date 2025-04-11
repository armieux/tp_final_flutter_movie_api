import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_data.dart';
import '../models/tv_show.dart';
import '../models/tv_show_details.dart';
import '../models/tv_show_episode.dart';

class UserDataService {
  static const String _favoritesKey = 'favorites';
  static const String _watchedEpisodesKey = 'watched_episodes';
  static const String _ratingsKey = 'show_ratings';
  static const String _themesKey = 'user_themes';
  static const String _activeThemeKey = 'active_theme';

  // Initialisation de Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    // Ouvrir les boîtes Hive nécessaires
    await Hive.openBox('user_data');
  }

  // ======== FAVORITES ========

  // Récupérer tous les favoris
  Future<List<FavoriteShow>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    return favoritesJson
        .map((json) => FavoriteShow.fromJson(jsonDecode(json)))
        .toList();
  }

  // Vérifier si une série est dans les favoris
  Future<bool> isFavorite(int showId) async {
    final favorites = await getFavorites();
    return favorites.any((show) => show.id == showId);
  }

  // Ajouter une série aux favoris
  Future<void> addToFavorites(TvShow show) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    // Vérifier si la série est déjà dans les favoris
    if (favorites.any((fav) => fav.id == show.id)) {
      return;
    }

    final newFavorite = FavoriteShow(
      id: show.id,
      name: show.name,
      thumbnailPath: show.thumbnailPath,
      permalink: show.permalink,
      dateAdded: DateTime.now(),
    );

    favorites.add(newFavorite);

    final favoritesJson = favorites
        .map((fav) => jsonEncode(fav.toJson()))
        .toList();

    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  // Supprimer une série des favoris
  Future<void> removeFromFavorites(int showId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    favorites.removeWhere((show) => show.id == showId);

    final favoritesJson = favorites
        .map((fav) => jsonEncode(fav.toJson()))
        .toList();

    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  // ======== WATCHED EPISODES ========

  // Récupérer tous les épisodes vus
  Future<List<WatchedEpisode>> getWatchedEpisodes() async {
    final box = Hive.box('user_data');
    final watchedJson = box.get(_watchedEpisodesKey, defaultValue: <String>[]) as List;

    return watchedJson
        .map((json) => WatchedEpisode.fromJson(jsonDecode(json.toString())))
        .toList();
  }

  // Vérifier si un épisode a été vu
  Future<bool> isEpisodeWatched(int showId, int season, int episode) async {
    final watchedEpisodes = await getWatchedEpisodes();
    return watchedEpisodes.any(
            (ep) => ep.showId == showId && ep.season == season && ep.episode == episode
    );
  }

  // Marquer un épisode comme vu
  Future<void> markEpisodeAsWatched(
      int showId,
      String showName,
      TvShowEpisode episode,
      ) async {
    final box = Hive.box('user_data');
    final watchedEpisodes = await getWatchedEpisodes();

    // Vérifier si l'épisode est déjà marqué comme vu
    if (watchedEpisodes.any(
            (ep) => ep.showId == showId && ep.season == episode.season && ep.episode == episode.episode
    )) {
      return;
    }

    final newWatchedEpisode = WatchedEpisode(
      showId: showId,
      showName: showName,
      season: episode.season,
      episode: episode.episode,
      episodeName: episode.name,
      watchedDate: DateTime.now(),
    );

    watchedEpisodes.add(newWatchedEpisode);

    final watchedJson = watchedEpisodes
        .map((ep) => jsonEncode(ep.toJson()))
        .toList();

    await box.put(_watchedEpisodesKey, watchedJson);
  }

  // Marquer un épisode comme non vu
  Future<void> markEpisodeAsUnwatched(int showId, int season, int episode) async {
    final box = Hive.box('user_data');
    final watchedEpisodes = await getWatchedEpisodes();

    watchedEpisodes.removeWhere(
            (ep) => ep.showId == showId && ep.season == season && ep.episode == episode
    );

    final watchedJson = watchedEpisodes
        .map((ep) => jsonEncode(ep.toJson()))
        .toList();

    await box.put(_watchedEpisodesKey, watchedJson);
  }

  // Obtenir le nombre d'épisodes vus pour une série
  Future<int> getWatchedEpisodesCount(int showId) async {
    final watchedEpisodes = await getWatchedEpisodes();
    return watchedEpisodes.where((ep) => ep.showId == showId).length;
  }

  // ======== RATINGS ========

  // Récupérer toutes les notes
  Future<List<ShowRating>> getRatings() async {
    final box = Hive.box('user_data');
    final ratingsJson = box.get(_ratingsKey, defaultValue: <String>[]) as List;

    return ratingsJson
        .map((json) => ShowRating.fromJson(jsonDecode(json.toString())))
        .toList();
  }

  // Obtenir la note d'une série
  Future<ShowRating?> getShowRating(int showId) async {
    final ratings = await getRatings();
    try {
      return ratings.firstWhere((rating) => rating.showId == showId);
    } catch (e) {
      return null;
    }
  }

  // Noter une série
  Future<void> rateShow(
      TvShow show,
      double rating, {
        String? notes,
      }) async {
    final box = Hive.box('user_data');
    final ratings = await getRatings();

    // Supprimer la note existante si elle existe
    ratings.removeWhere((r) => r.showId == show.id);

    final newRating = ShowRating(
      showId: show.id,
      showName: show.name,
      thumbnailPath: show.thumbnailPath,
      rating: rating,
      notes: notes,
      ratedDate: DateTime.now(),
    );

    ratings.add(newRating);

    final ratingsJson = ratings
        .map((r) => jsonEncode(r.toJson()))
        .toList();

    await box.put(_ratingsKey, ratingsJson);
  }

  // Supprimer la note d'une série
  Future<void> removeRating(int showId) async {
    final box = Hive.box('user_data');
    final ratings = await getRatings();

    ratings.removeWhere((rating) => rating.showId == showId);

    final ratingsJson = ratings
        .map((r) => jsonEncode(r.toJson()))
        .toList();

    await box.put(_ratingsKey, ratingsJson);
  }

  // ======== THEMES ========

  // Récupérer tous les thèmes
  Future<List<UserTheme>> getThemes() async {
    final prefs = await SharedPreferences.getInstance();
    final themesJson = prefs.getStringList(_themesKey) ?? [];

    if (themesJson.isEmpty) {
      // Ajouter quelques thèmes par défaut
      final defaultThemes = [
        UserTheme(
          name: 'Deep Purple',
          primaryColorValue: 0xFF673AB7,
          secondaryColorValue: 0xFF03DAC6,
          isDark: false,
        ),
        UserTheme(
          name: 'Dark Purple',
          primaryColorValue: 0xFF673AB7,
          secondaryColorValue: 0xFF03DAC6,
          isDark: true,
        ),
        UserTheme(
          name: 'Ocean',
          primaryColorValue: 0xFF006064,
          secondaryColorValue: 0xFF64FFDA,
          isDark: false,
        ),
        UserTheme(
          name: 'Midnight',
          primaryColorValue: 0xFF1A237E,
          secondaryColorValue: 0xFFFF8A80,
          isDark: true,
        ),
      ];

      await saveThemes(defaultThemes);
      return defaultThemes;
    }

    return themesJson
        .map((json) => UserTheme.fromJson(jsonDecode(json)))
        .toList();
  }

  // Enregistrer les thèmes
  Future<void> saveThemes(List<UserTheme> themes) async {
    final prefs = await SharedPreferences.getInstance();
    final themesJson = themes
        .map((theme) => jsonEncode(theme.toJson()))
        .toList();

    await prefs.setStringList(_themesKey, themesJson);
  }

  // Ajouter un thème
  Future<void> addTheme(UserTheme theme) async {
    final themes = await getThemes();
    themes.add(theme);
    await saveThemes(themes);
  }

  // Obtenir le thème actif
  Future<UserTheme?> getActiveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final activeThemeJson = prefs.getString(_activeThemeKey);

    if (activeThemeJson == null) return null;

    return UserTheme.fromJson(jsonDecode(activeThemeJson));
  }

  // Définir le thème actif
  Future<void> setActiveTheme(UserTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeThemeKey, jsonEncode(theme.toJson()));
  }

  // ======== STATISTICS ========

  // Obtenir des statistiques de visionnage
  Future<Map<String, dynamic>> getViewingStatistics() async {
    final watchedEpisodes = await getWatchedEpisodes();
    final favorites = await getFavorites();
    final ratings = await getRatings();

    // Nombre total d'épisodes regardés
    final totalEpisodesWatched = watchedEpisodes.length;

    // Nombre de séries différentes regardées
    final uniqueShowsWatched = watchedEpisodes.map((e) => e.showId).toSet().length;

    // Séries les plus regardées (top 5)
    final showsEpisodeCount = <int, int>{};
    for (var episode in watchedEpisodes) {
      showsEpisodeCount[episode.showId] = (showsEpisodeCount[episode.showId] ?? 0) + 1;
    }

    final topShows = showsEpisodeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topShowsData = <Map<String, dynamic>>[];
    for (var i = 0; i < topShows.length && i < 5; i++) {
      final showId = topShows[i].key;
      final episodeCount = topShows[i].value;
      final showName = watchedEpisodes.firstWhere((e) => e.showId == showId).showName;

      topShowsData.add({
        'id': showId,
        'name': showName,
        'episodesWatched': episodeCount,
      });
    }

    // Moyenne des notes
    double averageRating = 0;
    if (ratings.isNotEmpty) {
      averageRating = ratings.map((r) => r.rating).reduce((a, b) => a + b) / ratings.length;
    }

    // Distribution des notes (pour graphique)
    final ratingDistribution = <int, int>{};
    for (var rating in ratings) {
      final roundedRating = rating.rating.round();
      ratingDistribution[roundedRating] = (ratingDistribution[roundedRating] ?? 0) + 1;
    }

    final ratingDistributionData = <Map<String, dynamic>>[];
    for (var i = 1; i <= 5; i++) {
      ratingDistributionData.add({
        'rating': i,
        'count': ratingDistribution[i] ?? 0,
      });
    }

    // Répartition par jour de la semaine (pour voir les habitudes de visionnage)
    final weekdayDistribution = <int, int>{};
    for (var episode in watchedEpisodes) {
      final weekday = episode.watchedDate.weekday;
      weekdayDistribution[weekday] = (weekdayDistribution[weekday] ?? 0) + 1;
    }

    final weekdayDistributionData = <Map<String, dynamic>>[];
    for (var i = 1; i <= 7; i++) {
      weekdayDistributionData.add({
        'weekday': i,
        'count': weekdayDistribution[i] ?? 0,
      });
    }

    return {
      'totalEpisodesWatched': totalEpisodesWatched,
      'uniqueShowsWatched': uniqueShowsWatched,
      'favoritesCount': favorites.length,
      'ratingsCount': ratings.length,
      'averageRating': averageRating,
      'topShows': topShowsData,
      'ratingDistribution': ratingDistributionData,
      'weekdayDistribution': weekdayDistributionData,
    };
  }
}