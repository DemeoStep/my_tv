import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'search.dart';

class Menu extends StatelessWidget {
  final rezka;
  final searchResult;
  var http;
  static int index = -1;

  static BehaviorSubject<int> onIndex = BehaviorSubject<int>.seeded(index);

  Menu({required this.rezka, required this.searchResult, required this.http});

  void indexChange(int newIndex, BuildContext context) {

    searchResult.selectFilm(index: -1);
    onIndex.add(newIndex);
    index = newIndex;
    switch (newIndex) {
      case 0:
        {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Search('', rezka, http, false)));
          break;
        }
      case 1:
        {
          rezka.showNew(searchResult);
          break;
        }
      case 2:
        {
          rezka.showType(
              result: searchResult, type: 'films', filter: 'filter=last');
          break;
        }
      case 3:
        {
          rezka.showType(
              result: searchResult, type: 'films', filter: 'filter=popular');
          break;
        }
      case 4:
        {
          rezka.showType(
              result: searchResult, type: 'films', filter: 'filter=watching');
          break;
        }
      case 5:
        {
          rezka.showType(
              result: searchResult, type: 'series', filter: 'filter=last');
          break;
        }
      case 6:
        {
          rezka.showType(
              result: searchResult, type: 'series', filter: 'filter=popular');
          break;
        }
      case 7:
        {
          rezka.showType(
              result: searchResult, type: 'series', filter: 'filter=watching');
          break;
        }
      case 8:
        {
          rezka.showType(
              result: searchResult, type: 'cartoons', filter: 'filter=last');
          break;
        }
      case 9:
        {
          rezka.showType(
              result: searchResult, type: 'cartoons', filter: 'filter=popular');
          break;
        }
      case 10:
        {
          rezka.showType(
              result: searchResult,
              type: 'cartoons',
              filter: 'filter=watching');
          break;
        }
      default:
        {
          rezka.showNew(searchResult);
        }
    }
  }

  Widget category(String category) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          Text(
            category,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.left,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(5),
              height: 1,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Button(text: 'Поиск', index: 0, context: context),
        Button(text: 'Новинки каталога', index: 1, context: context),
        category('Фильмы'),
        Button(text: 'Новинки каталога', index: 2, context: context),
        Button(text: 'Популярные', index: 3, context: context),
        Button(text: 'Сейчас смотрят', index: 4, context: context),
        category('Сериалы'),
        Button(text: 'Новинки каталога', index: 5, context: context),
        Button(text: 'Популярные', index: 6, context: context),
        Button(text: 'Сейчас смотрят', index: 7, context: context),
        category('Мультфильмы'),
        Button(text: 'Новинки каталога', index: 8, context: context),
        Button(text: 'Популярные', index: 9, context: context),
        Button(text: 'Сейчас смотрят', index: 10, context: context),
      ],
    );
  }

  Widget Button(
      {required String text,
      required int index,
      required BuildContext context}) {
    return Expanded(
      child: Container(
        child: OutlinedButton(
          autofocus: index == 0 ? true : false,
          style: OutlinedButton.styleFrom(
            primary: Colors.cyanAccent,
            elevation: 0,
            side: BorderSide.none,
          ),
          onPressed: () {
            indexChange(index, context);
          },
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            alignment: Alignment.centerLeft,
            width: double.infinity,
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
