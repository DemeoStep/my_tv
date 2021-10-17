import 'package:flutter/material.dart';
import 'package:my_tv/history.dart';
import 'package:rxdart/rxdart.dart';
import 'search.dart';

class Menu extends StatelessWidget {
  final rezka;
  final searchResult;
  final http;
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
          rezka.showHistory(
              result: searchResult,
              viewed: History.viewed);
          break;
        }
      case 3:
        {
          rezka.showType(
              result: searchResult, type: 'films', filter: 'filter=last');
          break;
        }
      case 4:
        {
          rezka.showType(
              result: searchResult, type: 'films', filter: 'filter=popular');
          break;
        }
      case 5:
        {
          rezka.showType(
              result: searchResult, type: 'films', filter: 'filter=watching');
          break;
        }
      case 6:
        {
          rezka.showType(
              result: searchResult, type: 'series', filter: 'filter=last');
          break;
        }
      case 7:
        {
          rezka.showType(
              result: searchResult, type: 'series', filter: 'filter=popular');
          break;
        }
      case 8:
        {
          rezka.showType(
              result: searchResult, type: 'series', filter: 'filter=watching');
          break;
        }
      case 9:
        {
          rezka.showType(
              result: searchResult, type: 'cartoons', filter: 'filter=last');
          break;
        }
      case 10:
        {
          rezka.showType(
              result: searchResult, type: 'cartoons', filter: 'filter=popular');
          break;
        }
      case 11:
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
        button(text: 'Поиск', index: 0, context: context),
        button(text: 'Новинки каталога', index: 1, context: context),
        button(text: 'История', index: 2, context: context),
        category('Фильмы'),
        button(text: 'Новинки каталога', index: 3, context: context),
        button(text: 'Популярные', index: 4, context: context),
        button(text: 'Сейчас смотрят', index: 5, context: context),
        category('Сериалы'),
        button(text: 'Новинки каталога', index: 6, context: context),
        button(text: 'Популярные', index: 7, context: context),
        button(text: 'Сейчас смотрят', index: 8, context: context),
        category('Мультфильмы'),
        button(text: 'Новинки каталога', index: 9, context: context),
        button(text: 'Популярные', index: 10, context: context),
        button(text: 'Сейчас смотрят', index: 11, context: context),
      ],
    );
  }

  Widget button(
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
