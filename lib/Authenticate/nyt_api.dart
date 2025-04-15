import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'nyt_articles.dart';

class NYTimesService {
  final String apiKey = 'u0TZpumHU5jah390nkaAUfkdk5LQsVet';
  final String apiUrl =
      'https://api.nytimes.com/svc/search/v2/articlesearch.json';

  // Cache for storing fetched articles
  final Map<String, List<Article>> _cache = {};
  final Duration _cacheDuration = const Duration(hours: 1);
  final Map<String, DateTime> _cacheTimestamps = {};

  Future<List<Article>> fetchArticles(String query) async {
    // Check cache first
    if (_isCacheValid(query)) {
      return _cache[query]!;
    }

    try {
      final uri = Uri.parse(
          '$apiUrl?q=$query&api-key=$apiKey&sort=newest&fl=headline,web_url,abstract,byline,pub_date');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['response']['docs'] as List<dynamic>;

        if (articles.isEmpty) {
          return [];
        }

        final result = articles.map((json) => Article.fromJson(json)).toList();

        // Update cache
        _cache[query] = result;
        _cacheTimestamps[query] = DateTime.now();

        return result;
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching articles: $e');
      // Return cached data if available, even if expired
      if (_cache.containsKey(query)) {
        return _cache[query]!;
      }
      rethrow;
    }
  }

  bool _isCacheValid(String query) {
    if (!_cache.containsKey(query) || !_cacheTimestamps.containsKey(query)) {
      return false;
    }

    final timestamp = _cacheTimestamps[query]!;
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  Future<List<Article>> fetchDiabetesArticles() async {
    return fetchArticles('diabetes management');
  }

  Future<List<Article>> fetchDietArticles() async {
    return fetchArticles('diet');
  }

  Future<List<Article>> fetchBloodSugarArticles() async {
    return fetchArticles('blood sugar');
  }
}
