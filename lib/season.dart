import 'package:rxdart/rxdart.dart';

import 'episode.dart';

class Season{
  int _episodesCount = 0;
  List<Episode> _episodes = [];

  List<Episode> get episodes => _episodes;
  int get episodesCount => _episodesCount;

  void setCount(int count) {
    _episodesCount = count;
  }

  void addEpisode(Episode episode) {
    _episodes.add(episode);
  }

}