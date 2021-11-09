import 'package:http/http.dart' as simpleHttp;
import 'package:flutter/material.dart';
import 'package:my_tv/history.dart';
import 'dart:convert';
import 'package:my_tv/parsers/rezka.dart';
import 'package:my_tv/searchResultsList.dart';
import 'package:rxdart/rxdart.dart';
import 'menu.dart';
import 'package:my_tv/film.dart';
import 'result.dart';
import 'package:my_tv/my_http.dart';
import 'package:download_assets/download_assets.dart';
import 'package:my_tv/widgets/showUpgradeDialog.dart';

class MainScreen extends StatelessWidget {
  final http = NetworkService();
  final searchResult = SearchResultsList.newSearch();
  final ver = 20;
  String description = 'Есть обновление. Скачать?';
  static int focusedFilm = 0;

  static late BehaviorSubject<int> focused = BehaviorSubject<int>.seeded(focusedFilm);

  static void onFocus(int focus) {
    focusedFilm = focus;
    focused.add(focus);
  }

  Future<bool> checkUpdates() async {
    var response = await simpleHttp
        .get(Uri.parse('http://demeo.euronet.dn.ua/mytv/output-metadata.json'));

    var release = jsonDecode(response.body);

    int newVer = release['elements'][0]['versionCode'];

    if (newVer > ver) {
      var descResponse = await simpleHttp
          .get(Uri.parse('http://demeo.euronet.dn.ua/mytv/update.txt'));
      description = descResponse.body;
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final rezka = Rezka(http: http);
    History.fromJson();

    checkUpdates().then((needUpgrade) {
      if (needUpgrade) {
        DownloadAssetsController.init();
        showUpgradeDialog(context: context, description: description);
      }
    });

    final aspectRatio = (((MediaQuery.of(context).size.height) /
                    MediaQuery.of(context).size.width) * 100).ceil() / 100;

    rezka.showNew(searchResult);

    Menu.index = 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Center(
        child: Row(children: [
          Expanded(
            child: Container(
              child: StreamBuilder<int>(
                  stream: Menu.onIndex,
                  builder: (context, snapshot) {
                    return Menu(
                      rezka: rezka,
                      searchResult: searchResult,
                      http: http,
                    );
                  }),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              child: StreamBuilder<List<Film>>(
                  stream: searchResult.onFilmAdd,
                  builder: (context, snapshot) {
                    var list = snapshot.data ?? [];
                    if (Menu.index == 0 ||
                        Menu.index == 1 ||
                        Menu.index == 3 ||
                        Menu.index == 6 ||
                        Menu.index == 9) {
                      searchResult.sortList();
                    }
                    return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: aspectRatio,
                          crossAxisCount: 5,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          // if(Menu.index == 1 || Menu.index == 3 || Menu.index == 6 || Menu.index == 9) {
                          //   searchResult.sortList();
                          // }
                          return Result(
                            searchResult: searchResult,
                            index: index,
                            http: http,
                          );
                        });
                  }),
            ),
          ),
        ]),
      ),
    );
  }
}
