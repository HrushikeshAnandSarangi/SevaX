import 'dart:async';
import 'package:universal_io/io.dart' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevaexchange/components/newsimage/news_image_picker_dialog.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class NewsImagePickerHandler {
  late NewsImagePickerDialog imagePicker;
  AnimationController _controller;
  NewsImagePickerListener _listener;

  NewsImagePickerHandler(this._listener, this._controller);

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

  void openDocument() async {
    imagePicker.dismissDialog();
    _openFileExplorer();
  }

  addImageUrl() async {
    _listener.addWebImageUrl();
  }

  void _openFileExplorer() async {
    //  bool _isDocumentBeingUploaded = false;
    //File _file;
    //List<File> _files;
    String _fileName;
    String? _path;
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
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        _path = result.files.single.path;
      }
    } on PlatformException catch (e) {
      logger.e("Unsupported operation" + e.toString());
    }
    //   if (!mounted) return;
    if (_path != null) {
      _fileName = _path.split('/').last;

      _listener.userDoc(_path, _fileName);
    }
  }

  void init() {
    imagePicker = NewsImagePickerDialog(this, _controller);
    imagePicker.initState();
  }

  Future cropImage(String image) async {
    io.File croppedFile;
    ImageCropper()
        .cropImage(
      sourcePath: image,
      aspectRatio: CropAspectRatio(
        ratioX: 1.0,
        ratioY: 1.0,
      ),
      maxWidth: 512,
      maxHeight: 512,
    )
        .then((value) {
      if (value != null) {
        croppedFile = io.File(value.path);
        _listener.userImage(croppedFile);
      }
    });
  }

  void showDialog(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
    imagePicker.getImage(context);
  }
}

abstract class NewsImagePickerListener {
  void userImage(io.File _image);
  void userDoc(String _doc, String fileName);
  addWebImageUrl();
}
