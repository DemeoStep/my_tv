import 'package:http/http.dart' as http;
import 'package:my_tv/film.dart';
import 'dart:convert';
import 'package:my_tv/searchResultsList.dart';

class TMDB {
  final String apiKey = 'api_key=d1ba7d3fec5a577bb81519def72d8e65';
  final String posterPath = 'https://image.tmdb.org/t/p/w500';
  final String token =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkMWJhN2QzZmVjNWE1NzdiYjgxNTE5ZGVmNzJkOGU2NSIsInN1YiI6IjYxMjYyM2FlZDcwNTk0MDA5NTdjZTNmMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.b44X2Fz1KrTx0mPB_RDL3-3Tt36Ud2Ka9M0-CFMOxu0';

  final List<Map<String, String>> genres = [
    {"id": '28', "name": "боевик"},
    {"id": '12', "name": "приключения"},
    {"id": '16', "name": "мультфильм"},
    {"id": '35', "name": "комедия"},
    {"id": '80', "name": "криминал"},
    {"id": '99', "name": "документальный"},
    {"id": '18', "name": "драма"},
    {"id": '10751', "name": "семейный"},
    {"id": '14', "name": "фэнтези"},
    {"id": '36', "name": "история"},
    {"id": '27', "name": "ужасы"},
    {"id": '10402', "name": "музыка"},
    {"id": '9648', "name": "детектив"},
    {"id": '10749', "name": "мелодрама"},
    {"id": '878', "name": "фантастика"},
    {"id": '10770', "name": "телевизионный фильм"},
    {"id": '53', "name": "триллер"},
    {"id": '10752', "name": "военный"},
    {"id": '37', "name": "вестерн"}
  ];

  void search(
      {required String type,
      required String query,
      required SearchResultsList result}) async {
    var url = Uri.parse(
        'https://api.themoviedb.org/3/search/$type?query=$query&language=ru');

    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json;charset=utf-8'
    });

    var json = jsonDecode(response.body);

    for (var item in json['results']) {
      if (item['poster_path'] != null) {
        filmAdd(item: item, result: result, type: type);
      }
    }
  }

  void list(
      {required String type,
      required String category,
      required SearchResultsList result}) async {
    var url =
        Uri.parse('https://api.themoviedb.org/3/$type/$category?&language=ru');

    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json;charset=utf-8'
    });
    var json = jsonDecode(response.body);

    for (var item in json['results']) {
      if (item['poster_path'] != null) {
        filmAdd(item: item, result: result, type: type);
      }
    }
  }

  void filmAdd(
      {required var item,
      required SearchResultsList result,
      required String type}) {
    Film film = Film.newFilm();
    film.setName(item['title']);
    if (item['poster_path'] != null) {
      film.setPoster(posterPath + item['poster_path']);
    }
    var genresIds = item['genre_ids'] as List;

    for (var i = 0; i < genresIds.length; i++) {
      genresIds[i] = genres.firstWhere(
          (element) => element['id'] == genresIds[i].toString())['name'];
    }

    film.setGenre(genresIds);

    film.setYear(int.parse(item['release_date'].toString().substring(0, 4)));

    if (film.genres.any((element) => element == 'мультфильм')) {
      film.setType('Мультфильм');
    } else {
      switch (type) {
        case 'tv':
          film.setType('Сериал');
          break;
        default:
          {
            film.setType('Фильм');
          }
      }
    }

    result.filmAdd(film);
  }
}
