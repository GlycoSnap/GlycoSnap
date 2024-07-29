import 'dart:convert';
import 'package:http/http.dart' as http;
import 'nyt_articles.dart';

class NYTimesService {
  final String apiKey = 'u0TZpumHU5jah390nkaAUfkdk5LQsVet';
  final String apiUrl = 'https://api.nytimes.com/svc/search/v2/articlesearch.json';

  Future<List<Article>> fetchArticles(String query) async {
  final response = await http.get(Uri.parse('$apiUrl?q=$query&api-key=$apiKey'));

  if (response.statusCode == 200) {
    print('Response body: ${response.body}');
    var data = json.decode(response.body);
    print('Data: $data'); // Print entire response data
    List<dynamic> articles = data['response']['docs'];
    print('Number of articles found: ${articles.length}');
    if (articles.isEmpty) {
      print('No articles found');
    }
    return articles.map((json) => Article.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load articles');
  }
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

