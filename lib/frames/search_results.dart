import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:my_tv/searchResult.dart';

class SearchResults extends StatelessWidget {
  SearchResult searchResult;
  var index;

  SearchResults({required this.searchResult, required this.index});

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
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          searchResult.selectFilm(index: index);
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
                  Positioned.directional(
                    textDirection: TextDirection.ltr,
                    bottom: 2,
                    end: 2,
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
