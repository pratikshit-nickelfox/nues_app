import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nuesapp/model/news_dto.dart';

import '../model/source_dto.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

const String API_KEY = "1be96847557b499f828cb832f9b3196e";

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

Future<List<NewsDTO>> fetchNews(http.Client client, String source) async {
  final response = await client.get(Uri.parse(
      "https://newsapi.org/v2/top-headlines?sources=$source&apiKey=$API_KEY"));

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseNews, response.body);
}

// A function that converts a response body into a List<Photo>.
List<NewsDTO> parseNews(String responseBody) {
  final parsed = jsonDecode(responseBody);

  List<NewsDTO> _newsList = [];

  for (var item in parsed["articles"]) {
    NewsDTO _news = NewsDTO.fromJson(item);
    _newsList.add(_news);
  }

  return _newsList;
}
