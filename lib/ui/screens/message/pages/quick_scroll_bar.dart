import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/utils/strings.dart';

class QuickScrollBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  QuickScrollBar({required this.onChanged});

  @override
  _QuickScrollBarState createState() => _QuickScrollBarState();
}

class _QuickScrollBarState extends State<QuickScrollBar> {
  double offsetContainer = 0.0;
  var scrollBarText;
  var scrollBarTextPrev;
  var scrollBarHeight;
  var contactRowSize = 70;
  var scrollBarMarginRight = 50.0;
  var scrollBarContainerHeight;
  var scrollBarPosSelected = 0;
  var scrollBarHeightDiff = 0.0;
  var screenHeight = 0.0;
  String scrollBarBubbleText = "";
  bool scrollBarBubbleVisibility = true;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      scrollBarBubbleVisibility = true;
      if ((offsetContainer + details.delta.dy) >= 0 &&
          (offsetContainer + details.delta.dy) <=
              (scrollBarContainerHeight - scrollBarHeight)) {
        offsetContainer += details.delta.dy;

        scrollBarPosSelected =
            ((offsetContainer / scrollBarHeight) % alphabetList.length).round();

        scrollBarText = alphabetList[scrollBarPosSelected];
        if (scrollBarText != scrollBarTextPrev) {
          widget.onChanged(scrollBarText.toString());

          scrollBarTextPrev = scrollBarText;
        }
      }
    });
  }

  void _onVerticalDragStart(DragStartDetails details) {
    offsetContainer = details.globalPosition.dy - scrollBarHeightDiff;
    setState(() {
      scrollBarBubbleVisibility = true;
    });
  }

  Widget getBubble() {
    if (!scrollBarBubbleVisibility) {
      return Container();
    }
    return Container(
      decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(const Radius.circular(30.0))),
      width: 30,
      height: 30,
      child: Center(
        child: Text(
          "${scrollBarText ?? "${alphabetList.first}"}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  Widget _getAlphabetItem(int index) {
    return Expanded(
      child: Container(
        width: 40,
        height: 20,
        alignment: Alignment.center,
        child: Text(
          alphabetList[index],
          style: (index == scrollBarPosSelected)
              ? TextStyle(fontSize: 16, fontWeight: FontWeight.w700)
              : TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  void _onVerticalEnd(DragEndDetails details) {
    setState(() {
      scrollBarBubbleVisibility = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return LayoutBuilder(builder: (context, constraints) {
      scrollBarHeightDiff = screenHeight - constraints.biggest.height;
      scrollBarHeight = (constraints.biggest.height) / alphabetList.length;
      scrollBarContainerHeight = (constraints.biggest.height); //NO
      return Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onVerticalDragEnd: _onVerticalEnd,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragStart: _onVerticalDragStart,
              child: Container(
                height: 30.0 * 26,
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: []..addAll(
                      List.generate(
                        alphabetList.length,
                        (index) => _getAlphabetItem(index),
                      ),
                    ),
                ),
              ),
            ),
          ),
          Positioned(
            right: scrollBarMarginRight,
            top: offsetContainer,
            child: getBubble(),
          ),
        ],
      );
    });
  }
}
