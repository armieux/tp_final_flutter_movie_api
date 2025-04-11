import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../models/tv_show.dart';
import '../models/tv_show_episode.dart';
import '../services/user_data_service.dart';

class UserDataProvider with ChangeNotifier {
  final UserDataService _userDataService = UserDataService();

  List<FavoriteShow> _favorites = [];
  List<WatchedEpisode> _watchedEpisodes = [];
  List<ShowRating> _ratings = [];
  List<UserTheme> _themes = [];
  UserTheme? _activeTheme;
  Map<String, dynamic> _statistics = {};

  // Getters
  List<FavoriteShow> get favorites => _favorites;
  List<WatchedEpisode> get watchedEpisodes => _watchedEpisodes;
  List<ShowRating> get ratings => _ratings;
  List<UserTheme> get themes => _themes;
  UserTheme? get activeTheme => _activeTheme;
  Map<String, dynamic> get statistics => _statistics;

  // Initialisation
  Future<void> init() async {
    await _loadFavorites();
    await _loadWatchedEpisodes();
    await _loadRatings();
    await _loadThemes();
    await _loadActiveTheme();
    await _loadStatistics();
  }

  // ======== FAVORITES ========

  Future<void> _loadFavorites() async {
    _favorites = await _userDataService.getFavorites();
    notifyListeners();
  }

  Future<bool> isFavorite(int showId) async {
    return _favorites.any((show) => show.id == showId);
  }

  Future<void> toggleFavorite(TvShow show) async {
    final isFav = await isFavorite(show.id);

    if (isFav) {
      await _userDataService.removeFromFavorites(show.id);
    } else {
      await _userDataService.addToFavorites(show);
    }

    await _loadFavorites();
  }

  // ======== WATCHED EPISODES ========

  Future<void> _loadWatchedEpisodes() async {
    _watchedEpisodes = await _userDataService.getWatchedEpisodes();
    notifyListeners();
  }

  Future<bool> isEpisodeWatched(int showId, int season, int episode) async {
    return _watchedEpisodes.any(
            (ep) => ep.showId == showId && ep.season == season && ep.episode == episode
    );
  }

  Future<void> toggleEpisodeWatched(
      int showId,
      String showName,
      TvShowEpisode episode,
      ) async {
    final isWatched = await isEpisodeWatched(showId, episode.season, episode.episode);

    if (isWatched) {
      await _userDataService.markEpisodeAsUnwatched(showId, episode.season, episode.episode);
    } else {
      await _userDataService.markEpisodeAsWatched(showId, showName, episode);
    }

    await _loadWatchedEpisodes();
    await _loadStatistics();
  }

  Future<int> getWatchedEpisodesCount(int showId) async {
    return _watchedEpisodes.where((ep) => ep.showId == showId).length;
  }

  // ======== RATINGS ========

  Future<void> _loadRatings() async {
    _ratings = await _userDataService.getRatings();
    notifyListeners();
  }

  Future<ShowRating?> getShowRating(int showId) async {
    try {
      return _ratings.firstWhere((rating) => rating.showId == showId);
    } catch (e) {
      return null;
    }
  }

  Future<void> rateShow(
      TvShow show,
      double rating, {
        String? notes,
      }) async {
    await _userDataService.rateShow(show, rating, notes: notes);
    await _loadRatings();
    await _loadStatistics();
  }

  Future<void> removeRating(int showId) async {
    await _userDataService.removeRating(showId);
    await _loadRatings();
    await _loadStatistics();
  }

  // ======== THEMES ========

  Future<void> _loadThemes() async {
    _themes = await _userDataService.getThemes();
    notifyListeners();
  }

  Future<void> _loadActiveTheme() async {
    _activeTheme = await _userDataService.getActiveTheme();
    notifyListeners();
  }

  Future<void> addTheme(UserTheme theme) async {
    await _userDataService.addTheme(theme);
    await _loadThemes();
  }

  Future<void> setActiveTheme(UserTheme theme) async {
    await _userDataService.setActiveTheme(theme);
    await _loadActiveTheme();
  }

  // ======== STATISTICS ========

  Future<void> _loadStatistics() async {
    _statistics = await _userDataService.getViewingStatistics();
    notifyListeners();
  }

  // Marquer une saison entière comme vue
  Future<void> markSeasonAsWatched(
      int showId,
      String showName,
      int season,
      List<TvShowEpisode> episodes,
      ) async {
    for (var episode in episodes.where((e) => e.season == season)) {
      final isWatched = await isEpisodeWatched(showId, episode.season, episode.episode);
      if (!isWatched) {
        await _userDataService.markEpisodeAsWatched(showId, showName, episode);
      }
    }

    await _loadWatchedEpisodes();
    await _loadStatistics();
  }

  // Marquer une saison entière comme non vue
  Future<void> markSeasonAsUnwatched(
      int showId,
      int season,
      ) async {
    for (var episode in _watchedEpisodes.where((e) => e.showId == showId && e.season == season)) {
      await _userDataService.markEpisodeAsUnwatched(showId, episode.season, episode.episode);
    }

    await _loadWatchedEpisodes();
    await _loadStatistics();
  }
}