import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/views/image_url_view.dart';

import './image_picker_handler.dart';

class ImagePickerDialog extends StatelessWidget {
  ImagePickerHandler _listener;
  AnimationController _controller;
  BuildContext context;

  ImagePickerDialog(this._listener, this._controller);

  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;

  void initState() {
    _drawerContentsOpacity = CurvedAnimation(
      parent: ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  void getImage(BuildContext context) {
    this.context = context;
    if (_controller == null ||
        _drawerDetailsPosition == null ||
        _drawerContentsOpacity == null) {
      return;
    }
    _controller.forward();
    showDialog(
      context: context,
      builder: (BuildContext context) => SlideTransition(
        position: _drawerDetailsPosition,
        child: FadeTransition(
          opacity: ReverseAnimation(_drawerContentsOpacity),
          child: this,
        ),
      ),
    );
  }

  void refresh() {
    _listener.addImageUrl();
  }

  void dispose() {
    _controller.dispose();
  }

  Future<Timer> startTime() async {
    var _duration = Duration(milliseconds: 200);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pop(dialogContext);
  }

  void dismissDialog() {
    _controller.reverse();
    startTime();
  }

  BuildContext dialogContext;
  @override
  Widget build(BuildContext _context) {
    //context;
    this.dialogContext = _context;
    return Material(
        type: MaterialType.transparency,
        child: Opacity(
          opacity: 1.0,
          child: Container(
            padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                  onTap: () => _listener.openCamera(),
                  child: roundedButton(
                      S.of(context).camera,
                      EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      const Color(0xFF673AB7),
                      const Color(0xFFFFFFFF)),
                ),
                GestureDetector(
                  onTap: () => _listener.openGallery(),
                  child: roundedButton(
                      S.of(context).gallery,
                      EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      const Color(0xFF673AB7),
                      const Color(0xFFFFFFFF)),
                ),
                GestureDetector(
                  onTap: () => _listener.openStockImages(context, (image) => {
                    print(image)
                  }),
                  child: roundedButton(
                      AppLocalizations.of(context)
                          .translate('image_picker', 'stock_images'),
                      EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      const Color(0xFF673AB7),
                      const Color(0xFFFFFFFF)),
                ),
                GestureDetector(
                  onTap: () {
                    dismissDialog();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return ImageUrlView();
                        },
                      ),
                    ).then((value) {
                      refresh();
                    });
                  },
                  child: roundedButton(
                    S.of(context).image_url,
                    EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    const Color(0xFF673AB7),
                    const Color(0xFFFFFFFF),
//                      Icon(
//                        Icons.language,
//                        color: Colors.white,
//                      ),
                  ),
                ),
                const SizedBox(height: 15.0),
                GestureDetector(
                  onTap: () => dismissDialog(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                    child: roundedButton(
                        S.of(context).cancel,
                        EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                        const Color(0xFF673AB7),
                        const Color(0xFFFFFFFF)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget roundedButton(
      String buttonLabel, EdgeInsets margin, Color bgColor, Color textColor) {
    var loginBtn = Container(
      margin: margin,
      padding: EdgeInsets.all(15.0),
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(10.0)),
      ),
      child: Text(
        buttonLabel,
        style: TextStyle(
            color: textColor, fontSize: 15.0, fontWeight: FontWeight.w500),
      ),
    );
    return loginBtn;
  }
}
