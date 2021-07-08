import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

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
  ProfanityImageModel profanityImageModel = ProfanityImageModel();
  ProfanityStatusModel profanityStatusModel = ProfanityStatusModel();
  Future<String> _uploadImage() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('projects_avtaar')
        .child(
            SevaCore.of(context).loggedInUser.email + timestampString + '.jpg');
    UploadTask uploadTask = ref.putFile(
      _image,
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'Projects Logo'},
      ),
    );
    String imageURL = '';
    uploadTask.whenComplete(() async {
      imageURL = await ref.getDownloadURL();
    });
    await profanityCheck(imageURL: imageURL);

    return imageURL;
  }

  Future<void> profanityCheck({String imageURL}) async {
    // _newsImageURL = imageURL;
    profanityImageModel = await checkProfanityForImage(imageUrl: imageURL);
    if (profanityImageModel == null) {
      showFailedLoadImage(context: context).then((value) {
        globals.projectsAvtaarURL = null;
      });
    } else {
      profanityStatusModel =
          await getProfanityStatus(profanityImageModel: profanityImageModel);

      if (profanityStatusModel.isProfane) {
        showProfanityImageAlert(
                context: context, content: profanityStatusModel.category)
            .then((status) {
          if (status == 'Proceed') {
            deleteFireBaseImage(imageUrl: imageURL).then((value) {
              if (value) {
                setState(() {
                  globals.projectsAvtaarURL = null;
                });
              }
            }).catchError((e) => log(e));
          }
        });
      } else {
        setState(() {
          globals.projectsAvtaarURL = imageURL;
        });
      }
    }
  }

  @override
  void userImage(dynamic _image, type) {
    if (type == 'stock_image') {
      setState(() {
        globals.projectsAvtaarURL = _image;
      });
    } else {
      setState(() {
        this._image = _image;
        this._isImageBeingUploaded = true;
        _uploadImage().then((_) {
          this._isImageBeingUploaded = false;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = ImagePickerHandler(this, _controller, false);
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
                image: NetworkImage(widget.photoUrl ?? defaultCameraImageURL),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.all(Radius.circular(75.0)),
            boxShadow: [BoxShadow(blurRadius: 7.0, color: Colors.black12)]));
  }

  @override
  addWebImageUrl() {
    // TODO: implement addWebImageUrl
    if (globals.webImageUrl != null && globals.webImageUrl.isNotEmpty) {
      globals.projectsAvtaarURL = globals.webImageUrl;
      setState(() {});
    }
  }
}
