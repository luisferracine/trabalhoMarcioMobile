class Country {
  final String common;
  final String official;
  final String flagUrl;
  final String flagAlt;
  final String region;
  final String capital;
  final int? population;
  final String code;

  const Country({
    required this.common,
    required this.official,
    required this.flagUrl,
    required this.flagAlt,
    required this.region,
    required this.capital,
    this.population,
    required this.code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      common: json['name']?['common'] as String? ?? 'Sem nome',
      official: json['name']?['official'] as String? ?? 'Sem nome oficial',
      flagUrl: json['flags']?['png'] as String? ?? '',
      flagAlt: json['flags']?['alt'] as String? ?? 'Bandeira',
      region: json['region'] as String? ?? 'Região não informada',
      capital: (json['capital'] as List?)?.cast<String>().join(', ') ??
          'Capital não informada',
      population: json['population'] as int?,
      code: json['cca2'] as String? ?? '--',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'common': common,
      'official': official,
      'flagUrl': flagUrl,
      'flagAlt': flagAlt,
      'region': region,
      'capital': capital,
      if (population != null) 'population': population,
      'code': code,
    };
  }

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      common: map['common'] as String? ?? '',
      official: map['official'] as String? ?? '',
      flagUrl: map['flagUrl'] as String? ?? '',
      flagAlt: map['flagAlt'] as String? ?? 'Bandeira',
      region: map['region'] as String? ?? '',
      capital: map['capital'] as String? ?? '',
      population: map['population'] as int?,
      code: map['code'] as String? ?? '--',
    );
  }
}
