import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../../globals.dart' as globals;
import '../core.dart';

class DocumentUpload extends StatefulWidget {
  @override
  _DocumentUploadState createState() => _DocumentUploadState();
}

class _DocumentUploadState extends State<DocumentUpload> {
  bool _isDocumentBeingUploaded = false;
  File _file;
  List<File> _files;
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  AnimationController _controller;
  bool _multiPick = false;
  FileType _pickingType = FileType.custom;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFileExplorer() async {
    try {
      if (_multiPick) {
        _path = null;
        _files = await FilePicker.getMultiFile(
            type: _pickingType,
            allowedExtensions: (_extension?.isNotEmpty ?? false)
                ? _extension?.replaceAll(' ', '')?.split(',')
                : null);
      } else {
        _paths = null;
        _path = await FilePicker.getFilePath(
            type: FileType.custom, allowedExtensions: ['pdf']);
      }
    } on PlatformException catch (e) {
      logger.e(e);
    }
    if (!mounted) return;
    setState(() {
      _isDocumentBeingUploaded = true;

      _fileName = _path != null
          ? _path.split('/').last
          : _paths != null
              ? _paths.keys.toString()
              : '...';
      uploadDocument().then((_) {
        setState(() => this._isDocumentBeingUploaded = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFileExplorer(),
      child: Column(
        children: <Widget>[
          _isDocumentBeingUploaded
              ? Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Container(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : Container(
                  child: globals.newsDocumentURL == null
                      ? Offstage()
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: ListTile(
                              leading: Icon(Icons.attachment),
                              title: Text(
                                globals.newsDocumentName ??
                                    S.of(context).document,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                ),
          TextButton.icon(
            icon: Icon(Icons.attach_file),
            style: TextButton.styleFrom(
              primary: Colors.grey[200],
            ),
            label: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _path != null
                    ? S.of(context).change_document
                    : S.of(context).add_document,
              ),
            ),
            onPressed: () {
              _openFileExplorer(); //imagePicker.showDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Future<String> uploadDocument() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('news_documents')
        .child(SevaCore.of(context).loggedInUser.email +
            timestampString +
            _fileName);
    StorageUploadTask uploadTask = ref.putFile(
      File(_path),
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'News Document'},
      ),
    );
    String documentURL =
        await (await uploadTask.onComplete).ref.getDownloadURL();

    // _newsImageURL = imageURL;
    globals.newsDocumentURL = documentURL;
    globals.newsDocumentName = _fileName;
    // _setAvatarURL();
    // _updateDB();
    return documentURL;
  }
}
