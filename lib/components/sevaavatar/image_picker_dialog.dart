import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/views/image_url_view.dart';

import './image_picker_handler.dart';

class ImagePickerDialog extends StatelessWidget {
  ImagePickerHandler? _listener;
  AnimationController? _controller;
  BuildContext? context;
  bool? isCover;

  ImagePickerDialog(this._listener, this._controller, this.isCover);

  Animation<double>? _drawerContentsOpacity;
  Animation<Offset>? _drawerDetailsPosition;

  void initState() {
    _drawerContentsOpacity = CurvedAnimation(
      parent: ReverseAnimation(_controller!),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.fastOutSlowIn,
    ));
  }

  void getImage(BuildContext context, {bool? isOnboarding}) {
    this.context = context;
    if (_controller == null ||
        _drawerDetailsPosition == null ||
        _drawerContentsOpacity == null) {
      return;
    }
    _controller?.forward();
    showDialog(
      context: context,
      builder: (context) => SlideTransition(
        position: _drawerDetailsPosition!,
        child: FadeTransition(
          opacity: ReverseAnimation(_drawerContentsOpacity!),
          child: this,
        ),
      ),
    );
  }

  void refresh(BuildContext context) {
    _listener?.addImageUrl(context);
  }

  void dispose() {
    _controller?.dispose();
  }

  Future<Timer> startTime(BuildContext context) async {
    var _duration = Duration(milliseconds: 200);
    return Timer(_duration, () => navigationPage(context));
  }

  void navigationPage(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // void popContext() {
  //   if (Navigator.of(context).canPop()) {
  //     Navigator.of(dialogContext).pop();
  //   }
  // }

  void dismissDialog(BuildContext context) {
    _controller?.reverse();
    startTime(context);
  }

  @override
  Widget build(BuildContext _context) {
    //context;

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
                  onTap: () => _listener?.openCamera(_context),
                  child: roundedButton(
                      S.of(_context).camera,
                      EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      Theme.of(_context).primaryColor,
                      const Color(0xFFFFFFFF)),
                ),
                GestureDetector(
                  onTap: () => _listener?.openGallery(_context),
                  child: roundedButton(
                      S.of(_context).gallery,
                      EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      Theme.of(_context).primaryColor,
                      const Color(0xFFFFFFFF)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(_context)
                        .push(
                      MaterialPageRoute(
                        builder: (mContext) => SearchStockImages(
                          // keepOnBackPress: false,
                          // showBackBtn: false,
                          // isFromHome: false,
                          themeColor: Theme.of(_context).primaryColor,
                          onChanged: (image) async {
                            await _listener?.addStockImageUrl(
                                _context, image, isCover ?? false);
                            Navigator.pop(mContext);
                          },
                        ),
                      ),
                    )
                        .then((value) {
                      if (globals.isFromOnBoarding) {
                        dismissDialog(_context);
                      }
                    });
                  },
                  child: roundedButton(
                      S.of(_context).stock_images,
                      EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      Theme.of(_context).primaryColor,
                      const Color(0xFFFFFFFF)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(_context).push(
                      MaterialPageRoute(
                        builder: (mContext) {
                          return ImageUrlView(
                            isCover: isCover ?? false,
                            themeColor: Theme.of(_context).primaryColor,
                            onLinkCreated: (String url) async {
                              await _listener?.addStockImageUrl(
                                  _context, url, isCover ?? false);
                            },
                          );
                        },
                      ),
                    ).then((value) {
                      refresh(_context);
                      // dismissDialog();
                    });
                  },
                  child: roundedButton(
                    S.of(_context).add_image_url,
                    EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    Theme.of(_context).primaryColor,
                    const Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 15.0),
                GestureDetector(
                  onTap: () => dismissDialog(_context),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                    child: roundedButton(
                        S.of(_context).cancel,
                        EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                        Theme.of(_context).primaryColor,
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
