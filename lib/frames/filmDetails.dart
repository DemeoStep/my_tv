import 'package:video_player/video_player.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:my_tv/film.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:my_tv/player.dart';

class filmDetails extends StatelessWidget {
  Film film;

  filmDetails({required this.film});

  openMXPlayer() async {
    launch(film.mp4);
  }

  @override
  Widget build(BuildContext context) {
    parse().then((value) {
      film.isLoaded(true);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: StreamBuilder<bool>(
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
                              Row(
                                children: [
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
                                ]
                              ),
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
                Container(
                  margin: EdgeInsets.only(left: 10),
                  width: 165,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: film.hls.isNotEmpty
                      ? TextButton(
                    child: Text('PLAY'),
                    onPressed: () {
                      openMXPlayer();
                    },
                  ) : Text('')
                  ,
                )
              ],
            );
          }),
    );
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
    stream = stream.replaceAll('[${quality}]', '');
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
