import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';
import '../models/tv_model.dart';
import '../models/video_model.dart';

class TmdbApiService {
  static const String _apiKey = '3416ce8f0be4da5df6db860212c70425';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _language = 'fr-FR';

  // Fetch popular movies
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movie/popular?api_key=$_apiKey&language=$_language&page=$page',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }

  // Fetch popular TV series
  Future<List<TvSeries>> getPopularTvSeries({int page = 1}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/tv/popular?api_key=$_apiKey&language=$_language&page=$page',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => TvSeries.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load TV series: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching TV series: $e');
    }
  }

  // Get movie details
  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=$_language',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Movie.fromJson(data);
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movie details: $e');
    }
  }

  // Get TV series details
  Future<TvSeries> getTvSeriesDetails(int tvId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/tv/$tvId?api_key=$_apiKey&language=$_language',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TvSeries.fromJson(data);
      } else {
        throw Exception('Failed to load TV series details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching TV series details: $e');
    }
  }

  // Search movies
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.isEmpty) return [];
    
    try {
      final url = Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&language=$_language&query=$query&page=$page',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching movies: $e');
    }
  }

  // Search TV series
  Future<List<TvSeries>> searchTvSeries(String query, {int page = 1}) async {
    if (query.isEmpty) return [];
    
    try {
      final url = Uri.parse(
        '$_baseUrl/search/tv?api_key=$_apiKey&language=$_language&query=$query&page=$page',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => TvSeries.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search TV series: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching TV series: $e');
    }
  }

  // Get movie trailer
  Future<String?> getMovieTrailer(int movieId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey&language=en-US',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        if (results.isEmpty) return null;
        
        final videos = results.map((json) => Video.fromJson(json)).toList();
        
        final youtubeTrailers = videos.where((v) => v.isYouTubeTrailer).toList();
        
        if (youtubeTrailers.isNotEmpty) {
          return youtubeTrailers.first.key;
        }
        
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get TV series trailer
  Future<String?> getTvSeriesTrailer(int tvId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/tv/$tvId/videos?api_key=$_apiKey&language=en-US',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        if (results.isEmpty) return null;
        
        final videos = results.map((json) => Video.fromJson(json)).toList();
        
        final youtubeTrailers = videos.where((v) => v.isYouTubeTrailer).toList();
        
        if (youtubeTrailers.isNotEmpty) {
          return youtubeTrailers.first.key;
        }
        
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
