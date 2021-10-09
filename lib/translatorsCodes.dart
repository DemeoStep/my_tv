Map<String, String> codes = {
  'LostFilm': '1',
  'алексфильм (AlexFilm)': '4',
  'Кубик в Кубе (Kubik³)': '6',
  'байбако (BaibaKoTV)': '7',
  'Амедиа (Amedia)': '12',
  'AniDUB': '18',
  'Anilibria': '19',
  'Discovery': '22',
  'GREEN TEA': '29',
  'колдфильм (Coldfilm)': '35',
  'озз (Ozz)' : '40',
  'Двухголосый закадровый': '55',
  'Дубляж': '56',
  'Многолосый закадровый': '59',
  'Одноголосый закадровый': '62',
  'Оригинал' : '65',
  'Novamedia': '73',
  'СТС': '84',
  'Paramount Comedy': '87',
  'Украинский': '99',
  'Не нужен': '110',
  'HDrezka Studio': '111',
  'SoftBox': '114',
  'TVShows': '232',
  'AniMaunt': '235',
  'Оригинал (+субтитры)': '238',
  'Колобок' : '242',
  'Карцев': '254',
  'HighHopes': '261',
  'AniFilm': '288',
  'октопус (Octopus/Ultradox)': '316',
  'Мобильное телевидение': '349',
  'Любительский': '354',
  'Украинский дубляж ': '358',
  'AlphaProject' : '374',
  'НеЗупиняйПродакшн ': '377',
  'Force Media':'410',
  'Белорусский многоголосый': '432'
};

String getCode(String name) {
  var result;

  for (var str in codes.entries) {
    if (str.key == name) {
      result = str.value;
    }
  }
  return result;
}

String getName(String code) {
  var result;

  for (var str in codes.entries) {
    if (str.value == code) {
      result = str.key;
    }
  }
  return result;
}
