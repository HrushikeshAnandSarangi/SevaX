import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import './user_image_picker_dialog.dart';

class ImagePickerHandler {
  ImagePickerDialog imagePicker;
  AnimationController _controller;
  ImagePickerListener _listener;
  bool isAspectRatioFixed;

  ImagePickerHandler(this._listener, this._controller,
      {this.isAspectRatioFixed = true});

  void openCamera() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    cropImage(image);
  }

  void openGallery() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    cropImage(image);
  }

  addImageUrl() async {
    imagePicker.dismissDialog();

    _listener.addWebImageUrl();
  }

  void init() {
    imagePicker = ImagePickerDialog(this, _controller);
    imagePicker.initState(isAspectRatioFixed);
  }

  Future cropImage(File image) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      ratioX: isAspectRatioFixed ? 1.0 : null,
      ratioY: isAspectRatioFixed ? 1.0 : null,
      maxWidth: isAspectRatioFixed ? 512 : null,
      maxHeight: isAspectRatioFixed ? 512 : null,
    );
    _listener.userImage(croppedFile);
  }

  void showDialog(BuildContext context) {
    imagePicker.getImage(context);
  }
}

abstract class ImagePickerListener {
  void userImage(File _image);
  addWebImageUrl();
}
