import 'dart:convert';
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
  String author;
  String description;
  String urlToImage;
  String publshedAt;
  String content;
  String articleUrl;

  Article(
      {this.title,
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
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Latest News'),
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

  Future<void> getNews() async {
    List<Article> news = [];
    String url =
        "https://newsapi.org/v2/top-headlines?country=in&category=business&apiKey=${apiKey}";

    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);

    if (jsonData['status'] == "ok") {
      jsonData["articles"].forEach((element) {
        if (element['urlToImage'] != null && element['description'] != null) {
          Article article = Article(
            title: element['title'],
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
        body: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10.0),
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 30.0),
              ),
            ),
            FutureBuilder(
                future: getNews(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Text('Loading....');
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
                                publshedAt: news[index].publshedAt ?? ""),
                          ),
                        );
                      }
                  }
                })
          ],
        ),
      ),
    );
  }
}

class NewsTile extends StatelessWidget {
  final String imgUrl, title, url, publshedAt;

  NewsTile({this.imgUrl, this.title, this.url, this.publshedAt});

  void _launchURL() async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: InkWell(
        onTap: _launchURL,
        child: Stack(
          children: [
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: CachedNetworkImage(
                  imageUrl: imgUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              height: 160.0,
              width: MediaQuery.of(context).size.width,
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
                        top: Radius.circular(0.0),
                        bottom: Radius.circular(5.0)),
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
                    style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.white,
                    )),
              ),
              bottom: 0.0,
            )
          ],
        ),
      ),
    );
  }
}
