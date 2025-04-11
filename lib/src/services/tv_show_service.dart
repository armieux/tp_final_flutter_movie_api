import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tv_show.dart';
import '../models/tv_show_details.dart';

class TvShowService {
  static const String baseUrl = 'https://www.episodate.com/api';

  // Get popular TV shows with pagination
  Future<List<TvShow>> getPopularShows(int page) async {
    final response = await http.get(Uri.parse('$baseUrl/most-popular?page=$page'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['tv_shows'] as List)
          .map((show) => TvShow.fromJson(show))
          .toList();
    } else {
      throw Exception('Failed to load popular shows');
    }
  }

  // Search for TV shows with pagination
  Future<List<TvShow>> searchShows(String query, int page) async {
    final response = await http.get(Uri.parse('$baseUrl/search?q=$query&page=$page'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['tv_shows'] as List)
          .map((show) => TvShow.fromJson(show))
          .toList();
    } else {
      throw Exception('Failed to search shows');
    }
  }

  // Get detailed information about a specific TV show
  Future<TvShowDetails> getShowDetails(String showIdentifier) async {
    try {
      if (showIdentifier.isEmpty) {
        throw Exception('Identifiant de série invalide');
      }

      final response = await http.get(Uri.parse('$baseUrl/show-details?q=$showIdentifier'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Vérifier si la réponse contient les données de la série
        if (data['tvShow'] == null) {
          throw Exception('Série non trouvée');
        }

        return TvShowDetails.fromJson(data['tvShow']);
      } else if (response.statusCode == 404) {
        throw Exception('Série non trouvée');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      // Ajouter des logs pour le débogage
      print('Erreur dans getShowDetails: $e');

      if (e is FormatException) {
        throw Exception('Format de réponse invalide');
      } else if (e is http.ClientException) {
        throw Exception('Problème de connexion réseau');
      }

      // Relancer l'exception originale
      rethrow;
    }
  }
}