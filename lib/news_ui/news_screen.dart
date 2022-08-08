import 'dart:ui';
import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:nuesapp/repository/repo.dart';
import 'package:http/http.dart' as http;
import '../model/news_dto.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ui_widgets/custom_shimmer.dart';

class NewsScreen extends StatefulWidget {
  final String source;
  const NewsScreen({Key? key, required this.source}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState(source);
}

class _NewsScreenState extends State<NewsScreen> {
  final String source;

  _NewsScreenState(this.source);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Neus app"),
      ),
      body: Column(
        children: [
          const Text(
            "News",
            style: TextStyle(
                color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            height: height * 0.80,
            child: FutureBuilder<List<NewsDTO>>(
              future: fetchNews(http.Client(), source),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("${snapshot.error}"),
                  );
                } else if (snapshot.hasData) {
                  return NewsList(news: snapshot.data!);
                } else {
                  return const Center(
                      // child: CircularProgressIndicator(),
                      child: SizedBox(
                    width: 200.0,
                    height: 100.0,
                    child: CustomShimmer(
                      shimmerText: 'Loading news...',
                    ),
                  ));
                }
              },
            ),
          ),
        ],
      ),
    );
    ;
  }
}

class NewsList extends StatelessWidget {
  const NewsList({super.key, required this.news});

  final List<NewsDTO> news;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return ListView.builder(
      itemCount: news.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _launchURL(news[index].url!),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
            shadowColor: Colors.blue,
            margin: EdgeInsets.all(8),
            elevation: 4,
            child: Container(
              height: 220,
              child: Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Container(
                      child: FadeInImage.assetNetwork(
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/images/not_found.png'),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        image: "${news[index].urlToImage}",
                        placeholder: 'assets/images/loading.gif',
                      ),
                    ),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: Blur(
                        blur: 2.5,
                        child: SizedBox(
                          height: 85,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding:
                            const EdgeInsets.only(left: 8, right: 8, top: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.blue.withOpacity(0.5),
                                Colors.lightBlue.withOpacity(0.7),
                                Colors.blueGrey.withOpacity(0.7)
                              ]),
                        ),
                        height: 85,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text(
                              overflow: TextOverflow.ellipsis,
                              "${news[index].title}",
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              "${news[index].description}",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
