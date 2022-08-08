import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nuesapp/news_ui/news_screen.dart';
import 'package:nuesapp/news_ui/source_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(statusBarColor: Colors.blue),
            child: SafeArea(child: SourceScreen())),
      ),
    );
  }
}
