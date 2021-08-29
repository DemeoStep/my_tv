import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'keyboard.dart';

class Search extends StatelessWidget {
  String _searchQuery;

  BehaviorSubject<String> onQuery;

  Search(this._searchQuery)
      : onQuery = BehaviorSubject<String>.seeded(_searchQuery);

  void queryAdd(String query) {
    onQuery.add(_searchQuery + query);
    _searchQuery += query;
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
                      child: Container(),
                    ),
                  ]);
            }),
      ),
    );
  }
}
