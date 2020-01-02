import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sevaexchange/views/core.dart';
// import 'package:cached_network_image/cached_network_image.dart';

import '../../flavor_config.dart';
import '../../globals.dart' as globals;
// import '../../auth/auth_provider.dart';
// import '../../auth/auth_router.dart';
// import '../../components/loader/seva_loader.dart';
// import '../../views/mytasks.dart';
// import '../../views/profileedit.dart';

// import '../services/seva_firestore_service.dart';

import 'dart:io';
import './image_picker_handler.dart';

class TimebankAvatar extends StatefulWidget {
  _TimebankAvatarState createState() => _TimebankAvatarState();
}

@override
class _TimebankAvatarState extends State<TimebankAvatar>
    with TickerProviderStateMixin, ImagePickerListener {
  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;

  Future<String> _uploadImage() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('timebanklogos')
        .child(
            SevaCore.of(context).loggedInUser.email + timestampString + '.jpg');
    StorageUploadTask uploadTask = ref.putFile(
      _image,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'Timebank Logo'},
      ),
    );
    String imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();

    setState(() {
      globals.timebankAvatarURL = imageURL;
    });

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
    // _getAvatarURL();

    return Container(
      child: GestureDetector(
        onTap: () => imagePicker.showDialog(context),
        child: Container(
          child: globals.timebankAvatarURL == null
              ? Stack(
                  children: <Widget>[
                    defaultAvtarWidget,
                  ],
                )
              : Container(
                  child: CircleAvatar(
                    radius: 40.0,
                    // child: CachedNetworkImage(
                    //   imageUrl: avatarURL,
                    //   placeholder: CircularProgressIndicator(),
                    // ),
                    backgroundImage: NetworkImage(globals.timebankAvatarURL),
                    backgroundColor: const Color(0xFF778899),
                  ),
                ),
        ),
      ),
    );
  }
  Widget get defaultAvtarWidget{
    return FlavorConfig.appFlavor == Flavor.APP ? sevaXdeafaultImage : humanityFirstdefaultImage;
  }

  Widget get humanityFirstdefaultImage{
    return Container(
        child: CircleAvatar(
          radius: 40.0,
          backgroundImage:
          AssetImage('lib/assets/images/genericlogo.png'),
        ),
      );
  }

  Widget get sevaXdeafaultImage {
    return Container(
        width: 75.0,
        height: 75.0,
        decoration: BoxDecoration(
            color: Colors.red,
            image: DecorationImage(
                image: NetworkImage(
                    'https://cdn.dribbble.com/users/2060373/screenshots/5676655/2_2x.jpg'),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.all(Radius.circular(75.0)),
            boxShadow: [
              BoxShadow(blurRadius: 7.0, color: Colors.black12)
            ]
        )
    );
  }
}
