import 'episode.dart';

class Season {
  String _id = '';
  int _episodesCount = 0;
  List<Episode> _episodes = [];

  Season();

  List<Episode> get episodes => _episodes;

  int get episodesCount => _episodesCount;

  void setCount(int count) {
    _episodesCount = count;
  }

  void addEpisode(Episode episode) {
    _episodes.add(episode);
    _episodesCount++;
  }

  String get id => _id;

  void setId(String id) {
    _id = id;
  }

  factory Season.fromJson(Map<String, dynamic> json) {
    var season = Season();

    season._id = json['id'] as String;
    season._episodesCount = json['episodesCount'] as int;
    season._episodes = (json['episodes'] as List<dynamic>)
        .map((dynamic e) => Episode.fromJson(e as Map<String, dynamic>))
        .toList();

    return season;
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : _id,
      'episodesCount' : _episodesCount,
      'episodes' : episodes.map((e) => e.toJson()).toList()
    };
  }
}
