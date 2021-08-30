import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'keyboard.dart';
import 'package:my_tv/parsers/rezka.dart';
import 'package:my_tv/searchResultsList.dart';
import 'package:my_tv/film.dart';
import 'filmDetails.dart';
import 'result.dart';

class Search extends StatelessWidget {
  String _searchQuery;
  var rezka = Rezka();
  var searchResult = SearchResultsList.newSearch();

  BehaviorSubject<String> onQuery;

  Search(this._searchQuery)
      : onQuery = BehaviorSubject<String>.seeded(_searchQuery);

  void queryAdd(String query) {
    onQuery.add(_searchQuery + query);
    _searchQuery += query;
    rezka.doSearch(result: searchResult, query: _searchQuery);
  }

  void queryBackspace() {
    if(_searchQuery.length > 0) {
      _searchQuery = _searchQuery.substring(0, _searchQuery.length - 1);
      onQuery.add(_searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Center(
        child: StreamBuilder<String>(
            stream: onQuery,
            builder: (context, snapshot) {
              var string = snapshot.data ?? '';
              return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10, top: 15),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.teal.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(5),
                                // border: Border.all(width: 1, color: Colors.teal),
                              ),
                              child: Text(string, style: TextStyle(fontSize: 20, color: Colors.white),),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Keyboard(this, Keyboard.cyr!),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: StreamBuilder<int>(
                          stream: searchResult.onSelect,
                          builder: (context, snapshot) {
                            var selected = snapshot.data ?? -1;
                            if (selected != -1) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => filmDetails(film: searchResult.list[selected])));
                            }
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
                                            return result(
                                              searchResult: searchResult,
                                              index: index,
                                            );
                                          });
                                    }),
                              );
                          }),
                    ),
                  ]);
            }),
      ),
    );
  }
}
