import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';

import './image_picker_handler.dart';

class ImagePickerDialog extends StatelessWidget {
  ImagePickerHandler _listener;
  AnimationController _controller;
  BuildContext context;

  ImagePickerDialog(this._listener, this._controller);

  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;

  void initState() {
    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = new Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  void getImage(BuildContext context) {
    this.context = context;
    if (_controller == null ||
        _drawerDetailsPosition == null ||
        _drawerContentsOpacity == null) {
    } else {
      _controller.forward();
      showDialog(
        context: context,
        builder: (BuildContext context) => new SlideTransition(
          position: _drawerDetailsPosition,
          child: new FadeTransition(
            opacity: new ReverseAnimation(_drawerContentsOpacity),
            child: this,
          ),
        ),
      );
    }
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
    this.dialogContext = _context;
    return new Material(
        type: MaterialType.transparency,
        child: new Opacity(
          opacity: 1.0,
          child: new Container(
            padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new GestureDetector(
                  onTap: () => _listener.openCamera(),
                  child: roundedButton(
                      AppLocalizations.of(context)
                          .translate('image_picker', 'camera'),
                      EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      const Color(0x0FF766FE0),
                      const Color(0xFFFFFFFF),
                      Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      )),
                ),
                new GestureDetector(
                  onTap: () => _listener.openGallery(),
                  child: roundedButton(
                      AppLocalizations.of(context)
                          .translate('image_picker', 'gallery'),
                      EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      const Color(0x0FF766FE0),
                      const Color(0xFFFFFFFF),
                      Icon(
                        Icons.image,
                        color: Colors.white,
                      )),
                ),
                const SizedBox(height: 15.0),
                new GestureDetector(
                  onTap: () => dismissDialog(),
                  child: new Padding(
                    padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                    child: roundedButton(
                        AppLocalizations.of(context)
                            .translate('shared', 'cancel'),
                        EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                        const Color(0x0FF766FE0),
                        const Color(0xFFFFFFFF),
                        Offstage()),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget roundedButton(String buttonLabel, EdgeInsets margin, Color bgColor,
      Color textColor, Widget widget) {
    var loginBtn = new Container(
      margin: margin,
      padding: EdgeInsets.all(15.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
        // boxShadow: <BoxShadow>[
        //   BoxShadow(
        //     color: const Color(0xFF696969),
        //     offset: Offset(1.0, 6.0),
        //     blurRadius: 0.001,
        //   ),
        // ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          widget,
          SizedBox(
            width: 5,
          ),
          Text(
            buttonLabel,
            style: new TextStyle(
                color: textColor, fontSize: 15.0, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
    return loginBtn;
  }
}
