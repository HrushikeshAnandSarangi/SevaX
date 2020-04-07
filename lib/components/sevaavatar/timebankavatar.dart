import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/views/core.dart';

import './image_picker_handler.dart';
import '../../flavor_config.dart';
import '../../globals.dart' as globals;

class TimebankAvatar extends StatefulWidget {
  final String photoUrl;

  TimebankAvatar({this.photoUrl});

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
    var widthOfAvtar = FlavorConfig.appFlavor == Flavor.APP ? 150.0 : 150.0;
    return Container(
      child: GestureDetector(
        // onTap: () => imagePicker.showDialog(context),
        child: Container(
          width: widthOfAvtar,
          height: widthOfAvtar,
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

  Widget get defaultAvtarWidget {
    return FlavorConfig.appFlavor == Flavor.APP
        ? sevaXdeafaultImage
        : sevaXdeafaultImage;
  }

  Widget get humanityFirstdefaultImage {
    return Container(
      child: CircleAvatar(
        radius: 40.0,
        backgroundImage: AssetImage('lib/assets/images/genericlogo.png'),
      ),
    );
  }

  Widget get sevaXdeafaultImage {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(widget.photoUrl != null
                    ? widget.photoUrl
                    : defaultCameraImageURL),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.all(Radius.circular(75.0)),
            boxShadow: [BoxShadow(blurRadius: 7.0, color: Colors.black12)]));
  }
}
