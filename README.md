# TV Shows Explorer - Documentation

## Table des matières

1. [Présentation](#présentation)
2. [Fonctionnalités principales](#fonctionnalités-principales)
3. [Technologies utilisées](#technologies-utilisées)
4. [Structure du projet](#structure-du-projet)
5. [Écrans de l'application](#écrans-de-lapplication)
6. [Modèles de données](#modèles-de-données)
7. [Services](#services)
8. [Providers](#providers)
9. [Configuration et installation](#configuration-et-installation)
10. [API Episodate](#api-episodate)
11. [Personnalisation](#personnalisation)

## Présentation

TV Shows Explorer est une application mobile développée avec Flutter qui permet aux utilisateurs de découvrir, rechercher et suivre leurs séries TV préférées. L'application utilise l'API Episodate pour récupérer des informations détaillées sur les séries TV.

L'application offre une interface utilisateur moderne et responsive qui s'adapte aux différentes tailles d'écran (téléphones et tablettes), avec prise en charge des thèmes clair et sombre ainsi que des thèmes personnalisés.

## Fonctionnalités principales

- **Découverte de séries** : Parcourir les séries populaires
- **Recherche** : Rechercher des séries par nom
- **Détails des séries** : Afficher des informations détaillées sur chaque série (synopsis, date de diffusion, épisodes, etc.)
- **Gestion des favoris** : Ajouter/retirer des séries aux favoris
- **Suivi des épisodes** : Marquer les épisodes comme vus/non vus
- **Notation** : Noter les séries et ajouter des commentaires personnels
- **Statistiques** : Visualiser des statistiques sur les habitudes de visionnage
- **Thèmes personnalisés** : Créer et appliquer des thèmes personnalisés
- **Support multilingue** : Prêt pour l'internationalisation

## Technologies utilisées

- **Flutter** : Framework UI cross-platform
- **Dart** : Langage de programmation
- **Provider** : Gestion d'état
- **Hive** : Base de données NoSQL locale
- **SharedPreferences** : Stockage des préférences utilisateur
- **HTTP** : Communication avec l'API
- **Cached Network Image** : Mise en cache des images
- **FL Chart** : Visualisation des données statistiques
- **Material Design** : Design system pour l'interface utilisateur

## Structure du projet

```
lib/
├── main.dart                     # Point d'entrée de l'application
├── src/
│   ├── app.dart                  # Configuration de l'application
│   ├── main_screen.dart          # Écran principal avec navigation
│   ├── features/                 # Fonctionnalités par module
│   │   ├── shows/                # Module séries TV
│   │   │   ├── popular_shows_view.dart
│   │   │   ├── search_shows_view.dart
│   │   │   └── show_details_view.dart
│   │   └── user/                 # Module utilisateur
│   │       ├── favorites_view.dart
│   │       ├── statistics_view.dart
│   │       ├── theme_settings_view.dart
│   │       └── user_profile_view.dart
│   ├── models/                   # Modèles de données
│   │   ├── tv_show.dart
│   │   ├── tv_show_details.dart
│   │   ├── tv_show_episode.dart
│   │   └── user_data.dart
│   ├── providers/                # Providers pour la gestion d'état
│   │   ├── theme_provider.dart
│   │   └── user_data_provider.dart
│   ├── services/                 # Services d'accès aux données
│   │   ├── tv_show_service.dart
│   │   └── user_data_service.dart
│   ├── settings/                 # Paramètres de l'application
│   │   ├── settings_controller.dart
│   │   ├── settings_service.dart
│   │   └── settings_view.dart
│   └── localization/             # Internationalisation
│       └── app_en.arb
```

## Écrans de l'application

### 1. Séries Populaires (PopularShowsView)

- Affiche une grille des séries TV populaires
- Pagination infinie (chargement à la demande)
- Pull-to-refresh pour rafraîchir la liste
- Responsive design (2, 3 ou 4 colonnes selon la taille d'écran)
- Indicateurs visuels pour les séries favorites ou avec des épisodes vus

### 2. Recherche (SearchShowsView)

- Recherche de séries par nom
- Affichage des résultats en grille ou liste selon la taille d'écran
- Pagination des résultats de recherche
- Indicateurs pour les séries favorites et les épisodes vus

### 3. Détails de la série (ShowDetailsView)

- Affichage des informations détaillées de la série
- Interface organisée avec TabBar (Episodes, Photos, Statistiques)
- Fonctionnalités :
  - Ajouter/retirer des favoris
  - Noter la série (1-5 étoiles) avec commentaires personnels
  - Marquer des épisodes ou des saisons entières comme vus/non vus
  - Visualisation des photos de la série
  - Statistiques de visionnage personnelles

### 4. Favoris (FavoritesView)

- Liste des séries favorites de l'utilisateur
- Affichage en grille ou liste selon la taille d'écran
- Suppression par swipe sur mobile
- Accès rapide aux détails de la série

### 5. Profil Utilisateur (UserProfileView)

- Vue d'ensemble des statistiques utilisateur
- Accès rapide aux fonctionnalités (favoris, statistiques, thèmes)
- Synthèse des données de visionnage

### 6. Statistiques (StatisticsView)

- Visualisation des habitudes de visionnage
- Graphiques (distribution des notes, activité par jour de la semaine)
- Top des séries les plus regardées
- Compteurs (épisodes vus, séries suivies, etc.)

### 7. Paramètres de thème (ThemeSettingsView)

- Sélection du mode thème (clair/sombre/système)
- Création de thèmes personnalisés
- Sélecteur de couleurs pour la personnalisation
- Aperçu en temps réel des changements de thème

### 8. Paramètres (SettingsView)

- Configuration générale de l'application
- Accès aux informations légales
- Gestion des données utilisateur

## Modèles de données

### TvShow

Représente les informations de base d'une série TV :

```dart
class TvShow {
  final int id;
  final String name;
  final String permalink;
  final String startDate;
  final String? endDate;
  final String country;
  final String network;
  final String status;
  final String thumbnailPath;
}
```

### TvShowDetails

Extension de TvShow avec des informations détaillées :

```dart
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
}
```

### TvShowEpisode

Représente un épisode d'une série :

```dart
class TvShowEpisode {
  final int season;
  final int episode;
  final String name;
  final String airDate;
}
```

### UserData

Ensemble de classes pour les données utilisateur :

```dart
// Modèle pour les favoris
class FavoriteShow {
  final int id;
  final String name;
  final String thumbnailPath;
  final String permalink;
  final DateTime dateAdded;
}

// Modèle pour le suivi des épisodes
class WatchedEpisode {
  final int showId;
  final String showName;
  final int season;
  final int episode;
  final String episodeName;
  final DateTime watchedDate;
}

// Modèle pour les notes personnelles
class ShowRating {
  final int showId;
  final String showName;
  final String thumbnailPath;
  final double rating;
  final String? notes;
  final DateTime ratedDate;
}

// Modèle pour les thèmes personnalisés
class UserTheme {
  final String name;
  final int primaryColorValue;
  final int secondaryColorValue;
  final bool isDark;
}
```

## Services

### TvShowService

Service pour interagir avec l'API Episodate :

```dart
class TvShowService {
  static const String baseUrl = 'https://www.episodate.com/api';

  // Obtenir les séries populaires avec pagination
  Future<List<TvShow>> getPopularShows(int page)

  // Rechercher des séries avec pagination
  Future<List<TvShow>> searchShows(String query, int page)

  // Obtenir les détails d'une série spécifique
  Future<TvShowDetails> getShowDetails(String showIdentifier)
}
```

### UserDataService

Service pour gérer les données utilisateur locales :

```dart
class UserDataService {
  // Initialisation de Hive
  static Future<void> init()
  
  // Gestion des favoris
  Future<List<FavoriteShow>> getFavorites()
  Future<bool> isFavorite(int showId)
  Future<void> addToFavorites(TvShow show)
  Future<void> removeFromFavorites(int showId)
  
  // Gestion des épisodes vus
  Future<List<WatchedEpisode>> getWatchedEpisodes()
  Future<bool> isEpisodeWatched(int showId, int season, int episode)
  Future<void> markEpisodeAsWatched(int showId, String showName, TvShowEpisode episode)
  Future<void> markEpisodeAsUnwatched(int showId, int season, int episode)
  
  // Gestion des notes
  Future<List<ShowRating>> getRatings()
  Future<ShowRating?> getShowRating(int showId)
  Future<void> rateShow(TvShow show, double rating, {String? notes})
  Future<void> removeRating(int showId)
  
  // Gestion des thèmes
  Future<List<UserTheme>> getThemes()
  Future<void> saveThemes(List<UserTheme> themes)
  Future<void> addTheme(UserTheme theme)
  Future<UserTheme?> getActiveTheme()
  Future<void> setActiveTheme(UserTheme theme)
  
  // Statistiques
  Future<Map<String, dynamic>> getViewingStatistics()
}
```

## Providers

### UserDataProvider

Provider pour accéder aux données utilisateur dans l'application :

```dart
class UserDataProvider with ChangeNotifier {
  // Initialisation
  Future<void> init()
  
  // Gestion des favoris
  Future<bool> isFavorite(int showId)
  Future<void> toggleFavorite(TvShow show)
  
  // Gestion des épisodes vus
  Future<bool> isEpisodeWatched(int showId, int season, int episode)
  Future<void> toggleEpisodeWatched(int showId, String showName, TvShowEpisode episode)
  Future<int> getWatchedEpisodesCount(int showId)
  Future<void> markSeasonAsWatched(int showId, String showName, int season, List<TvShowEpisode> episodes)
  Future<void> markSeasonAsUnwatched(int showId, int season)
  
  // Gestion des notes
  Future<ShowRating?> getShowRating(int showId)
  Future<void> rateShow(TvShow show, double rating, {String? notes})
  Future<void> removeRating(int showId)
  
  // Gestion des thèmes
  Future<void> addTheme(UserTheme theme)
  Future<void> setActiveTheme(UserTheme theme)
}
```

### ThemeProvider

Provider pour gérer le thème de l'application :

```dart
class ThemeProvider with ChangeNotifier {
  // Propriétés
  ThemeMode get themeMode
  UserTheme? get customTheme
  bool get isDarkMode
  
  // Méthodes
  void setThemeMode(ThemeMode mode)
  void setCustomTheme(UserTheme? theme)
  ThemeData getTheme(bool isDark)
}
```

## Configuration et installation

### Prérequis

- Flutter SDK (version récente)
- Dart SDK (version récente)
- Un éditeur comme VS Code ou Android Studio

### Installation

1. Cloner le dépôt :
   ```bash
   git clone [URL_DU_REPO]
   cd tp_final_flutter_movie_api
   ```

2. Installer les dépendances :
   ```bash
   flutter pub get
   ```

3. Lancer l'application :
   ```bash
   flutter run
   ```

### Configuration

Les principales dépendances sont définies dans le fichier `pubspec.yaml` :

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  http: ^1.2.0
  cached_network_image: ^3.3.1
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  provider: ^6.1.1
  fl_chart: ^0.66.0
  path_provider: ^2.1.2
  flutter_rating_bar: ^4.0.1
  animations: ^2.0.8
```

## API Episodate

L'application utilise l'API Episodate pour récupérer les informations sur les séries TV.

### Endpoints principaux

1. **Séries populaires** :
   - URL: `/api/most-popular?page=:page`
   - Exemple: `https://www.episodate.com/api/most-popular?page=1`

2. **Recherche** :
   - URL: `/api/search?q=:search&page=:page`
   - Exemple: `https://www.episodate.com/api/search?q=arrow&page=1`

3. **Détails d'une série** :
   - URL: `/api/show-details?q=:show`
   - Exemple: `https://www.episodate.com/api/show-details?q=arrow`

### Restrictions

- Utiliser uniquement les appels API nécessaires
- L'API met en cache les résultats pendant 60 minutes
- Éviter les appels inutiles en stockant les données localement

## Personnalisation

### Thèmes

L'application permet une personnalisation complète de l'apparence :

1. **Modes de thème** :
   - Clair
   - Sombre
   - Système (suit les préférences de l'appareil)

2. **Thèmes personnalisés** :
   - Création de thèmes avec nom personnalisé
   - Sélection des couleurs primaire et secondaire
   - Option mode sombre/clair pour chaque thème

3. **Application des thèmes** :
   - Les thèmes sont appliqués immédiatement
   - Persistance des préférences entre les sessions

### Localisation

L'application est prête pour l'internationalisation :

- Les fichiers de traduction sont stockés dans `lib/src/localization/`
- Configuration dans `l10n.yaml`
- Actuellement disponible en anglais
- Structure en place pour ajouter d'autres langues
