import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'search.dart';

class Keyboard extends StatelessWidget {
  Search searchQuery;
  bool isCyr = true;
  static bool? cyr = true;

  BehaviorSubject<bool> onKeyboard;

  Keyboard(this.searchQuery, this.isCyr) : onKeyboard = BehaviorSubject<bool>.seeded(isCyr);

  void onKeyboardChange() {
    isCyr = !isCyr;
    onKeyboard.add(isCyr);
    cyr = isCyr;
  }

  var cyrKeys = [
    'а',
    'б',
    'в',
    'г',
    'д',
    'е',
    'ё',
    'є',
    'ж',
    'з',
    'и',
    'і',
    'ї',
    'й',
    'к',
    'л',
    'м',
    'н',
    'о',
    'п',
    'р',
    'с',
    'т',
    'у',
    'ф',
    'х',
    'ц',
    'ч',
    'ш',
    'щ',
    'ъ',
    'ы',
    'ь',
    'э',
    'ю',
    'я',
  ];

  var engKeys = [
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
  ];

  Widget button(String text) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        side: BorderSide.none,
      ),
      onPressed: () {
        searchQuery.queryAdd(text);
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
    return StreamBuilder<bool>(
      stream: onKeyboard,
      builder: (context, snapshot) {
        var keys = isCyr ? cyrKeys : engKeys;
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
                          icon: Icon(
                            Icons.keyboard_voice,
                            color: Colors.white,
                          ),
                          splashRadius: 20,
                          iconSize: 20,
                          onPressed: () {},
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
                            onKeyboardChange();
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
                            searchQuery.queryAdd(' ');
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
      }
    );
  }
}
