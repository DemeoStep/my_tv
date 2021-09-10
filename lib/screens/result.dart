import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:my_tv/screens/filmDetails.dart';
import 'package:my_tv/searchResultsList.dart';

class Result extends StatelessWidget {
  SearchResultsList searchResult;
  var index;
  var http;

  Result({required this.searchResult, required this.index, required this.http});

  @override
  Widget build(BuildContext context) {
    var list = searchResult.list;

    return Container(
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Colors.grey.shade900,
      ),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          primary: Colors.cyanAccent,
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FilmDetails(
                        film: searchResult.list[index],
                        http: http,
                      )));
          //searchResult.selectFilm(index: index);
        },
        child: Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Stack(children: [
                  Container(
                    height: 220,
                    /* decoration: BoxDecoration(boxShadow: [
                      BoxShadow(blurRadius: 3),
                    ]), */
                    child: Image.network(
                      list[index].poster,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Positioned.directional(
                    textDirection: TextDirection.ltr,
                    top: 3,
                    start: 3,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      color: Colors.black54,
                      child: Text(
                        list[index].type,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          /* shadows: [
                            Shadow(color: Colors.black, blurRadius: 3),
                            Shadow(color: Colors.black, blurRadius: 3),
                            Shadow(color: Colors.black, blurRadius: 3),
                            Shadow(color: Colors.black, blurRadius: 3),
                          ], */
                        ),
                      ),
                    ),
                  ),
                  Positioned.directional(
                    textDirection: TextDirection.ltr,
                    bottom: 2,
                    end: 2,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      color: Colors.black54,
                      child: Text(
                        list[index].year.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          /* shadows: [
                            Shadow(color: Colors.black, blurRadius: 3),
                            Shadow(color: Colors.black, blurRadius: 3),
                            Shadow(color: Colors.black, blurRadius: 3),
                            Shadow(color: Colors.black, blurRadius: 3),
                          ], */
                        ),
                      ),
                    ),
                  ),
                ]),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.centerLeft,
                    child: list[index].name.length > 11
                        ? Marquee(
                            startAfter: Duration(seconds: 5),
                            text: list[index].name,
                            blankSpace: 100,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )
                        : Text(
                            list[index].name,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
