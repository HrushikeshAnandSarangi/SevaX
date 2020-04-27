import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/views/core.dart';

import './image_picker_handler.dart';
import '../../flavor_config.dart';
import '../../globals.dart' as globals;

class ProjectAvtaar extends StatefulWidget {
  final String photoUrl;

  ProjectAvtaar({this.photoUrl});

  _ProjectsAvtaarState createState() => _ProjectsAvtaarState();
}

@override
class _ProjectsAvtaarState extends State<ProjectAvtaar>
    with TickerProviderStateMixin, ImagePickerListener {
  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;
  bool _isImageBeingUploaded = false;

  Future<String> _uploadImage() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('projects_avtaar')
        .child(
            SevaCore.of(context).loggedInUser.email + timestampString + '.jpg');
    StorageUploadTask uploadTask = ref.putFile(
      _image,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'Projects Logo'},
      ),
    );
    String imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();

    setState(() {
      globals.projectsAvtaarURL = imageURL;
    });

    return imageURL;
  }

  @override
  userImage(File _image) {
    setState(() {
      this._image = _image;
      this._isImageBeingUploaded = true;
      _uploadImage().then((_) {
        this._isImageBeingUploaded = false;
      });
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
    var widthOfAvtar = (FlavorConfig.appFlavor == Flavor.APP ||
            FlavorConfig.appFlavor == Flavor.SEVA_DEV)
        ? 150.0
        : 150.0;
    return Container(
      child: GestureDetector(
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
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              )
            : Container(
                width: widthOfAvtar,
                height: widthOfAvtar,
                child: globals.projectsAvtaarURL == null
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
                          backgroundImage:
                              NetworkImage(globals.projectsAvtaarURL),
                          backgroundColor: const Color(0xFF778899),
                        ),
                      ),
              ),
      ),
    );
  }

  Widget get defaultAvtarWidget {
    return (FlavorConfig.appFlavor == Flavor.APP ||
            FlavorConfig.appFlavor == Flavor.SEVA_DEV)
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
