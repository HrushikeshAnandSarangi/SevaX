import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import './image_picker_dialog.dart';

class ImagePickerHandler {
  ImagePickerDialog imagePicker;
  AnimationController _controller;
  ImagePickerListener _listener;

  ImagePickerHandler(this._listener, this._controller);

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
    imagePicker.initState();
  }

  Future cropImage(File image) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 200,
      maxHeight: 200,
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
