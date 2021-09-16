import 'dart:convert';

import 'package:my_tv/episode.dart';
import 'package:my_tv/translator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:my_tv/film.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:my_tv/translatorsCodes.dart';
import 'seasonsScreen.dart';

import '../season.dart';

class FilmDetails extends StatelessWidget {
  final Film film;
  final http;

  FilmDetails({required this.film, required this.http});

  @override
  Widget build(BuildContext context) {
    check().then((value) {
      parse().then((value) {
        film.isLoaded(true);
      });
    });

    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade800,
          toolbarHeight: 48,
          automaticallyImplyLeading: false,
          bottom: TabBar(
              labelStyle: TextStyle(fontSize: 20),
              indicatorColor: Colors.yellowAccent,
              tabs: [
                Tab(text: 'Описание'),
                Tab(text: 'Смотреть'),
                Tab(text: 'Торренты'),
              ]),
        ),
        backgroundColor: Colors.grey.shade900,
        body: TabBarView(children: [
          StreamBuilder<bool>(
              stream: film.onLoad,
              builder: (context, snapshot) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      color: Colors.grey.shade900,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Image.network(
                              film.poster,
                              filterQuality: FilterQuality.high,
                              scale: 0.7,
                              alignment: Alignment.topLeft,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${film.name} (${film.year})',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Divider(
                                    color: Colors.grey.shade600,
                                  ),
                                  film.rate.isNotEmpty ? fields('Рейтинг ', film.rate) : Container(),
                                  fields('Жанр: ', film.genres.toString().replaceAll('[', '').replaceAll(']', '')),
                                  fields('Страна: ', film.country),
                                  film.age.isNotEmpty ? fields('Возрастные ограничения: ', film.age) : Container(),
                                  Divider(
                                    color: Colors.grey.shade600,
                                  ),
                                  fields('Описание: ', film.description),
                                  Divider(
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
          StreamBuilder<List<Translator>>(
              stream: film.onTranslators,
              builder: (context, snapshot) {
                var list = snapshot.data ?? [];
                return ListView.separated(
                  padding: EdgeInsets.all(8),
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey.shade800,
                        padding: EdgeInsets.zero,
                        side: BorderSide.none,
                      ),
                      onPressed: () {
                        film.type == 'Сериал'
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SeasonsScreen(
                                          film: film,
                                          http: http,
                                          translator: list[index],
                                          seasonSelected: 0,
                                        )))
                            : playFilm(list[index].id);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.centerLeft,
                        height: 50,
                        child: Text(
                          '${list[index].name}',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                );
              }),
          Text('Торренты', style: TextStyle(color: Colors.white)),
        ]),
      ),
    );
  }

  Widget fields (String fieldName, String value) {
    return RichText(text: TextSpan(
        text: '$fieldName ',
        style: TextStyle(color: Colors.yellow),
        children: <TextSpan> [
          TextSpan(
            text: value,
            style: TextStyle(color: Colors.white),
          )
        ]
    ));
  }

  Future<void> check() async {
    await getTranslators();
    if (film.type == 'Сериал') {
      await serialParse();
    } else {
      var serial = await isSerial();
      if (serial) {
        film.setType('Сериал');
        await serialParse();
      } else
        await filmParse();
    }

    for(var translator in film.translatorsList) {
      print(translator.seasonsList.length);
    }
  }

  Future<bool> isSerial() async {
    var response = await http.get(Uri.parse(film.url));
    var document = html_parser.parse(response.body);

    var seasons = document.getElementById('simple-seasons-tabs');

    return seasons != null;
  }

  Future<void> serialParse() async {
    film.translatorsList.clear();
    for (var trans in film.translators) {
      var translator = Translator();
      translator.setName(
          trans.values.toString().replaceAll('(', '').replaceAll(')', ''));
      translator.setId(
          trans.keys.toString().replaceAll('(', '').replaceAll(')', ''));

      getSeasonsCount(translator)
          .then((value) {
        film.addTranslator(translator);
      });
    }

  }

  Future<void> filmParse() async {
    film.translatorsList.clear();
    for (var trans in film.translators) {
      var translator = Translator();

      translator.setName(
          trans.values.toString().replaceAll('(', '').replaceAll(')', ''));
      translator
          .setId(trans.keys.toString().replaceAll('(', '').replaceAll(')', ''));
      film.addTranslator(translator);
    }
  }

  Future<void> playFilm(String translatorId) async {
    var date = DateTime.now().millisecondsSinceEpoch;
    var jsUrl = Uri.parse('http://hdrezka.co/ajax/get_cdn_series/?t=$date');

    var cookie =
        http.headers.values.toString().replaceAll('(', '').replaceAll(')', '');
    var body =
        'id=${film.id}&translator_id=$translatorId&is_camrip=0&is_ads=0&is_director=0&action=get_movie';

    http.headers = {
      'Host': 'hdrezka.co',
      'User-Agent':
          'Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101 Firefox/91.0',
      'Accept': 'application/json, text/javascript, */*; q=0.01',
      'Accept-Language': 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3',
      'Accept-Encoding': 'gzip, deflate',
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'X-Requested-With': 'XMLHttpRequest',
      'Origin': 'http://hdrezka.co',
      'Connection': 'keep-alive',
      'Referer': film.url,
      'Cookie': cookie,
    };

    var jsResponse = await http.post(jsUrl, body: body);

    var str = jsonDecode(jsResponse.body)['url'].toString().split(',');

    var urls = str.last.split('or');

    launch(urls.last.trim());
  }

  Future<void> getSeasonsCount(Translator translator) async {
    var date = DateTime.now().millisecondsSinceEpoch;
    var url = Uri.parse('http://hdrezka.co/ajax/get_cdn_series/?t=$date');

    var cookie = http.headers.values.toString().replaceAll('(', '').replaceAll(')', '');
    var body = 'id=${film.id}&translator_id=${translator.id}&action=get_episodes';

    http.headers = {
      'Host': 'hdrezka.co',
      'User-Agent':
      'Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101 Firefox/91.0',
      'Accept': 'application/json, text/javascript, */*; q=0.01',
      'Accept-Language': 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3',
      'Accept-Encoding': 'gzip, deflate',
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'X-Requested-With': 'XMLHttpRequest',
      'Origin': 'http://hdrezka.co',
      'Connection': 'keep-alive',
      'Referer': film.url,
      'Cookie': cookie,
    };

    var response = await http.post(url, body: body);

    var str = jsonDecode(response.body);

    var seasons = str['seasons'].toString().split('</li>');

    for(var item in seasons) {
      if(item == '') continue;

      var season = Season();

      season.setId(item.substring(item.indexOf('data-tab_id="'), item.indexOf('">Сезон')).replaceAll('data-tab_id="', ''));
      var rawstr = str['episodes'].toString().split('</ul>');

      for(var item in rawstr) {
        var episodes = item.split('</li>');

        for(var episode in episodes) {
          if(episode == '') continue;

          var seasonId = episode.substring(episode.indexOf('data-season_id="'), episode.indexOf('" data-episode_id=')).replaceAll('data-season_id="', '');

          if(seasonId == season.id) {
            episode = episode.substring(episode.indexOf('data-episode_id="'), episode.indexOf('">Серия')).replaceAll('data-episode_id="', '');
            season.addEpisode(Episode(episode: episode));
          }
        }

      }

      translator.addSeason(season);
    }

  }

  Future<void> getTranslators() async {
    var url = Uri.parse(film.url);
    var response = await http.get(url);

    var document = html_parser.parse(response.body);
    var translators = document.getElementsByClassName('b-translator__item');

    List<Map<String, String>> translatorsMap = [];

    if (translators.length > 0) {
      for (var translator in translators) {
        var out = translator.outerHtml;

        var translatorName = out
            .substring(out.indexOf('title'), out.indexOf('" class='))
            .replaceAll('title="', '');
        var translatorId = out
            .substring(out.indexOf('_id="'), out.indexOf('">'))
            .replaceAll('_id="', '');
        translatorsMap.add({translatorId: translatorName});
      }
    } else {
      translators = document.getElementsByTagName('tr');

      for (var translator in translators) {
        var inner = translator.innerHtml;
        if (inner.contains('перевод')) {
          var translatorName = inner
              .substring(inner.lastIndexOf('<td>'), inner.lastIndexOf('</td>'))
              .replaceAll('<td>', '');
          var translatorId = getCode(translatorName);
          translatorsMap.add({translatorId: translatorName});
        }
      }
    }
    if (translatorsMap.isEmpty) {
      film.setTranslators([
        {'110': 'Перевод не нужен'}
      ]);
    } else {
      film.setTranslators(translatorsMap);
    }
  }

  Future<void> parse() async {
    var url = Uri.parse(film.url);

    var response = await http.get(url);
    var body = response.body;

    var map = body
        .substring(
            body.indexOf('"streams":"'), body.indexOf(',"default_quality":'))
        .replaceAll('"streams":"', '')
        .split(',');

    var stream = map.last;

    var quality = stream.substring(0, stream.indexOf(']')).replaceAll('[', '');
    stream = stream.replaceAll('[$quality]', '');
    var hls = stream.substring(0, stream.indexOf(' or '));
    var mp4 =
        stream.replaceAll(hls, '').replaceAll(' or ', '').replaceAll('"', '');

    film.setHls(hls.replaceAll('\\', ''));
    film.setMp4(mp4.replaceAll('\\', ''));

    var document = html_parser.parse(response.body);
    var description =
        document.getElementsByClassName('b-post__description_text');
    var info = document.getElementsByClassName('b-post__info');

    film.setDescr(description[0].innerHtml.trim());

    var infoList = info[0].innerHtml.split('<tr>');

    for (var item in infoList) {
      if (item.contains('Рейтинги')) getRates(item);
    }

    var ages = document.getElementsByTagName('tr');
    for(var str in ages) {
      var out = str.innerHtml;
      if(out.contains('<td class="l"><h2>Возраст</h2>')) {
        var age = out.replaceAll('<td class="l"><h2>Возраст</h2>:</td> <td><span class="bold" style="color: #666;">', '').replaceAll('</span>', '').replaceAll('</td>', '');
        film.setAge(age);
      }

      if(out.contains('<td class="l"><h2>Жанр</h2>')) {
        var genres = out.replaceAll('<td class="l"><h2>Жанр</h2>:</td> <td>', '').replaceAll('</td>', '').split(',');
        List<String> genresList = [];
        for(var genre in genres) {
          genre = genre.substring(genre.indexOf('itemprop="genre">')).replaceAll('itemprop="genre">', '').replaceAll('</span></a>', '');
          genresList.add(genre);
        }
        film.setGenre(genresList);
      }
    }
  }

  void getRates(String item) {
    var ratingSource = item
        .substring(item.indexOf('"nofollow">'), item.indexOf('</a>:'))
        .replaceAll('"nofollow">', '');

    var rate = item
        .substring(item.indexOf('<span class="bold">'), item.indexOf('</span>'))
        .replaceAll('<span class="bold">', '');

    film.setRate('$ratingSource: $rate');
  }
}
