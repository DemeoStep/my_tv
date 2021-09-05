import 'package:rxdart/rxdart.dart';

class Episode{
  String _episode = '';

  Episode({required String episode}) {
    this._episode = episode;
  }

  String get episode => _episode;
}