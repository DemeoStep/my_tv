import 'package:my_tv/season.dart';

class Translator {
  String _id = '';
  String _name = '';
  int _seasonsCount = 0;
  List<Season> _seasons = [];

  Translator();

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

  factory Translator.fromJson(Map<String, dynamic> json) {
    var translator = Translator();

    translator._id = json['id'] as String;
    translator._name = json['name'] as String;
    translator._seasonsCount = json['seasonsCount'] as int;
    translator._seasons = (json['seasons'] as List<dynamic>)
        .map((dynamic e) => Season.fromJson(e as Map<String, dynamic>))
        .toList();

    return translator;
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : _id,
      'name' : _name,
      'seasonsCount' : _seasonsCount,
      'seasons' : _seasons.map((e) => e.toJson()).toList()
    };
  }
}
