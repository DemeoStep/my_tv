import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_tv/my_http.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../film.dart';
import '../translator.dart';

class SeasonsScreen extends StatelessWidget {
  Translator translator;
  NetworkService http;
  Film film;

  var seasonSelected;
  BehaviorSubject<int> onSeason;

  SeasonsScreen({required this.film, required this.http, required this.translator, required this.seasonSelected}) : onSeason = BehaviorSubject<int>.seeded(seasonSelected);

  void seasonSelect(int index) {
    onSeason.add(index);
    seasonSelected = index;
  }

  Future<void> getEpisode(int season, int episode, String translatorId) async {
    var date = DateTime.now().millisecondsSinceEpoch;
    var jsUrl = Uri.parse('http://hdrezka.co/ajax/get_cdn_series/?t=$date');

    print(film.url);

      var cookie = http.headers.values.toString().replaceAll('(', '').replaceAll(')', '');
      var body = 'id=${film.id}&translator_id=$translatorId&season=${season.toString()}&episode=${episode.toString()}&action=get_stream';

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

      var jsResponse = await http.post(jsUrl,
          body: body);

      var str = jsonDecode(jsResponse.body)['url'].toString().split(',');

      var urls = str.last.split('or');

      launch(urls.last.trim());

  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [];

    for(var i = 1; i <= translator.seasonsCount; i++) {
      tabs.add(Tab(text: 'Сезон $i',));
    }

    return StreamBuilder<int>(
      stream: onSeason,
      builder: (context, snapshot) {
        var season = snapshot.data ?? 0;
        return DefaultTabController(
          length: translator.seasonsCount,
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.grey.shade800,
                toolbarHeight: 48,
                automaticallyImplyLeading: false,
                bottom: TabBar(
                  onTap: (index) => seasonSelect(index),
                    labelStyle: TextStyle(fontSize: 20),
                    indicatorColor: Colors.yellowAccent,
                    tabs: tabs),
              ),
              backgroundColor: Colors.grey.shade900,
              body: GridView.builder(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    // childAspectRatio: 0.57,
                    crossAxisCount: 7,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  padding: EdgeInsets.all(8),
                  itemBuilder: (BuildContext context, int index) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey.shade800,
                        padding: EdgeInsets.zero,
                        side: BorderSide.none,
                      ),
                      onPressed: () {
                        getEpisode(season + 1, index + 1, translator.id);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        height: 50,
                        child: Text(
                          '${index + 1} серия',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                  itemCount: translator.seasonsList[season].episodesCount),
          ),
        );
      }
    );
  }
}
