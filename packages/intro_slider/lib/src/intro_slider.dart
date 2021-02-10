library intro_slider;

import 'dart:async';

import 'package:flutter/material.dart';

class IntroSlider extends StatefulWidget {
  // final List<Widget> data;
  final List<String> data;
  final VoidCallback onSkip;
  IntroSlider({@required this.data, @required this.onSkip});
  @override
  _IntroSliderState createState() => _IntroSliderState();
}

class _IntroSliderState extends State<IntroSlider> {
  Timer _timer;
  final PageController _controller = PageController(initialPage: 0);
  final _pageIndicator = StreamController<int>.broadcast();
  bool shouldSwitchNext = false;

  @override
  void initState() {
    if (widget.data.length > 1) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          _timer = Timer.periodic(
            Duration(seconds: 4),
            (timer) async {
              if (shouldSwitchNext) {
                await _controller.nextPage(
                  duration: Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                );
                _pageIndicator.add(
                  _controller.page.toInt() % widget.data.length,
                );
                shouldSwitchNext = false;
              }
            },
          );
        },
      );
    }
    super.initState();
  }

  // dispose method
  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // slider
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemBuilder: (context, index) {
              // return CachedNetworkImage(
              //   imageUrl: widget.data[index % widget.data.length],
              //   placeholder: (BuildContext context, String url) {
              //     return Center(
              //       child: Container(
              //           width: 60,
              //           height: 60,
              //           child: CircularProgressIndicator()),
              //     );
              //   },
              //   errorWidget: (BuildContext context, String url, error) =>
              //       Icon(Icons.error),
              // );
              return Image.network(
                widget.data[index % widget.data.length],
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) {
                    shouldSwitchNext = true;
                    return child;
                  }
                  shouldSwitchNext = false;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  );
                },
                fit: BoxFit.fill,
              );
              // return widget.data[index % widget.data.length];
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Row(
                children: [
                  StreamBuilder<int>(
                    stream: _pageIndicator.stream,
                    builder: (context, snapshot) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.data.length,
                          (index) => Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              height: index == (snapshot.data ?? 0) ? 15 : 8,
                              width: index == (snapshot.data ?? 0) ? 15 : 8,
                              decoration: BoxDecoration(
                                color: index == (snapshot.data ?? 0)
                                    ? Colors.white
                                    : Colors.white38,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Spacer(),
                  FlatButton(
                    color: Colors.transparent,
                    onPressed: widget.onSkip,
                    child: Row(
                      children: [
                        Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
