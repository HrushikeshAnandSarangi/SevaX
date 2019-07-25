import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/views/core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cached_network_image/cached_network_image.dart';

import '../../globals.dart' as globals;
// import '../../auth/auth_provider.dart';
// import '../../auth/auth_router.dart';
// import '../../components/loader/seva_loader.dart';
// import '../../views/mytasks.dart';
// import '../../views/profileedit.dart';

// import '../services/seva_firestore_service.dart';

import 'dart:io';
import './image_picker_handler.dart';

class SevaAvatar extends StatefulWidget {
  _SevaAvatarState createState() => _SevaAvatarState();
}

@override
class _SevaAvatarState extends State<SevaAvatar>
    with TickerProviderStateMixin, ImagePickerListener {
  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;

  Future<dynamic> _getAvatarURL() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    SevaCore.of(context).loggedInUser.photoURL =
        prefs.getString('avatarurl') ?? null;
  }

  void _updateDB() {
    Firestore.instance
        .collection('users')
        .document(SevaCore.of(context).loggedInUser.email)
        .updateData({
      'avatarurl': SevaCore.of(context).loggedInUser.photoURL,
      'profilelastupdate': globals.profileLastUpdate
    });

    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => CoreView()));
  }

  _setAvatarURL() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'avatarurl', SevaCore.of(context).loggedInUser.photoURL);
  }

  Future<String> _uploadImage() async {
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('avatars')
        .child(SevaCore.of(context).loggedInUser.email + '.jpg');
    StorageUploadTask uploadTask = ref.putFile(
      _image,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'Avatar'},
      ),
    );
    String imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();

    SevaCore.of(context).loggedInUser.photoURL = imageURL;
    _setAvatarURL();
    _updateDB();
    return imageURL;
  }

  @override
  userImage(File _image) {
    setState(() {
      this._image = _image;
      _uploadImage();
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
    _getAvatarURL();
    return Container(
      child: GestureDetector(
        onTap: () => imagePicker.showDialog(context),
        child: Container(
          child: SevaCore.of(context).loggedInUser.photoURL == null
              ? Stack(
                  children: <Widget>[
                    Container(
                      child: CircleAvatar(
                        radius: 40.0,
                        // backgroundImage: Image.asset('profile'),
                        backgroundColor: const Color(0xFF778899),
                      ),
                    ),
                  ],
                )
              : Container(
                  child: CircleAvatar(
                    radius: 40.0,
                    // child: CachedNetworkImage(
                    //   imageUrl: avatarURL,
                    //   placeholder: CircularProgressIndicator(),
                    // ),
                    backgroundImage: NetworkImage(
                        SevaCore.of(context).loggedInUser.photoURL),
                    backgroundColor: const Color(0xFF778899),
                  ),
                ),
        ),
      ),
    );
  }
}
