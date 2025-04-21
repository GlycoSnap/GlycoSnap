import 'package:flutter/material.dart';
import 'package:glycosnap/Authenticate/nyt_api.dart';
import 'package:glycosnap/Authenticate/web_view.dart';
import 'package:glycosnap/Authenticate/nyt_articles.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  int visit = 0;
  final SearchController controller = SearchController();

  late Future<List<Article>> futureArticles;

  @override
  void initState() {
    super.initState();
    final nyTimesService = NYTimesService();

    futureArticles = Future.wait<List<Article>>([
      nyTimesService.fetchDiabetesArticles(),
      nyTimesService.fetchDietArticles(),
      nyTimesService.fetchBloodSugarArticles(),
    ]).then((List<List<Article>> results) {
      // Flatten the list of lists into a single list
      return results.expand((articles) => articles).toList();
    });
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
        future: futureArticles,
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
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context)
                          .colorScheme
                          .secondary.withValues(alpha: 0.)),
                    
                    padding: const EdgeInsets.only(right: 10),
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Category',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      article.title,
                                      style: TextStyle(
                                        fontFamily: 'PoppinsBold',
                                        fontSize: 17,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      article.description,
                                      style: TextStyle(
                                        fontFamily: 'OpenSauce',
                                        fontSize: 13,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
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
