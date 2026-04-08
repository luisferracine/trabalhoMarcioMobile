import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';
import '../models/country_detail.dart';

class CountriesService {
  static const _baseUrl = 'https://restcountries.com/v3.1';

  Future<List<Country>> fetchAll() async {
    final uri = Uri.parse(
      '$_baseUrl/all?fields=name,flags,region,capital,population,cca2',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) return [];
    final List<dynamic> data = json.decode(response.body);
    final countries = data
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList();
    countries.sort((a, b) => a.common.compareTo(b.common));
    return countries;
  }

  Future<CountryDetail?> fetchByCode(String code) async {
    final uri = Uri.parse('$_baseUrl/alpha/${Uri.encodeComponent(code)}');
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;
    final dynamic data = json.decode(response.body);
    final Map<String, dynamic> raw = data is List ? data[0] : data;
    return CountryDetail.fromJson(raw);
  }
}
