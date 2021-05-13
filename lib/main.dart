import 'dart:convert';
import 'dart:ffi';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

String apiKey = "5e86616ada44464f81d1f8dd60b26a4d";

void main() {
  runApp(MyApp());
}

class Article {
  String title;
  String source;
  String author;
  String description;
  String urlToImage;
  String publshedAt;
  String content;
  String articleUrl;

  Article(
      {this.title,
      this.source,
      this.description,
      this.author,
      this.content,
      this.publshedAt,
      this.urlToImage,
      this.articleUrl});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'News'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String formatDate(DateTime date) => new DateFormat("MMMM d").format(date);
  List<String> categories = [
    "business",
    "entertainment",
    "general",
    "health",
    "science",
    "sports",
    "technology"
  ];

  int cat = 0;

  Future<void> getNews() async {
    List<Article> news = [];
    String url =
        "https://newsapi.org/v2/top-headlines?country=in&category=${categories[cat]}&apiKey=${apiKey}";

    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);

    // print(jsonData);

    if (jsonData['status'] == "ok") {
      jsonData["articles"].forEach((element) {
        if (element['urlToImage'] != null && element['description'] != null) {
          Article article = Article(
            title: element['title'],
            source: element['source']['name'],
            author: element['author'],
            description: element['description'],
            urlToImage: element['urlToImage'],
            publshedAt: formatDate(DateTime.parse(element['publishedAt'])),
            content: element["content"],
            articleUrl: element["url"],
          );
          news.add(article);
        }
      });
    }
    return news;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.deepPurple[50],
        body: RefreshIndicator(
          onRefresh: getNews,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10.0),
                child: Text(
                  categories[cat][0].toUpperCase() +
                      categories[cat].substring(1) +
                      " News",
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  children: List.generate(
                      categories.length,
                      (index) => TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  index == cat
                                      ? Colors.purple[100]
                                      : Colors.transparent)),
                          onPressed: () {
                            setState(() {
                              cat = index;
                            });
                          },
                          child: Text(categories[index][0].toUpperCase() +
                              categories[index].substring(1)))),
                ),
              ),
              FutureBuilder(
                  future: getNews(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Expanded(
                            child: Center(child: CircularProgressIndicator()));
                      default:
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List news = snapshot.data;
                          return Expanded(
                            child: ListView.builder(
                              itemCount: news.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) => NewsTile(
                                imgUrl: news[index].urlToImage ?? "",
                                title: news[index].title ?? "",
                                url: news[index].articleUrl ?? "",
                                publshedAt: news[index].publshedAt ?? "",
                                source: news[index].source ?? "",
                              ),
                            ),
                          );
                        }
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class NewsTile extends StatelessWidget {
  final String imgUrl, title, url, publshedAt, source;

  NewsTile({this.imgUrl, this.title, this.url, this.publshedAt, this.source});

  void _launchURL() async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: Stack(
        children: [
          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                child: CachedNetworkImage(
                  filterQuality: FilterQuality.medium,
                  fadeInCurve: Curves.easeIn,
                  imageUrl: imgUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            height: 160.0,
            width: MediaQuery.of(context).size.width,
          ),
          Positioned(
            child: Container(
              decoration: BoxDecoration(color: Colors.black26),
              padding: EdgeInsets.all(5.0),
              child: Text(source,
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.white,
                  )),
            ),
            top: 0,
            left: 0,
          ),
          Positioned(
            child: Container(
              decoration: BoxDecoration(color: Colors.black26),
              padding: EdgeInsets.all(5.0),
              child: Text(publshedAt,
                  style: TextStyle(
                    fontSize: 8.0,
                    color: Colors.white,
                  )),
            ),
            top: 0,
            right: 0,
          ),
          Positioned(
            child: Container(
              width: MediaQuery.of(context).size.width - 20.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(0.0), bottom: Radius.circular(5.0)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: const FractionalOffset(0.5, 0.0),
                    end: const FractionalOffset(0.5, 1.0),
                  )),
              padding: EdgeInsets.all(5.0),
              child: Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.0,
                    color: Colors.white,
                  )),
            ),
            bottom: 0.0,
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: _launchURL,
              ),
            ),
          )
        ],
      ),
    );
  }
}
