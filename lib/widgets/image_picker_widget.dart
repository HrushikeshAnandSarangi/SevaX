import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sevaexchange/components/newsimage/user_image_picker_handler.dart';

///Pass a [Widget] without any gestures or click events
class ImagePickerWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<File> onChanged;
  final bool isAspectRatioFixed;

  const ImagePickerWidget(
      {Key key, this.onChanged, this.child, this.isAspectRatioFixed = true})
      : assert(child != null),
        assert(onChanged != null),
        super(key: key);

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget>
    with TickerProviderStateMixin, UserImagePickerListener {
  UserImagePickerHandler imagePicker;
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    imagePicker = UserImagePickerHandler(
      this,
      _controller,
      isAspectRatioFixed: widget.isAspectRatioFixed,
    );
    imagePicker.init();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          {FocusScope.of(context).unfocus(), imagePicker.showDialog(context)},
      child: widget.child,
    );
  }

  @override
  void userImage(File _image) {
    widget.onChanged(_image);
  }

  @override
  addWebImageUrl() {
    // TODO: implement addWebImageUrl
    print('');
  }
}
