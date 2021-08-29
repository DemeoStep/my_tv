import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Keyboard extends StatelessWidget {
  Keyboard({Key? key}) : super(key: key);

  var cyrKeys = [
    'а',
    'б',
    'в',
    'г',
    'ґ',
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

  Widget button(String text) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        side: BorderSide.none,
      ),
      onPressed: () {},
      child: Text(
        text,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        crossAxisCount: 10,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                      ),
                      itemCount: cyrKeys.length,
                      itemBuilder: (context, index) {
                        return Container(
                          alignment: Alignment.center,
                          child: button(cyrKeys[index]),
                        );
                      },
                    ),
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      padding: EdgeInsets.all(0),
                      focusColor: Colors.blueGrey,
                      splashRadius: 16,
                      splashColor: Colors.greenAccent,
                      icon: Icon(
                        Icons.keyboard_voice,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      padding: EdgeInsets.all(0),
                      focusColor: Colors.blueGrey,
                      splashRadius: 16,
                      splashColor: Colors.greenAccent,
                      icon: Icon(
                        Icons.backspace_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      padding: EdgeInsets.all(0),
                      focusColor: Colors.blueGrey,
                      splashRadius: 16,
                      splashColor: Colors.greenAccent,
                      icon: Icon(
                        Icons.language,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: () {},
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
}
