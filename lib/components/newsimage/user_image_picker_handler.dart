import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevaexchange/components/sevaavatar/image_picker_handler.dart';

import './user_image_picker_dialog.dart';

class UserImagePickerHandler {
  late UserImagePickerDialog imagePicker;
  late AnimationController _controller;
  late UserImagePickerListener _listener;
  late bool isAspectRatioFixed;

  UserImagePickerHandler(this._listener, this._controller,
      {this.isAspectRatioFixed = true});

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

  void openStockImages(context) async {
    imagePicker.dismissDialog();

    FocusScope.of(context).requestFocus(FocusNode());
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => SearchStockImages(
              // keepOnBackPress: false,
              // showBackBtn: false,
              // isFromHome: false,
              themeColor: Theme.of(context).primaryColor,
              onChanged: (image) {
                _listener.stockImage(image, 'stock_image');
                Navigator.pop(context);
              },
            ),
          ),
        )
        .then((value) {});
    // _parentStockSelectionBottomsheet(context, (image) {
    //   log("inside stock images onchanged callback");
    //   _listener.userImage(image, 'stock_image');
    //   Navigator.pop(context);
    // });
  }

  addImageUrl() async {
    imagePicker.dismissDialog();

    _listener.addWebImageUrl();
  }

  void init() {
    imagePicker = UserImagePickerDialog(this, _controller);
    imagePicker.initState(isAspectRatioFixed);
  }

  Future cropImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: CropAspectRatio(
        ratioX: isAspectRatioFixed ? 1.0 : 1.0,
        ratioY: isAspectRatioFixed ? 1.0 : 1.0,
      ),
      maxWidth: isAspectRatioFixed ? 512 : 512,
      maxHeight: isAspectRatioFixed ? 512 : 512,
    );
    if (croppedFile != null) {
      _listener.userImage(File(croppedFile.path));
    }
  }

  void showDialog(BuildContext context) {
    imagePicker.getImage(context);
  }
}

abstract class UserImagePickerListener {
  void userImage(File _image);
  void stockImage(dynamic _image, String type);

  addWebImageUrl();
}
