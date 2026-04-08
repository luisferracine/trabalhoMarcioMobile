import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/country.dart';

/// Gerencia os países favoritos do usuário usando Firebase Auth anônimo
/// e Cloud Firestore.
///
/// Estrutura no Firestore:
///   users/{uid}/favorites/{countryCode}  →  dados do país
class FavoritesService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /// Garante que o usuário está autenticado anonimamente.
  Future<void> ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('favorites');
  }

  /// Retorna os códigos (ex: "BR", "US") dos países favoritados.
  Future<Set<String>> loadFavoriteCodes() async {
    await ensureSignedIn();
    final col = _collection;
    if (col == null) return {};
    final snapshot = await col.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  /// Retorna a lista completa de países favoritados.
  Future<List<Country>> loadFavoriteCountries() async {
    await ensureSignedIn();
    final col = _collection;
    if (col == null) return [];
    final snapshot = await col.get();
    return snapshot.docs.map((doc) => Country.fromMap(doc.data())).toList();
  }

  /// Adiciona um país aos favoritos.
  Future<void> addFavorite(Country country) async {
    await ensureSignedIn();
    await _collection?.doc(country.code).set(country.toMap());
  }

  /// Remove um país dos favoritos pelo código.
  Future<void> removeFavorite(String code) async {
    await ensureSignedIn();
    await _collection?.doc(code).delete();
  }
}
