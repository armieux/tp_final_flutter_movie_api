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

  TvShow({
    required this.id,
    required this.name,
    required this.permalink,
    required this.startDate,
    this.endDate,
    required this.country,
    required this.network,
    required this.status,
    required this.thumbnailPath,
  });

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Série inconnue',
      permalink: json['permalink'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      country: json['country'] ?? '',
      network: json['network'] ?? '',
      status: json['status'] ?? '',
      thumbnailPath: json['image_thumbnail_path'] ?? '',
    );
  }
}