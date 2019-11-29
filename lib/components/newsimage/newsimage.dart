import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/news/newscreate.dart';

import '../../globals.dart' as globals;
import 'dart:io';
import './image_picker_handler.dart';

class NewsImage extends StatefulWidget {
  NewsImageState createState() => NewsImageState();
}

@override
class NewsImageState extends State<NewsImage>
    with TickerProviderStateMixin, ImagePickerListener {
  bool _isImageBeingUploaded = false;

  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;

  Future<String> uploadImage() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('newsimages')
        .child(
            SevaCore.of(context).loggedInUser.email + timestampString + '.jpg');
    StorageUploadTask uploadTask = ref.putFile(
      _image,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'News Image'},
      ),
    );
    String imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();

    // _newsImageURL = imageURL;
    globals.newsImageURL = imageURL;

    // _setAvatarURL();
    // _updateDB();
    return imageURL;
  }

  void userImage(File _image) {
    setState(() {
      this._image = _image;
      this._isImageBeingUploaded = true;
    });
    uploadImage().then((_) {
      setState(() => this._isImageBeingUploaded = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = ImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => imagePicker.showDialog(context),
      child: _isImageBeingUploaded
          ? Container(
              margin: EdgeInsets.only(top: 20),
              child: Container(
                  color: Colors.grey[100],
                  height: 150,
                  width: 150,
                  child: Center(
                      child: Container(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator()))))
          : Container(
              child: globals.newsImageURL == null
                  ? Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 20),
                      child: Container(
                        // height: 60,
                        // width: 100,
                        // color: Colors.grey[100],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(0),
                              width: double.infinity,
                              child: FlatButton.icon(
                                icon: Icon(Icons.image),
                                label: Text(
                                  "Add Image",
                                ),
                                onPressed: () {
                                  imagePicker.showDialog(context);
                                },
                              ),
                            ),
                            // Text(
                            //   'Add',
                            //   style: Theme.of(context).textTheme.title,
                            // ),
                            // Text(
                            //   'Image',
                            //   style: Theme.of(context).textTheme.title,
                            // ),
                            // Text(
                            //   '+',
                            //   style: Theme.of(context).textTheme.title,
                            // )
                          ],
                        ),
                      ))
                  : Container(
                      height: 200,
                      width: 200,
                      child: FadeInImage(
                        image: NetworkImage(globals.newsImageURL),
                        placeholder: AssetImage(
                          'lib/assets/images/noimagefound.png',
                        ),
                      ),
                    ),
            ),
    );
  }
}
