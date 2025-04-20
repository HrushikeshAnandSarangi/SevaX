import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import './image_picker_dialog.dart';

class ImagePickerHandler {
  late ImagePickerDialog imagePicker;
  AnimationController _controller;
  ImagePickerListener _listener;

  ImagePickerHandler(this._listener, this._controller);

  void openCamera() async {
    imagePicker.dismissDialog();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      cropImage(pickedFile.path);
    }
  }

  void openGallery() async {
    imagePicker.dismissDialog();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      cropImage(pickedFile.path);
    }
  }

  addImageUrl() async {
    imagePicker.dismissDialog();
    _listener.addWebImageUrl();
  }

  void init() {
    imagePicker = ImagePickerDialog(this, _controller);
    imagePicker.initState();
  }

  Future cropImage(String image) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image,
      aspectRatio: CropAspectRatio(
        ratioX: 1.0,
        ratioY: 1.0,
      ),
      maxWidth: 200,
      maxHeight: 200,
    );
    if (croppedFile != null) {
      _listener.userImage(File(croppedFile.path));
    }
  }

  void showDialog(BuildContext context) {
    imagePicker.getImage(context);
  }
}

abstract class ImagePickerListener {
  void userImage(File _image);
  addWebImageUrl();
}
