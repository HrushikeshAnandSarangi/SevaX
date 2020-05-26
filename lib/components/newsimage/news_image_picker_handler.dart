import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevaexchange/components/newsimage/news_image_picker_dialog.dart';

class NewsImagePickerHandler {
  NewsImagePickerDialog imagePicker;
  AnimationController _controller;
  NewsImagePickerListener _listener;

  NewsImagePickerHandler(this._listener, this._controller);

  openCamera() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    cropImage(image);
  }

  openGallery() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    cropImage(image);
  }

  openDocument() async {
    imagePicker.dismissDialog();
    _openFileExplorer();
  }

  void _openFileExplorer() async {
    //  bool _isDocumentBeingUploaded = false;
    //File _file;
    //List<File> _files;
    String _fileName;
    String _path;
    Map<String, String> _paths;
//    String _extension;
//    bool _loadingPath = false;
//    bool _multiPick = false;
//    FileType _pickingType = FileType.custom;
//    try {
//      if (_multiPick) {
//        _path = null;
//        _files = await FilePicker.getMultiFile(
//            type: _pickingType,
//            allowedExtensions: (_extension?.isNotEmpty ?? false)
//                ? _extension?.replaceAll(' ', '')?.split(',')
//                : null);
//      } else {
//        _paths = null;
//        _path = await FilePicker.getFilePath(
//            type: FileType.custom, allowedExtensions: ['pdf']);
//      }
//    } on PlatformException catch (e) {
//      print("Unsupported operation" + e.toString());
//    }
    try {
      _paths = null;
      _path = await FilePicker.getFilePath(
          type: FileType.custom, allowedExtensions: ['pdf']);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    //   if (!mounted) return;

    _fileName = _path != null
        ? _path.split('/').last
        : _paths != null ? _paths.keys.toString() : 'PDF document';
    print("FIle  name $_fileName");

    _listener.userDoc(_path, _fileName);
  }

  void init() {
    imagePicker = new NewsImagePickerDialog(this, _controller);
    imagePicker.initState();
  }

  Future cropImage(File image) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );
    _listener.userImage(croppedFile);
  }

  showDialog(BuildContext context) {
    imagePicker.getImage(context);
  }
}

abstract class NewsImagePickerListener {
  userImage(File _image);
  userDoc(String _doc, String fileName);
}
