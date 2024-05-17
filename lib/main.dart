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
  final _lottieAnimation = NetworkLottie('https://d305e11xqcgjdr.cloudfront.net/stickers/cl69ghdwt000100bx966hxbp6/1.zip').load();

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
  late final _lottieCache = CachedLottie(Size(150, 150), widget.lottieAnimation);

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
              children:  <Widget>[
                Expanded(
                  child: GridView.builder(
                      itemCount: 250,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                      itemBuilder: (BuildContext context, int index) {
                        return CachedLottiePlayer(lottie: _lottieCache);
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



// A class to cache the images inside the lottie animations
class CachedLottie {
  final Size size;
  final LottieComposition composition;
  final List<Image?> images;
  late final _drawable = LottieDrawable(composition);

  CachedLottie(this.size, this.composition)
      : images = List.filled(composition.durationFrames.ceil(), null);

  Duration get duration => composition.duration;

  Image imageAt(BuildContext context, double progress) {
    var index = (images.length * progress).round() % images.length;
    return images[index] ??= _takeImage(context, progress);
  }

  Image _takeImage(BuildContext context, double progress) {
    var recorder = PictureRecorder();
    var canvas = Canvas(recorder);

    var devicePixelRatio = View.of(context).devicePixelRatio;

    _drawable
      ..setProgress(progress)
      ..draw(canvas, Offset.zero & (size * devicePixelRatio));
    var picture = recorder.endRecording();
    return picture.toImageSync((size.width * devicePixelRatio).round(),
        (size.height * devicePixelRatio).round());
  }
}

// A Player for the cached the images of the lottie animations
class CachedLottiePlayer extends StatefulWidget {
  final CachedLottie lottie;
  final AnimationController? controller;

  const CachedLottiePlayer({
    super.key,
    required this.lottie,
    this.controller,
  });

  @override
  State<CachedLottiePlayer> createState() => _CachedLottiePlayerState();
}

class _CachedLottiePlayerState extends State<CachedLottiePlayer>
    with TickerProviderStateMixin {
  late final AnimationController _autoController =
  AnimationController(vsync: this, duration: widget.lottie.duration)
    ..repeat();

  @override
  Widget build(BuildContext context) {
    var controller = widget.controller ?? _autoController;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        var image = widget.lottie.imageAt(context, controller.value);
        return material.RawImage(
          image: image,
          width: widget.lottie.size.width,
          height: widget.lottie.size.height,
        );
      },
    );
  }

  @override
  void dispose() {
    _autoController.dispose();
    super.dispose();
  }

}


