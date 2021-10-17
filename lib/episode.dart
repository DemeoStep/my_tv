class Episode {
  String _episode = '';

  Episode({required String episode}) {
    this._episode = episode;
  }

  String get episode => _episode;

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episode: json['episode'] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'episode' : _episode
    };
  }
}
