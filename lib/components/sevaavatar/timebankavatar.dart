import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

import './image_picker_handler.dart';
import '../../globals.dart' as globals;

class TimebankAvatar extends StatefulWidget {
  final String? photoUrl;

  TimebankAvatar({this.photoUrl});

  _TimebankAvatarState createState() => _TimebankAvatarState();
}

@override
class _TimebankAvatarState extends State<TimebankAvatar>
    with TickerProviderStateMixin, ImagePickerListener {
  File? _image;
  AnimationController? _controller;
  ImagePickerHandler? imagePicker;
  bool _isImageBeingUploaded = false;
  ProfanityImageModel profanityImageModel = ProfanityImageModel();
  ProfanityStatusModel profanityStatusModel = ProfanityStatusModel();
  Future<void> _uploadImage() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    Reference ref = FirebaseStorage.instance.ref().child('timebanklogos').child(
        SevaCore.of(context).loggedInUser.email! + timestampString + '.jpg');
    if (_image == null) return;
    UploadTask uploadTask = ref.putFile(
      _image!,
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'Timebank Logo'},
      ),
    );
    String imageURL = '';
    uploadTask.whenComplete(() async {
      imageURL = await ref.getDownloadURL();
      log('image url ${imageURL}');

      await profanityCheck(imageURL: imageURL);
    });
  }

  Future<void> profanityCheck({required String imageURL}) async {
    // _newsImageURL = imageURL;
    profanityImageModel = await checkProfanityForImage(imageUrl: imageURL);
    this._isImageBeingUploaded = false;

    if (profanityImageModel == null) {
      showFailedLoadImage(context: context).then((value) {
        setState(() {
          globals.timebankAvatarURL = null;
        });
      });
    } else {
      profanityStatusModel =
          await getProfanityStatus(profanityImageModel: profanityImageModel);

      if (profanityStatusModel?.isProfane ?? false) {
        showProfanityImageAlert(
                context: context, content: profanityStatusModel?.category ?? '')
            .then((status) {
          if (status == 'Proceed') {
            deleteFireBaseImage(imageUrl: imageURL).then((value) {
              if (value) {
                setState(() {
                  globals.timebankAvatarURL = null;
                });
              }
            }).catchError((e) => log(e));
          } else {}
        });
      } else {
        setState(() {
          globals.timebankAvatarURL = imageURL;
        });
      }
    }
  }

  @override
  void userImage(dynamic _image, type) {
    if (type == 'stock_image') {
      setState(() {
        globals.timebankAvatarURL = _image;
      });
    } else {
      setState(() {
        this._image = _image;
        this._isImageBeingUploaded = true;
      });
      _uploadImage();
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = ImagePickerHandler(this, _controller!, false);
    imagePicker!.init();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _getAvatarURL();
    var widthOfAvtar = 150.0;
    return Container(
      child: GestureDetector(
        onTap: () => imagePicker?.showDialog(context),
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
                      child: LoadingIndicator(),
                    ),
                  ),
                ),
              )
            : Container(
                width: widthOfAvtar,
                height: widthOfAvtar,
                child: globals.timebankAvatarURL == null
                    ? Stack(
                        children: <Widget>[
                          sevaXdeafaultImage,
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
                              globals.timebankAvatarURL ?? defaultUserImageURL),
                          backgroundColor: const Color(0xFF778899),
                        ),
                      ),
              ),
      ),
    );
  }

  Widget get sevaXdeafaultImage {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(
                  widget.photoUrl ?? defaultCameraImageURL,
                ),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.all(Radius.circular(75.0)),
            boxShadow: [BoxShadow(blurRadius: 7.0, color: Colors.black12)]));
  }

  @override
  addWebImageUrl() {
    if (globals.webImageUrl != null &&
        globals.webImageUrl?.isNotEmpty == true) {
      globals.timebankAvatarURL = globals.webImageUrl;
      setState(() {});
    }
  }
}
