import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/news/newscreate.dart';

import '../../globals.dart' as globals;
import 'dart:io';
import './image_picker_handler.dart';

class NewsImage extends StatefulWidget {
  final Function addCreditTextFieldHandler;
  NewsImage(this.addCreditTextFieldHandler);
  NewsImageState createState() => NewsImageState(addCreditTextFieldHandler);
}

@override
class NewsImageState extends State<NewsImage>
    with TickerProviderStateMixin, ImagePickerListener {
  bool _isImageBeingUploaded = false;
  final Function addCreditTextFieldHandler;
  NewsImageState(this.addCreditTextFieldHandler);

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
      this.addCreditTextFieldHandler();
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
      onTap: () {
        imagePicker.showDialog(context);
      },
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
              ?
          Container(
              margin: EdgeInsets.only(top: 0,left: 0,right: 0,bottom: 0),
              child: Container(
                color: Colors.white,
                child: Center(
                  child: feedbackImage(),
                ),
              )
          )
              : _buildBody()
      ),
    );
  }
  Widget feedbackImage() {
    AssetImage assetImage1 = AssetImage('lib/assets/images/add-feed-image.png');
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0.0),
        child: Image(
          image: assetImage1,
          width: 150.0,
          height: 150.0,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return new Container(
        constraints: new BoxConstraints.expand(
            height: 400.0,
        ),
        alignment: Alignment.bottomCenter,
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: NetworkImage(globals.newsImageURL),
            fit: BoxFit.cover,
          ),
        ),
        child: Text('')
    );
  }

  }
