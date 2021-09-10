import 'film.dart';
import 'package:rxdart/rxdart.dart';
import 'screens/menu.dart';

class SearchResultsList {
  List<Film> _list;
  var selected;

  BehaviorSubject<List<Film>> onFilmAdd;
  BehaviorSubject<int> onSelect;

  SearchResultsList(this._list, this.selected)
      : onFilmAdd = BehaviorSubject<List<Film>>.seeded(_list),
        onSelect = BehaviorSubject<int>.seeded(selected);

  SearchResultsList.newSearch() : this([], -1);

  List<Film> get list => _list;

  void filmAdd(Film film) {
    _list.add(film);
    onFilmAdd.add(_list);
  }

  void selectFilm({required int index}) {
    selected = index;
    onSelect.add(index);
    Menu.onIndex.add(-1);
  }
}
