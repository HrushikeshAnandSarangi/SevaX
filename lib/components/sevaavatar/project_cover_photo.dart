import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

import './image_picker_handler.dart';
import '../../flavor_config.dart';
import '../../globals.dart' as globals;

class ProjectCoverPhoto extends StatefulWidget {
  final String cover_url;

  ProjectCoverPhoto({this.cover_url});

  _ProjectCoverPhotoState createState() => _ProjectCoverPhotoState();
}

@override
class _ProjectCoverPhotoState extends State<ProjectCoverPhoto>
    with TickerProviderStateMixin, ImagePickerListener {
  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;
  bool _isImageBeingUploaded = false;
  ProfanityImageModel profanityImageModel = ProfanityImageModel();
  ProfanityStatusModel profanityStatusModel = ProfanityStatusModel();

  Future<String> _uploadImage(File croppedImage) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('projects_avtaar')
        .child(
            SevaCore.of(context).loggedInUser.email + timestampString + '.jpg');
    UploadTask uploadTask = ref.putFile(
      croppedImage,
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'Cover Photo'},
      ),
    );
    String imageURL = '';
    await uploadTask.whenComplete(() async {
      imageURL = await ref.getDownloadURL();
      await profanityCheck(imageURL: imageURL);
    });
    log("user cover image $imageURL");

    return imageURL;
  }

  Future<void> profanityCheck({String imageURL}) async {
    // _newsImageURL = imageURL;
    profanityImageModel = await checkProfanityForImage(imageUrl: imageURL);
    this._isImageBeingUploaded = false;

    if (profanityImageModel == null) {
      showFailedLoadImage(context: context).then((value) {
        setState(() {
          globals.projectsCoverURL = null;
        });
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
                  globals.projectsCoverURL = null;
                });
              }
            }).catchError((e) => log(e));
            ;
          }
        });
      } else {
        setState(() {
          globals.projectsCoverURL = imageURL;
        });
      }
    }
  }

  @override
  void userImage(dynamic _image, type) {
    log('user image cropped file ${_image.path}');
    if (type == 'stock_image') {
      setState(() {
        globals.projectsCoverURL = _image;
      });
    } else {
      setState(() {
        this._image = _image;
        this._isImageBeingUploaded = true;
        _uploadImage(_image);
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

    imagePicker = ImagePickerHandler(this, _controller, true);
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
    var widthOfCover = 620.0;
    var heightOfCover = 180.0;
    return Container(
      child: GestureDetector(
        onTap: () => imagePicker.showDialog(context),
        child: _isImageBeingUploaded
            ? Container(
                margin: EdgeInsets.only(top: 20),
                child: Container(
                  color: Colors.grey[100],
                  width: 620,
                  height: 180,
                  child: Center(
                    child: Container(
                      child: LoadingIndicator(),
                    ),
                  ),
                ),
              )
            : Container(
                width: widthOfCover,
                height: heightOfCover,
                child: globals.projectsCoverURL == null
                    ? Stack(
                        children: <Widget>[
                          sevaXdeafaultImage,
                        ],
                      )
                    : Container(
                        width: 620,
                        height: 180,
                        child: Image(
                          fit: BoxFit.cover,
                          width: 620,
                          height: 180,
                          image: NetworkImage(
                              globals.projectsCoverURL ?? defaultGroupImageURL),
                        ),
                      ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3.0,
                        color: Colors.black12,
                        offset: Offset(0.0, 0.75),
                      )
                    ]),
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
    return (widget.cover_url != null && widget.cover_url != '')
        ? Container(
            width: 620,
            height: 180,
            child: Image(
              image: NetworkImage(
                widget.cover_url ?? defaultGroupImageURL,
              ),
              fit: BoxFit.cover,
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3.0,
                    color: Colors.black12,
                    offset: Offset(0.0, 0.75),
                  )
                ]),
          )
        : Container(
            width: 620,
            height: 180,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: addImageIcon,
                    placeholder: (context, url) => LoadingIndicator(),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    S.of(context).add_cover_picture,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  // SizedBox(
                  //   height: 8,
                  // ),
                  // Text(
                  //   S.of(context).or_drag_and_drop,
                  //   style: TextStyle(fontSize: 12),
                  // ),
                ],
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3.0,
                    color: Colors.black12,
                    offset: Offset(0.0, 0.75),
                  )
                ]),
          );
  }

  @override
  addWebImageUrl() {
    // TODO: implement addWebImageUrl
    if (globals.webImageUrl != null && globals.webImageUrl.isNotEmpty) {
      globals.projectsCoverURL = globals.webImageUrl;
      setState(() {});
    }
  }
}
