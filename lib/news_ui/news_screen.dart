import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:nuesapp/news_ui/news_web.dart';
import 'package:nuesapp/repository/repo.dart';
import 'package:http/http.dart' as http;
import '../model/news_dto.dart';
import '../ui_widgets/custom_shimmer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
          const SizedBox(height: 10),
          Container(
            height: height * 0.83,
            child: FutureBuilder<List<NewsDTO>>(
              future: NewsRepo.fetchNews(http.Client(), source)
                  .then((value) => value.keys.first),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("${snapshot.error}"),
                  );
                } else if (snapshot.hasData) {
                  return NewsList(news: snapshot.data!, source: source);
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

class NewsList extends StatefulWidget {
  NewsList({super.key, required this.news, required this.source});

  List<NewsDTO> news;
  final String source;

  @override
  State<NewsList> createState() => _NewsListState(news: news, source: source);
}

class _NewsListState extends State<NewsList> {
  final RefreshController refreshController = RefreshController();

  @override
  dispose() {
    news = [];
    source = "";
    NewsRepo.currentPage = 0;
    NewsRepo.isLastPage = false;
    NewsRepo.totalPages = 0;
    NewsRepo.newsList = [];
    super.dispose();
  }

  List<NewsDTO> news;
  String source;

  _NewsListState({required this.news, required this.source});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return SmartRefresher(
      enablePullUp: true,
      onLoading: () async {
        final Map<List<NewsDTO>, bool> listAndItem =
            await NewsRepo.fetchNews(http.Client(), widget.source);

        setState(() {
          news = listAndItem.keys.first;
          if (listAndItem.values.first == false)
            refreshController.loadComplete();
          else
            refreshController.loadNoData();
        });
      },
      controller: refreshController,
      child: ListView.builder(
        itemCount: news.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomWebView(url: news[index].url!),
                  ));
            },
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
                        alignment: Alignment.topCenter,
                        child: Blur(
                          blur: 2.5,
                          child: SizedBox(
                            height: 15,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.only(left: 8),
                          height: 15,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.blueGrey.withOpacity(0.5),
                                  Colors.lightBlue.withOpacity(0.4),
                                  Colors.transparent.withOpacity(0.2)
                                ]),
                          ),
                          child: Text(
                            "Source : ${news[index].source?.name}",
                            style: const TextStyle(
                                decorationStyle: TextDecorationStyle.solid,
                                color: Colors.white,
                                fontStyle: FontStyle.italic),
                          ),
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
                        alignment: Alignment.bottomLeft,
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
      ),
    );
  }
}
