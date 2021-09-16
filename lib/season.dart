import 'episode.dart';

class Season {
  String _id = '';
  int _episodesCount = 0;
  List<Episode> _episodes = [];

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
}
