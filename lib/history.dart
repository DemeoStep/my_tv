import 'dart:io';

import 'package:path_provider/path_provider.dart';

class History {
  static List<ViewedFilm> viewed = [];

  static void addFilm({required id}) {
    viewed.add(ViewedFilm(id: id));
    saveHistory();
  }

  static Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    print(path);
    return File('$path/history.txt');
  }

  static Future<File> saveHistory() async {
    final file = await _localFile;

    return file.writeAsString('$viewed');
  }

}

class ViewedFilm {
  var id;
  bool isViewed = false;
  List<List> seasons = [];

  ViewedFilm({required this.id});

  void addEpisode(int season, int episode) {
    seasons[season][episode] = true;
  }
}