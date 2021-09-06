import 'package:flutter/material.dart';
import 'package:my_tv/speech_api.dart';
import 'package:rxdart/rxdart.dart';
import 'keyboard.dart';
import 'package:my_tv/searchResultsList.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:my_tv/film.dart';
import 'filmDetails.dart';
import 'result.dart';

class Search extends StatelessWidget {
  String _searchQuery;
  var rezka;
  var http;
  var searchResult = SearchResultsList.newSearch();
  bool isListening = false;

  BehaviorSubject<String> onQuery;
  BehaviorSubject<bool> onListening;

  Search(this._searchQuery, this.rezka, this.http, this.isListening)
      : onQuery = BehaviorSubject<String>.seeded(_searchQuery),
        onListening = BehaviorSubject<bool>.seeded(isListening);

  void listeningChange(bool isListening) {
    onListening.add(isListening);
    this.isListening = isListening;
  }

  void queryAdd(String query, bool isSpeech) {
    if(isSpeech) {
      onQuery.add(query);
      _searchQuery = query;
    } else {
      onQuery.add(_searchQuery + query);
      _searchQuery += query;
    }
    rezka.doSearch(result: searchResult, query: _searchQuery);
  }

  void queryBackspace() {
    if (_searchQuery.length > 0) {
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(left: 10, top: 15),
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    string,
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ),
                                Expanded(
                                  child: StreamBuilder<bool>(
                                      stream: onListening,
                                      builder: (context, snapshot) {
                                        var isListening =
                                            snapshot.data ?? false;
                                        return AvatarGlow(
                                          animate: isListening,
                                          endRadius: 60,
                                          child: FloatingActionButton(
                                            autofocus: true,
                                            focusColor: Colors.red.shade200,
                                            backgroundColor: Colors.red,
                                            onPressed: toggleRecording,
                                            child: isListening
                                                ? Icon(Icons.mic)
                                                : Icon(Icons.mic_none),
                                          ),
                                        );
                                      }),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Keyboard(this, 0),
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => filmDetails(
                                            film: searchResult.list[selected],
                                            http: http,
                                          )));
                            }
                            return Container(
                              child: StreamBuilder<List<Film>>(
                                  stream: searchResult.onFilmAdd,
                                  builder: (context, snapshot) {
                                    var list = snapshot.data ?? [];
                                    return GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 0.52,
                                          crossAxisCount: 7,
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
                            );
                          }),
                    ),
                  ]);
            }),
      ),
    );
  }

  Future toggleRecording() => SpeechApi.toggleRecording(
      onResult: (text) => queryAdd(text, true),
      onListening: (isListening) {
        listeningChange(isListening);
      });
}
