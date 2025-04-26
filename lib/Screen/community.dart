import 'package:flutter/material.dart';
import 'package:glycosnap/Authenticate/nyt_api.dart';
import 'package:glycosnap/Authenticate/web_view.dart';
import 'package:glycosnap/Authenticate/nyt_articles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  int visit = 0;
  final SearchController controller = SearchController();
  static List<Article>? _cachedArticles;
  static DateTime? _lastFetchTime;
  static const Duration cacheDuration = Duration(hours: 1);

  Future<List<Article>> _getArticles() async {
    try {
      // If we have valid cached articles, return them immediately
      if (_cachedArticles != null && _lastFetchTime != null) {
        final now = DateTime.now();
        final timeSinceLastFetch = now.difference(_lastFetchTime!);
        if (timeSinceLastFetch < cacheDuration) {
          return _cachedArticles!;
        }
      }

      // If no cache or cache expired, fetch new articles
      final nyTimesService = NYTimesService();
      final articles = await Future.wait<List<Article>>([
        nyTimesService.fetchDiabetesArticles(),
        nyTimesService.fetchDietArticles(),
        nyTimesService.fetchBloodSugarArticles(),
      ]).then((List<List<Article>> results) {
        return results.expand((articles) => articles).toList();
      });

      // Update static cache
      _cachedArticles = articles;
      _lastFetchTime = DateTime.now();

      // Save to SharedPreferences as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_articles',
          jsonEncode(articles.map((a) => a.toJson()).toList()));
      await prefs.setString(
          'last_fetch_time', _lastFetchTime!.toIso8601String());

      return articles;
    } catch (e) {
      print('Error fetching articles: $e');
      // If there's an error, try to return cached articles if available
      if (_cachedArticles != null) {
        return _cachedArticles!;
      }
      rethrow;
    }
  }

  Future<void> _loadCachedArticles() async {
    try {
      // First try to load from static cache
      if (_cachedArticles != null && _lastFetchTime != null) {
        final now = DateTime.now();
        final timeSinceLastFetch = now.difference(_lastFetchTime!);
        if (timeSinceLastFetch < cacheDuration) {
          return;
        }
      }

      // If static cache is invalid, try to load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final cachedArticlesJson = prefs.getString('cached_articles');
      final lastFetchTimeStr = prefs.getString('last_fetch_time');

      if (cachedArticlesJson != null && lastFetchTimeStr != null) {
        final lastFetchTime = DateTime.parse(lastFetchTimeStr);
        final now = DateTime.now();
        final timeSinceLastFetch = now.difference(lastFetchTime);

        if (timeSinceLastFetch < cacheDuration) {
          final List<dynamic> articlesJson = jsonDecode(cachedArticlesJson);
          _cachedArticles =
              articlesJson.map((json) => Article.fromJson(json)).toList();
          _lastFetchTime = lastFetchTime;
        }
      }
    } catch (e) {
      print('Error loading cached articles: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCachedArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        toolbarHeight: 80,
        title: Container(
          child: Text(
            'Articles',
            style: TextStyle(
              fontFamily: 'PoppinsBold',
              fontSize: 26,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(
                Icons.bookmark,
                size: 35,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: 'See saved articles',
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: _getArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary));
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error.toString()}');
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No articles found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Article article = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    if (article.url.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewScreen(url: article.url),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('No full article available.')),
                      );
                    }
                  },
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.5)),
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    article.title,
                                    style: TextStyle(
                                      fontFamily: 'PoppinsBold',
                                      fontSize: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    article.description,
                                    style: TextStyle(
                                      fontFamily: 'OpenSauce',
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: Icon(
                                  Icons.bookmark_add_outlined,
                                  size: 25,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                tooltip: 'Save article',
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget buildSearchAnchor() {
    return SearchAnchor(
      viewElevation: 5,
      builder: (BuildContext context, SearchController controller) {
        return SizedBox(
          width: 370,
          child: SearchBar(
            controller: controller,
            hintText: 'Search article',
            hintStyle: WidgetStateProperty.all<TextStyle>(
              const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
                fontSize: 14.0,
              ),
            ),
            padding: WidgetStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 18.0),
            ),
            onTap: () {
              controller.openView();
            },
            onChanged: (_) {
              controller.openView();
            },
            leading: const Icon(Icons.search),
            backgroundColor: WidgetStateProperty.all<Color?>(
              Colors.white,
            ),
          ),
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        return List<ListTile>.generate(5, (int index) {
          final String item = 'item $index';
          return ListTile(
            title: Text(item),
            onTap: () {
              setState(() {
                controller.closeView(item);
              });
            },
          );
        });
      },
    );
  }
}
