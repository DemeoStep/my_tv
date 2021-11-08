import 'dart:convert';
import 'dart:ui';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:my_tv/chewie_player.dart';
import 'package:my_tv/history.dart';
import 'package:my_tv/my_http.dart';
import 'package:rxdart/rxdart.dart';
import '../film.dart';
import '../translator.dart';

class SeasonsScreen extends StatelessWidget {
  Translator translator;
  NetworkService http;
  Film film;

  List<String> playlist = [];
  List<BetterPlayerDataSource> dataSourceList = [];

  var seasonSelected;
  BehaviorSubject<int> onSeason;

  SeasonsScreen(
      {required this.film,
      required this.http,
      required this.translator,
      required this.seasonSelected})
      : onSeason = BehaviorSubject<int>.seeded(seasonSelected);

  void seasonSelect(int index) {
    onSeason.add(index);
    seasonSelected = index;
  }

  Future<void> getEpisodes(int season, int episode, Translator translator) async {
    var date = DateTime.now().millisecondsSinceEpoch;
    var jsUrl = Uri.parse('http://hdrezka.co/ajax/get_cdn_series/?t=$date');

    var cookie =
        http.headers.values.toString().replaceAll('(', '').replaceAll(')', '');
    var body =
        'id=${film.id}&translator_id=${translator.id}&season=${translator.seasonsList[season].id}&episode=${translator.seasonsList[season].episodes[episode].episode}&action=get_stream';

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

    playlist.add(urls.last.trim());

    if(episode + 1 < translator.seasonsList[season].episodes.length) {
      episode++;
      await getEpisodes(season, episode, translator);
    }

  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [];

    for (var season in translator.seasonsList) {
      tabs.add(Tab(
        child: FittedBox(child: Text('${season.id} сезон', maxLines: 1, textAlign: TextAlign.center,)),
      ));
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
                toolbarHeight: 0,
                automaticallyImplyLeading: false,
                bottom: TabBar(
                    onTap: (index) => seasonSelect(index),
                    labelStyle: TextStyle(fontSize: 20),
                    indicatorColor: Colors.yellowAccent,
                    tabs: tabs),
              ),
              backgroundColor: Colors.grey.shade900,
              body: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    // childAspectRatio: 0.57,
                    crossAxisCount: 7,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  padding: EdgeInsets.all(8),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.grey.shade700,
                            Colors.grey.shade800,
                          ],
                          stops: [0.9, 0.9], //percents
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey.withOpacity(0),
                          padding: EdgeInsets.zero,
                          side: BorderSide.none,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          await getEpisodes(season, 0, translator);
                          History.addFilm(film: film);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChewiePlayer(true, playlist: playlist, index: index, filmName: film.name, season: (season + 1).toString(),)));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          alignment: Alignment.center,
                          height: 50,
                          child: Text(
                            '${translator.seasonsList[season].episodes[index].episode} серия',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: translator.seasonsList[season].episodesCount),
            ),
          );
        });
  }
}
