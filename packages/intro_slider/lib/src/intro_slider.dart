library intro_slider;

import 'dart:async';

import 'package:flutter/material.dart';

class IntroSlider extends StatefulWidget {
  // final List<Widget> data;
  final List<String> data;
  final VoidCallback onSkip;
  final String nextText;
  final String continueText;
  final String skipText;
  IntroSlider({@required this.data, @required this.onSkip, @required this.nextText, @required this.continueText, @required this.skipText});
  @override
  _IntroSliderState createState() => _IntroSliderState();
}

class _IntroSliderState extends State<IntroSlider> {
  Timer _timer;
  final PageController _controller = PageController(initialPage: 0);
  final _pageIndicator = StreamController<int>.broadcast();
  bool reachedEnd = false;

  @override
  void initState() {
    if (widget.data.length > 1) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          _timer = Timer.periodic(
            Duration(milliseconds: 600),
            (timer) async {
              // await _controller.nextPage(
              //   duration: Duration(milliseconds: 600),
              //   curve: Curves.easeInOut,
              // );
              if (_controller.hasClients) {
                if (_controller.page >= widget.data.length - 1) {
                  setState(() {
                    reachedEnd = true;
                  });
                }
              }
              _pageIndicator.add(
                _controller.page.toInt() % widget.data.length,
              );
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
              return Image.network(
                widget.data[index % widget.data.length],
                fit: BoxFit.fill,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: LinearProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                  );
                },
              );

              // return widget.data[index % widget.data.length];
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 0, bottom: 8),
              child: Row(
                children: [
                  TextButton(
                    onPressed: widget.onSkip,
                    child: Row(
                      children: [
                        Text(
                          widget.skipText,
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
                  Spacer(),
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
                  reachedEnd
                      ? TextButton(
                          onPressed: widget.onSkip,
                          child: Row(
                            children: [
                              Text(
                               widget.continueText,
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
                        )
                      : TextButton(
                          onPressed: () {
                            _controller.animateToPage(
                                _controller.page.toInt() + 1,
                                duration: Duration(milliseconds: 400),
                                curve: Curves.easeIn);

                            if (_controller.hasClients) {
                              if (_controller.page >= widget.data.length - 1) {
                                setState(() {
                                  reachedEnd = true;
                                });
                              }
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                widget.nextText,
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
