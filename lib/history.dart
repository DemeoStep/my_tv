import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'film.dart';

class History {
  static Set<ViewedFilm> _viewed = {};

  static Set<ViewedFilm> get viewed => _viewed;

  static void addFilm({required Film film}) async {
    _viewed.add(ViewedFilm(film: film));
    print(film.progress);
    await saveHistory();
  }

  static void changeProgress({required Film film}) async {
    if(_viewed.contains(ViewedFilm(film: film))) {
      _viewed.remove(ViewedFilm(film: film));
      print("remove film from history");
    }

    addFilm(film: film);
  }

  static Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/history.txt');
  }

  static Future<File> saveHistory() async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode(toJson()));
  }

  static Future<String> readHistory() async {
    try {
      final file = await _localFile;

      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      return '';
    }
  }

  static void printHistory() {
    for(int i = 0; i < _viewed.length; i++) {
      print(_viewed.elementAt(i));
    }
  }

  static List<Map<String, dynamic>> toJson() {
    return viewed.map((e) => e.toJson()).toList();
  }

  static void fromJson() async {
    var list = jsonDecode(await readHistory()) as List<dynamic>;

    _viewed = await list.map((dynamic e) => ViewedFilm.fromJson(e as Map<String, dynamic>)).toSet();

    printHistory();

  }

}

class ViewedFilm {
  var _name;
  var _id;
  var _year;
  var _url;
  var _poster;
  var _type;
  var _progress;

  get url => _url;
  get name => _name;
  get id => _id;
  get year => _year;
  get poster => _poster;
  get type => _type;
  get progress => _progress;

  ViewedFilm({required Film film}) {
    _name = film.name;
    _id = film.id;
    _year = film.year;
    _url = film.url;
    _poster = film.poster;
    _type = film.type;
    _progress = film.progress;
  }

  @override
  String toString() {
    return 'ViewedFilm{_name: $_name, _id: $_id, _year: $_year, _url: $_url, _poster: $_poster, _type: $_type, _progress: $_progress}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewedFilm &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'name' : _name,
      'id' : _id,
      'year' : _year,
      'url' : _url,
      'poster' : _poster,
      'type' : _type,
      'progress' : _progress
    };
  }

  factory ViewedFilm.fromJson(Map<String, dynamic> json) {
    var film = Film.newFilm();

    film.setName(json['name']);
    film.setId(json['id']);
    film.setYear(json['year']);
    film.setUrl(json['url']);
    film.setPoster(json['poster']);
    film.setType(json['type']);
    film.setProgress(json['progress'] ?? "00:00:00");

    return ViewedFilm(film: film);
  }
}