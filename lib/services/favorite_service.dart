import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie_model.dart';
import '../models/tv_model.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<void> addToFavorites(dynamic item, String type) async {
    if (_currentUserId == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      Map<String, dynamic> favoriteData;

      if (type == 'movie' && item is Movie) {
        favoriteData = {
          'id': item.id,
          'title': item.title,
          'posterPath': item.posterPath,
          'voteAverage': item.voteAverage,
          'releaseDate': item.releaseDate,
          'overview': item.overview,
          'type': 'movie',
          'addedAt': FieldValue.serverTimestamp(),
        };
      } else if (type == 'tv' && item is TvSeries) {
        favoriteData = {
          'id': item.id,
          'title': item.name,
          'posterPath': item.posterPath,
          'voteAverage': item.voteAverage,
          'releaseDate': item.firstAirDate,
          'overview': item.overview,
          'type': 'tv',
          'addedAt': FieldValue.serverTimestamp(),
        };
      } else {
        throw Exception('Type invalide');
      }

      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorites')
          .doc(favoriteData['id'].toString())
          .set(favoriteData);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout aux favoris: ${e.toString()}');
    }
  }

  Future<void> removeFromFavorites(int movieId) async {
    if (_currentUserId == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorites')
          .doc(movieId.toString())
          .delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du favori: ${e.toString()}');
    }
  }

  Future<bool> isFavorite(int movieId) async {
    if (_currentUserId == null) {
      return false;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorites')
          .doc(movieId.toString())
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> getFavoritesStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    if (_currentUserId == null) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des favoris: ${e.toString()}');
    }
  }
}
