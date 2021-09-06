import 'package:my_tv/season.dart';

class Translator {
  String _id = '';
  String _name = '';
  int _seasonsCount = 0;
  List<Season> _seasons = [];

  List<Season> get seasonsList => _seasons;

  String get id => _id;

  String get name => _name;

  int get seasonsCount => _seasonsCount;

  void setCount(int count) {
    _seasonsCount = count;
  }

  void addSeason(Season season) {
    _seasons.add(season);
    _seasonsCount++;
  }

  void setName(String name) {
    _name = name;
  }

  void setId(String id) {
    _id = id;
  }
}
