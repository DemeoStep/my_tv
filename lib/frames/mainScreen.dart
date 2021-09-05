import 'package:flutter/material.dart';
import 'package:my_tv/parsers/rezka.dart';
import 'package:my_tv/searchResultsList.dart';
import 'menu.dart';
import 'package:my_tv/film.dart';
import 'result.dart';
import 'package:my_tv/my_http.dart';

class MainScreen extends StatelessWidget {
  final http = NetworkService();
  final searchResult = SearchResultsList.newSearch();
  @override
  Widget build(BuildContext context) {
    final rezka = Rezka(http: http);

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
                    return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 0.57,
                          crossAxisCount: 5,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          return result(
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
