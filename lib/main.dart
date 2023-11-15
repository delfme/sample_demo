import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/material.dart' as material;
import 'package:lottie/lottie.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final List<String> items = List<String>.generate(60, (i) => '$i');

  //Fetch a lottie animation from network and preload
  final _lottieAnimation = NetworkLottie('https://d305e11xqcgjdr.cloudfront.net/stickers/cl69ghdwt000100bx966hxbp6/20.zip').load();

  @override
  void initState() {
  super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: true,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<LottieComposition>(
        future: _lottieAnimation,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorWidget(snapshot.error!);
          }
          var animation = snapshot.data;
          if (animation != null) {
            return MyHomePage(lottieAnimation: animation);
          } else {
            // Don't show the app until the animation is loaded.
            // Since it is loaded from the local assets, it will only take 1 frame.
            return const SizedBox();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // Only open the home page once we have the lottie animation fully loaded
  final LottieComposition lottieAnimation;

  const MyHomePage({Key? key, required this.lottieAnimation}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  final List<String> items = List<String>.generate(62, (i) => '$i');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Impeller'),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SwitchListTile(
                  title: Text('Enable Render Cache'),
                  value: _enableRenderCache,
                  onChanged: (v) {
                    setState(() {
                      _enableRenderCache = v;
                    });
                  },
                ),
                Expanded(
                  child: GridView.builder(
                      itemCount: 250,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      itemBuilder: (BuildContext context, int index) {
                        return Lottie(
                          composition: widget.lottieAnimation,
                          enableRenderCache: _enableRenderCache,
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
