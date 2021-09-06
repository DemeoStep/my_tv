import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'search.dart';

class Keyboard extends StatelessWidget {
  Search searchQuery;
  int type = 0;

  BehaviorSubject<int> onKeyboard;

  Keyboard(this.searchQuery, this.type)
      : onKeyboard = BehaviorSubject<int>.seeded(type);

  void onKeyboardChange(int type) {
    this.type = type;
    onKeyboard.add(type);
  }

  var cyrKeys = [
    'А',
    'Б',
    'В',
    'Г',
    'Д',
    'Е',
    'Ё',
    'Є',
    'Ж',
    'З',
    'И',
    'І',
    'Ї',
    'Й',
    'К',
    'Л',
    'М',
    'Н',
    'О',
    'П',
    'Р',
    'С',
    'Т',
    'У',
    'Ф',
    'Х',
    'Ц',
    'Ч',
    'Ш',
    'Щ',
    'Ъ',
    'Ы',
    'Ь',
    'Э',
    'Ю',
    'Я',
  ];

  var engKeys = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  var symbolKeys = [
    '1', '2', '3', '4', '5', '&', '#', '(', ')',
    '6', '7', '8', '9', '0', '@', '!', '?', ':',
    ',', '.', '_', '-', '+', '=', '/', '"', '\'',
    '\$', '%', '*',
  ];

  Widget button(String text) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        side: BorderSide.none,
      ),
      onPressed: () {
        searchQuery.queryAdd(text, false);
      },
      child: Text(
        text,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var keyTypes = [
      cyrKeys,
      engKeys,
      symbolKeys
    ];

    return StreamBuilder<int>(
        stream: onKeyboard,
        builder: (context, snapshot) {
          var keys = keyTypes[snapshot.data ?? 0];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.only(top: 5),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              //childAspectRatio: 0.57,
                              crossAxisCount: 9,
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 5,
                            ),
                            itemCount: keys.length,
                            itemBuilder: (context, index) {
                              return Container(
                                alignment: Alignment.center,
                                child: button(keys[index]),
                              );
                            },
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          IconButton(
                            icon: Text(
                              '?#1', style: TextStyle(
                              color: Colors.white,
                              ),
                            ),
                            splashRadius: 20,
                            iconSize: 20,
                            onPressed: () {
                              onKeyboardChange(2);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.backspace_rounded,
                              color: Colors.white,
                            ),
                            splashRadius: 20,
                            iconSize: 20,
                            onPressed: () {
                              searchQuery.queryBackspace();
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.language,
                              color: Colors.white,
                            ),
                            splashRadius: 20,
                            iconSize: 20,
                            onPressed: () {
                              onKeyboardChange(
                                  type == 2
                                      ? 0
                                      : type == 1 ? 0 : 1);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.space_bar,
                              color: Colors.white,
                            ),
                            splashRadius: 20,
                            iconSize: 20,
                            onPressed: () {
                              searchQuery.queryAdd(' ', false);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
}
