import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'keyboard.dart';

class Search extends StatelessWidget {
  String _searchQuery;

  BehaviorSubject<String> onQuery;

  Search(this._searchQuery)
      : onQuery = BehaviorSubject<String>.seeded(_searchQuery);

  void queryChange(String query) {
    onQuery.add(query);
    _searchQuery = query;
    print(query);
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
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              color: Colors.deepPurple,
                              child: Text(string),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Keyboard(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(),
                    ),
                  ]);
            }),
      ),
    );
  }
}
