import 'package:html/parser.dart' as html_parser;
import 'package:my_tv/history.dart';
import 'package:my_tv/searchResultsList.dart';
import 'package:my_tv/film.dart';

class Rezka {
  final http;

  Rezka({required this.http});

  static final host = 'hdrezka.co';

  static final searchUrl = 'http://$host/search/?do=search&subaction=search&q=';

  Future<void> makeSearch(String query, SearchResultsList result) async {
    result.list.clear();
    var url = Uri.parse(searchUrl + query);

    await parse(url, result);
  }

  Future<void> showNew(SearchResultsList result) async {
    result.list.clear();
    for (var v = 1; v < 5; v++) {
      var url = Uri.parse('http://$host/page/$v/?filter=last');

      await parse(url, result);
    }
  }

  Future<void> showHistory(
      {required SearchResultsList result, required Set<ViewedFilm> viewed}) async {
    result.list.clear();
    for(ViewedFilm film in viewed) {
      var viewedFilm = Film.newFilm();
      viewedFilm.setName(film.name);
      viewedFilm.setUrl(film.url);
      viewedFilm.setId(film.id);
      viewedFilm.setYear(film.year);
      viewedFilm.setPoster(film.poster);
      viewedFilm.setType(film.type);

      result.filmAdd(viewedFilm);
    }
  }

  Future<void> doSearch(
      {required SearchResultsList result, required String query}) async {
    if (query.length > 2) {
      result.list.clear();
      var url =
          Uri.parse('http://$host/search/?do=search&subaction=search&q=$query');
      await parse(url, result);
    }
  }

  Future<void> showType(
      {required SearchResultsList result,
      required String type,
      required String filter}) async {
    result.list.clear();
    for (var v = 1; v < 5; v++) {
      var url = Uri.parse('http://$host/$type/page/$v/?$filter');

      await parse(url, result);
    }
  }

  Future<void> parse(Uri url, SearchResultsList result) async {
    var response = await http.get(url);
    final document = html_parser.parse(response.body);
    var links = document.getElementsByClassName('b-content__inline_item');

    for (var element in links) {
      var film = Film.newFilm();
      var link = element.children;

      for (var str in link) {
        var item = str.outerHtml;
        var imageUrl;
        var name;
        var id;
        var year;
        var country;
        var genre;
        var type;
        var url;

        if (item.contains('<img src=')) {
          imageUrl = item
              .substring(item.indexOf('<img src="'), item.indexOf('" height='))
              .replaceAll('<img src="', '');
          film.setPoster(imageUrl);

          type = item
              .substring(
                  item.indexOf('"entity">'), item.indexOf('<i class="icon">'))
              .replaceAll('"entity">', '')
              .replaceAll('</i>', '');
          film.setType(type);

          url = item
              .substring(item.indexOf('href='), item.indexOf('"> <img'))
              .replaceAll('href="', '');

          film.setUrl(url);
        }

        id = film.url
            .substring(film.url.lastIndexOf('/'), film.url.indexOf('-'))
            .replaceAll('/', '');
        film.setId(id);

        if (!item.contains('<img src=')) {
          name = item
              .substring(item.indexOf('.html">'), item.indexOf('</a>'))
              .replaceAll('.html">', '');
          film.setName(name);

          var string = item
              .substring(item.indexOf('<div>'), item.indexOf('</div>'))
              .replaceAll('<div>', '');

          year = int.parse(string.substring(0, 4));
          film.setYear(year);

          string = string
              .replaceAll(string.substring(0, string.indexOf(',')), '')
              .replaceFirst(', ', '');

          if (string.contains(',')) {
            country = string.substring(0, string.lastIndexOf(','));
            film.setCountry(country);
            genre = string.replaceAll(country + ', ', '');
          } else {
            genre = string;
          }

          film.setGenre([genre]);
        }
      }
      result.filmAdd(film);
    }
  }
}
