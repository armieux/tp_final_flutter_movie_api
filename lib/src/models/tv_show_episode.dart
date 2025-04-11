class TvShowEpisode {
  final int season;
  final int episode;
  final String name;
  final String airDate;

  TvShowEpisode({
    required this.season,
    required this.episode,
    required this.name,
    required this.airDate,
  });

  factory TvShowEpisode.fromJson(Map<String, dynamic> json) {
    return TvShowEpisode(
      season: json['season'] ?? 0,
      episode: json['episode'] ?? 0,
      name: json['name'] ?? 'Épisode sans nom',
      airDate: json['air_date'] ?? '',
    );
  }
}