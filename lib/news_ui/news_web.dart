import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class CustomWebView extends StatelessWidget {
  final String url;
  const CustomWebView({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProgressDialog pd = ProgressDialog(context: context);

    return SafeArea(
      child: Scaffold(
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: url,
          onPageStarted: (String url) {
            pd.close();
          },
          onWebViewCreated: (WebViewController webViewController) {
            pd.show(max: 100, msg: 'Loading...');
          },
          onPageFinished: (String url) {
            pd.close();
          },
          onProgress: (int num) {
            if (num < 15) pd.show(max: 100, msg: 'Loading...');
          },
        ),
      ),
    );
  }
}
