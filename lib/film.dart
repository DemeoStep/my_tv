import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'translator.dart';

class Film {
  String _name;
  String _id;
  int _year;
  String _country;
  List<String> _genres;
  String _url;
  String _poster;
  String _type;
  String _description;
  String _rate;
  bool _loaded = false;
  String _hls;
  String _mp4;
  List<Map<String, String>> _translators = [];
  List<Translator> _translatorsList = [];

  BehaviorSubject<String> onDescr;
  BehaviorSubject<bool> onLoad;
  BehaviorSubject<List<Translator>> onTranslators;

  Film(
      this._name,
      this._id,
      this._year,
      this._country,
      this._genres,
      this._url,
      this._poster,
      this._type,
      this._description,
      this._rate,
      this._hls,
      this._mp4,
      this._loaded,
      this._translatorsList)
      : onDescr = BehaviorSubject<String>.seeded(_description),
        onLoad = BehaviorSubject<bool>.seeded(_loaded),
        onTranslators = BehaviorSubject<List<Translator>>.seeded(_translatorsList);

  Film.newFilm() : this('', '', 0, '', [], '', '', '', '', '', '', '', false, []);

  String get name => _name;
  String get id => _id;
  int get year => _year;
  String get country => _country;
  List<String> get genres => _genres;
  String get url => _url;
  String get poster => _poster;
  String get type => _type;
  String get description => _description;
  String get rate => _rate;
  String get hls => _hls;
  String get mp4 => _mp4;
  List<Map<String, String>> get translators => _translators;
  List<Translator> get translatorsList => _translatorsList;

  void descriptionChange(String description) {
    onDescr.add(description);
    _description = description;
  }

  void isLoaded(bool loaded) {
    onLoad.add(loaded);
    _loaded = loaded;
  }

  void setName(String value) {
    _name = value;
  }

  void setId(String id) {
    _id = id;
  }

  void setYear(int value) {
    _year = value;
  }

  void setCountry(String value) {
    _country = value;
  }

  void setGenre(List genres) {
    for (var item in genres) {
      _genres.add(item.toString());
    }
  }

  void setUrl(String value) {
    _url = value;
  }

  void setPoster(String poster) {
    _poster = poster;
  }

  void setType(String type) {
    _type = type;
  }

  void setRate(String rate) {
    _rate = rate;
  }

  void setDescr(String descr) {
    _description = descr;
  }

  void setHls(String hls) {
    _hls = hls;
  }

  void setMp4(String mp4) {
    _mp4 = mp4;
  }

  void setTranslators(List<Map<String, String>> translators) {
    _translators = translators;
  }

  void addTranslator(Translator translator) {
    _translatorsList.add(translator);
    onTranslators.add(_translatorsList);
  }
  
}
