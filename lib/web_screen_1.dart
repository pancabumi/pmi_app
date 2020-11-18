import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  WebViewScreen({Key key, this.title, this.url, this.isAdmin})
      : super(key: key);

  final String title;
  final String url;
  final bool isAdmin;

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(widget.title), _switchPageDialog(context)],
              ),
              leading: Image.asset('assets/iconset/32.png'),
            ),
            body: WebView(
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              gestureNavigationEnabled: true,
            )
        ),
        
        onWillPop: () async {
          final futureController = await _controller.future;
          if (await futureController.canGoBack()) {
            await futureController.goBack();
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Keluar dari Aplikasi'),
                    content: Text('Ingin keluar dari Aplikasi?'),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Batalkan')),
                      TextButton(
                          onPressed: () {
                            SystemNavigator.pop();
                          },
                          child: Text('Ya'))
                    ],
                  );
                });
          }
          return false;
        });
  }

  InkWell _switchPageDialog(BuildContext context) {
    return InkWell(
      child: Icon(Icons.apps),
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Konfirmasi'),
                content: widget.isAdmin
                    ? Text('Tinggalkan Halaman Admin?')
                    : Text('Masuk ke Halaman Admin?'),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Batalkan')),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (!widget.isAdmin) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewScreen(
                                        title: 'Login Admin',
                                        url:
                                            'https://pmisukabumikab.org/admin_area/form_login',
                                        isAdmin: true,
                                      )));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewScreen(
                                        title: 'PMI Kabupaten Sukabumi',
                                        url: 'https://pmisukabumikab.org/',
                                        isAdmin: false,
                                      )));
                        }
                      },
                      child: Text('Ya'))
                ],
              );
            });
      },
    );
  }
}
