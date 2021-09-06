import 'dart:convert';
import 'dart:developer';

import 'package:my_tv/episode.dart';
import 'package:my_tv/my_http.dart';
import 'package:my_tv/translator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:my_tv/film.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:my_tv/translatorsCodes.dart';
import 'seasonsScreen.dart';

import '../season.dart';

class filmDetails extends StatelessWidget {
  Film film;
  var http;

  filmDetails({required this.film, required this.http});

  @override
  Widget build(BuildContext context) {
    check().then((value) {
      film.isLoaded(true);
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
                                  Row(children: [
                                    Expanded(
                                      child: Text(
                                        film.rate != ''
                                            ? 'Жанр: ${film.genres.toString().replaceAll('[', '').replaceAll(']', '')}' +
                                                '\nРейтинг ${film.rate}'
                                            : 'Жанр: ${film.genres.toString().replaceAll('[', '').replaceAll(']', '')}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Страна: ${film.country}\n ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ]),
                                  Divider(
                                    color: Colors.grey.shade600,
                                  ),
                                  Text(
                                    film.description,
                                    style: TextStyle(color: Colors.white),
                                  ),
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
      getSeasonsCount(
              trans.keys.toString().replaceAll('(', '').replaceAll(')', ''),
              translator)
          .then((value) {
        translator.setName(
            trans.values.toString().replaceAll('(', '').replaceAll(')', ''));
        translator.setId(
            trans.keys.toString().replaceAll('(', '').replaceAll(')', ''));
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

  Future<void> getSeasonsCount(
      String translatorId, Translator translator) async {
    var response =
        await http.get(Uri.parse('${film.url}#t:$translatorId-s:1-e:1'));
    var document = html_parser.parse(response.body);

    var seasons = document.querySelectorAll('[id^="simple-episodes-list-"]');

    for (var i = 1; i <= seasons.length; i++) {
      var season = Season();

      var episodes = document.querySelectorAll('[data-season_id^="$i"]');
      season.setCount(episodes.length);
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
        {'110': 'Не нужен'}
      ]);
    } else {
      film.setTranslators(translatorsMap);
    }
  }

  Future<void> parseTranslators(int seasons) async {
    if (film.translators != null) {
      for (var trans in film.translators) {
        var translator = Translator();
        var translatorId =
            trans.keys.toString().replaceAll('(', '').replaceAll(')', '');
        var translatorName =
            trans.values.toString().replaceAll('(', '').replaceAll(')', '');

        translator.setId(translatorId);
        translator.setName(translatorName);

        getSeasons(translatorId, seasons, translator).then((seasonList) {
          film.addTranslator(translator);
        });
      }
    }
  }

  Future<void> getSeasons(
      String translatorId, int seasons, Translator translator) async {
    for (var i = 1; i <= seasons; i++) {
      getEpisodes(translatorId, i).then((season) {
        // translator.addSeason(season);
      });
    }
  }

  Future<void> getEpisodes(String translatorId, int seasonNum) async {
    var date = DateTime.now().millisecondsSinceEpoch;
    var jsUrl = Uri.parse('http://hdrezka.co/ajax/get_cdn_series/?t=$date');
    var urls;
    var episode = 1;

    do {
      var cookie = http.headers.values
          .toString()
          .replaceAll('(', '')
          .replaceAll(')', '');
      var body =
          'id=${film.id}&translator_id=$translatorId&season=$seasonNum&episode=$episode&favs=13a5841a-ba68-48f1-bea6-dd5adf9fe233&action=get_stream';

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

      var urls = jsonDecode(jsResponse.body);

      if (urls != null && urls['success'] == true && urls['url'] != false) {
        var str = urls['url'].toString().split(',');

        var url = str.last
            .substring(str.last.indexOf(']'), str.last.indexOf(' or'))
            .replaceAll(']', '');
        var episode = Episode(episode: url);
      }

      episode++;
    } while (urls != null && urls['success'] == true && urls['url'] != false);
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
