import 'package:rxdart/rxdart.dart';

class Film {
  String _name;
  int _year;
  String _country;
  List<String> _genres;
  String _url;
  String _poster;
  String _type;
  String _description;
  String _rate;
  bool _loaded = false;
  String _hls;
  String _mp4;

  BehaviorSubject<String> onDescr;
  BehaviorSubject<bool> onLoad;

  Film(
      this._name,
      this._year,
      this._country,
      this._genres,
      this._url,
      this._poster,
      this._type,
      this._description,
      this._rate,
      this._hls,
      this._mp4,
      this._loaded)
      : onDescr = BehaviorSubject<String>.seeded(_description),
        onLoad = BehaviorSubject<bool>.seeded(_loaded);

  Film.newFilm() : this('', 0, '', [], '', '', '', '', '', '', '', false);

  String get name => _name;
  int get year => _year;
  String get country => _country;
  List<String> get genres => _genres;
  String get url => _url;
  String get poster => _poster;
  String get type => _type;
  String get description => _description;
  String get rate => _rate;
  String get hls => _hls;
  String get mp4 => _mp4;

  void descriptionChange(String description) {
    onDescr.add(description);
    _description = description;
  }

  void isLoaded(bool loaded) {
    onLoad.add(loaded);
    _loaded = loaded;
  }

  void setName(String value) {
    _name = value;
  }

  void setYear(int value) {
    _year = value;
  }

  void setCountry(String value) {
    _country = value;
  }

  void setGenre(List genres) {
    for (var item in genres) {
      _genres.add(item.toString());
    }
  }

  void setUrl(String value) {
    _url = value;
  }

  void setPoster(String poster) {
    _poster = poster;
  }

  void setType(String type) {
    _type = type;
  }

  void setRate(String rate) {
    _rate = rate;
  }

  void setDescr(String descr) {
    _description = descr;
  }

  void setHls(String hls) {
    _hls = hls;
  }

  void setMp4(String mp4) {
    _mp4 = mp4;
  }
}
