import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nuesapp/model/news_dto.dart';

import '../model/source_dto.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

const String API_KEY = "e9bff569701b4d5d9ca20f8b195dd87f";
const int pageSize = 12;

Future<List<SourceDTO>> fetchSources(http.Client client) async {
  final response = await client.get(Uri.parse(
      "https://newsapi.org/v2/top-headlines/sources?apiKey=$API_KEY"));

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseSources, response.body);
}

// A function that converts a response body into a List<Photo>.
List<SourceDTO> parseSources(String responseBody) {
  final parsed = jsonDecode(responseBody);

  List<SourceDTO> _sourceList = [];

  for (var item in parsed["sources"]) {
    SourceDTO _source = SourceDTO.fromJson(item);
    _sourceList.add(_source);
  }

  return _sourceList;
}

class NewsRepo {
  static final NewsRepo _singleton = NewsRepo._internal();

  factory NewsRepo() {
    return _singleton;
  }

  NewsRepo._internal();

  static int currentPage = 0;
  static int totalPages = 0;
  static List<NewsDTO> newsList = [];
  static bool isLastPage = false;

  static Future<Map<List<NewsDTO>, bool>> fetchNews(
      http.Client client, String source) async {
    if (currentPage <= totalPages) {
      currentPage++;
      if (currentPage == totalPages) isLastPage = true;
    } else {
      isLastPage = true;
    }
    final response = await client.get(Uri.parse(
        "https://newsapi.org/v2/top-headlines?sources=$source&page=$currentPage&pageSize=$pageSize&apiKey=$API_KEY"));

    final parsed = jsonDecode(response.body);
    int totalResults = parsed['totalResults'] as int;

    if (totalPages == 0) {
      if (totalResults % pageSize == 0) {
        totalPages = totalResults ~/ pageSize;
      } else {
        totalPages = totalResults ~/ pageSize + 1;
      }
    }

    // Use the compute function to run parsePhotos in a separate isolate.

    newsList.addAll(await compute(parseNews, response.body));
    return {newsList: isLastPage};
  }

// A function that converts a response body into a List<Photo>.
  static List<NewsDTO> parseNews(String responseBody) {
    final parsed = jsonDecode(responseBody);

    List<NewsDTO> _newsList = [];

    for (var item in parsed["articles"]) {
      NewsDTO _news = NewsDTO.fromJson(item);
      _newsList.add(_news);
    }

    return _newsList;
  }
}
