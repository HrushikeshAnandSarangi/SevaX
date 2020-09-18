import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevaexchange/components/sevaavatar/image_picker_handler.dart';

import './user_image_picker_dialog.dart';

class UserImagePickerHandler {
  UserImagePickerDialog imagePicker;
  AnimationController _controller;
  UserImagePickerListener _listener;
  bool isAspectRatioFixed;

  UserImagePickerHandler(this._listener, this._controller,
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

abstract class UserImagePickerListener {
  void userImage(File _image);
  void stockImage(dynamic _image, String type);

  addWebImageUrl();
}
