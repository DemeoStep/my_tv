import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_tv/frames/filmDetails.dart';
import 'package:my_tv/frames/menu.dart';
import 'package:my_tv/frames/search_results.dart';
import 'package:my_tv/parsers/tmdb.dart';
import 'parsers/rezka.dart';
import 'searchResult.dart';
import 'film.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My TV',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final tmdb = TMDB();
  final rezka = Rezka();
  final searchResult = SearchResult.newSearch();

  @override
  Widget build(BuildContext context) {
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
                    );
                  }),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: StreamBuilder<int>(
                stream: searchResult.onSelect,
                builder: (context, snapshot) {
                  var selected = snapshot.data ?? -1;
                  print(selected);
                  if (selected != -1) {
                    return filmDetails(
                      film: searchResult.list[selected],
                    );
                  } else
                    return Container(
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
                                  return SearchResults(
                                    searchResult: searchResult,
                                    index: index,
                                  );
                                });
                          }),
                    );
                }),
          ),
        ]),
      ),
    );
  }
}
