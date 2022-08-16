import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nuesapp/news_ui/news_screen.dart';
import '../model/source_dto.dart';
import '../repository/repo.dart';
import '../ui_widgets/custom_shimmer.dart';

class SourceScreen extends StatefulWidget {
  const SourceScreen({Key? key}) : super(key: key);

  @override
  State<SourceScreen> createState() => _SourceScreenState();
}

class _SourceScreenState extends State<SourceScreen> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Neus app"),
      ),
      body: Stack(children: [
        Column(
          children: [
            const Text(
              "Sources",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: height * 0.83,
              child: FutureBuilder<List<SourceDTO>>(
                future: fetchSources(http.Client()),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("${snapshot.error}"),
                    );
                  } else if (snapshot.hasData) {
                    return SourceList(sources: snapshot.data!);
                  } else {
                    return const Center(
                      // child: CircularProgressIndicator(),
                      child: CustomShimmer(
                        shimmerText: 'Fetching sources...',
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: _SourceListState.indexList,
          builder:
              (BuildContext context, Map<int, String> indexMap, Widget? child) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8.0, right: 8.0),
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: _SourceListState.indexList.value.isNotEmpty
                      ? FloatingActionButton(
                          child: const Icon(Icons.navigate_next),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsScreen(
                                    source: getSourceIdsForAPI(),
                                  ),
                                ));
                          })
                      : null),
            );
          },
        )
      ]),
    );
    ;
  }

  String getSourceIdsForAPI() {
    String finalId = "";
    _SourceListState.indexList.value.values.forEach((element) {
      finalId += "$element,";
    });
    return finalId.substring(0, finalId.length - 1);
  }
}

class SourceList extends StatefulWidget {
  const SourceList({super.key, required this.sources});

  final List<SourceDTO> sources;

  @override
  State<SourceList> createState() => _SourceListState();
}

class _SourceListState extends State<SourceList> {
  static ValueNotifier<Map<int, String>> indexList = ValueNotifier({});

  void checkIfIndexListContains(int index, String id) {
    Map<int, String> tempList = {};

    setState(() {
      if (indexList.value.containsKey(index)) {
        indexList.value.remove(index);
        tempList = indexList.value;
        indexList.value = {};
        indexList.value = tempList;
      } else {
        indexList.value[index] = id;
        tempList = indexList.value;
        indexList.value = {};
        indexList.value = tempList;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 1.7),
      itemCount: widget.sources.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            checkIfIndexListContains(index, widget.sources[index].id!);
          },
          child: Card(
            shadowColor: Colors.blue,
            margin: const EdgeInsets.all(8),
            elevation: 4,
            child: Container(
              height: height * 0.05,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Text(
                          "${widget.sources[index].name}",
                          maxLines: 3,
                          style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Expanded(flex: 1, child: SizedBox()),
                      if (indexList.value.containsKey(index))
                        const Expanded(
                            flex: 2,
                            child: Icon(Icons.check, color: Colors.blueAccent))
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
