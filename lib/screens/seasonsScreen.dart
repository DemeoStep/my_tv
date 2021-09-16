import 'dart:convert';
import 'dart:io';
import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_tv/my_http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:my_tv/player.dart';
import '../film.dart';
import '../translator.dart';

class SeasonsScreen extends StatelessWidget {
  Translator translator;
  NetworkService http;
  Film film;
  File? playlist;

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

  Future<void> getEpisode(int season, int episode, Translator translator) async {
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

    dataSourceList.add(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        urls.last.trim(),
      ),
    );

    print(urls.last.trim());

    if(episode + 1 < translator.seasonsList[season].episodes.length) {
      episode++;
      await getEpisode(season, episode, translator);
    }

  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  Future<void> get _localFile async {
    final path = await _localPath;
    playlist = File('$path/season.m3u');
  }

  Future<void> writeEpisode(String playlistString) async {
    playlist!.writeAsString('$playlistString\n', mode: FileMode.append);
  }
  
  Future<void> createPlaylist() async {
    _localFile.then((value) {
      playlist!.writeAsString('#EXTM3U\n');
      //     '#EXT-X-TARGETDURATION:6\n' +
      // '#EXT-X-ALLOW-CACHE:YES\n' +
      // '#EXT-X-PLAYLIST-TYPE:VOD\n' +
      // '#EXT-X-VERSION:3\n' +
      // '#EXT-X-MEDIA-SEQUENCE:1\n');
    });
  }

  Future<void> readEpisodes() async {
    try {
      // Read the file
      final contents = await playlist!.readAsString();

      print(contents);
    } catch (e) {
      // If encountering an error, return 0
      print(e);
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      onPressed: () async {
                        await createPlaylist();
                        await getEpisode(season, index, translator);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Player(dataSourceList: dataSourceList)));
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        height: 50,
                        child: Text(
                          '${translator.seasonsList[season].episodes[index].episode} серия',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          textAlign: TextAlign.center,
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
