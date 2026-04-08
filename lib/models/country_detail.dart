import 'country.dart';

class CountryDetail extends Country {
  final String? subregion;
  final double? area;
  final List<String> timezones;
  final List<String> continents;
  final List<String> tld;
  final String? mapUrl;
  final String? fifa;
  final String? carSide;
  final String? startOfWeek;
  final List<String> languages;
  final List<String> currencies;
  final bool? independent;
  final bool? unMember;

  const CountryDetail({
    required super.common,
    required super.official,
    required super.flagUrl,
    required super.flagAlt,
    required super.region,
    required super.capital,
    super.population,
    required super.code,
    this.subregion,
    this.area,
    this.timezones = const [],
    this.continents = const [],
    this.tld = const [],
    this.mapUrl,
    this.fifa,
    this.carSide,
    this.startOfWeek,
    this.languages = const [],
    this.currencies = const [],
    this.independent,
    this.unMember,
  });

  factory CountryDetail.fromJson(Map<String, dynamic> json) {
    final currencyList = <String>[];
    final currenciesJson = json['currencies'] as Map<String, dynamic>?;
    if (currenciesJson != null) {
      for (final entry in currenciesJson.values) {
        if (entry is Map && entry['name'] != null) {
          currencyList.add(entry['name'].toString());
        }
      }
    }

    final languageList = <String>[];
    final languagesJson = json['languages'] as Map<String, dynamic>?;
    if (languagesJson != null) {
      languageList.addAll(languagesJson.values.map((v) => v.toString()));
    }

    return CountryDetail(
      common: json['name']?['common'] as String? ?? 'Sem nome',
      official: json['name']?['official'] as String? ?? 'Sem nome oficial',
      flagUrl: json['flags']?['png'] as String? ?? '',
      flagAlt: json['flags']?['alt'] as String? ?? 'Bandeira',
      region: json['region'] as String? ?? 'Região não informada',
      capital: (json['capital'] as List?)?.cast<String>().join(', ') ??
          'Capital não informada',
      population: json['population'] as int?,
      code: json['cca2'] as String? ?? '--',
      subregion: json['subregion'] as String?,
      area: (json['area'] as num?)?.toDouble(),
      timezones: List<String>.from((json['timezones'] as List?) ?? []),
      continents: List<String>.from((json['continents'] as List?) ?? []),
      tld: List<String>.from((json['tld'] as List?) ?? []),
      mapUrl: json['maps']?['googleMaps'] as String?,
      fifa: json['fifa'] as String?,
      carSide: json['car']?['side'] as String?,
      startOfWeek: json['startOfWeek'] as String?,
      languages: languageList,
      currencies: currencyList,
      independent: json['independent'] as bool?,
      unMember: json['unMember'] as bool?,
    );
  }
}
