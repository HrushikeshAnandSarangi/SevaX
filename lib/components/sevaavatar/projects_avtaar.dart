import 'dart:async';
import 'dart:developer';
import 'package:universal_io/io.dart' as io;

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
import '../../flavor_config.dart';
import '../../globals.dart' as globals;

class ProjectAvtaar extends StatefulWidget {
  final String? photoUrl;

  const ProjectAvtaar({Key? key, this.photoUrl}) : super(key: key);

  @override
  _ProjectsAvtaarState createState() => _ProjectsAvtaarState();
}

class _ProjectsAvtaarState extends State<ProjectAvtaar>
    with TickerProviderStateMixin
    implements ImagePickerListener {
  io.File? _image;
  late AnimationController _controller;
  late ImagePickerHandler? imagePicker;
  bool? _isImageBeingUploaded = false;
  ProfanityImageModel? profanityImageModel = ProfanityImageModel();
  ProfanityStatusModel? profanityStatusModel = ProfanityStatusModel();
  Future<String>? _uploadImage() async {
    int? timestamp = DateTime.now().millisecondsSinceEpoch;
    String? timestampString = timestamp.toString();
    Reference? ref = FirebaseStorage.instance
        .ref()
        .child('projects_avtaar')
        .child(SevaCore.of(context).loggedInUser.email! +
            timestampString +
            '.jpg');
    if (_image == null) return '';
    UploadTask uploadTask = ref.putFile(
      _image!,
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'Projects Logo'},
      ),
    );
    String imageURL = '';
    uploadTask.whenComplete(() async {
      imageURL = await ref.getDownloadURL();
      await profanityCheck(imageURL: imageURL);
    });

    return imageURL;
  }

  Future<void> profanityCheck({required String imageURL}) async {
    // _newsImageURL = imageURL;
    profanityImageModel = await checkProfanityForImage(imageUrl: imageURL);
    this._isImageBeingUploaded = false;

    if (profanityImageModel == null) {
      showFailedLoadImage(context: context).then((value) {
        setState(() {
          globals.projectsAvtaarURL = null;
        });
      });
    } else {
      if (profanityImageModel != null) {
        profanityStatusModel =
            await getProfanityStatus(profanityImageModel: profanityImageModel!);

        if (profanityStatusModel != null) {
          if (profanityStatusModel?.isProfane ?? false) {
            showProfanityImageAlert(
                    context: context,
                    content: profanityStatusModel?.category ?? '')
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
    }
  }

  @override
  void userImage(dynamic _image, String type) {
    if (type == 'stock_image') {
      setState(() {
        globals.projectsAvtaarURL = (_image as io.File?)?.path;
      });
    } else {
      setState(() {
        this._image = _image as io.File?;
        this._isImageBeingUploaded = true;
        _uploadImage();
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
    imagePicker?.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _getSevaXDefaultImage() {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(widget.photoUrl ?? defaultCameraImageURL),
                fit: BoxFit.cover),
            borderRadius: const BorderRadius.all(Radius.circular(75.0)),
            boxShadow: const [
          BoxShadow(blurRadius: 7.0, color: Colors.black12)
        ]));
  }

  Widget _getDefaultAvtarWidget() {
    return _getSevaXDefaultImage();
  }

  Widget _getHumanityFirstDefaultImage() {
    return Container(
      child: CircleAvatar(
        radius: 40.0,
        backgroundImage: AssetImage('lib/assets/images/genericlogo.png'),
      ),
    );
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
        onTap: () => imagePicker?.showDialog(context),
        child: _isImageBeingUploaded ?? false
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
                child: CircleAvatar(
                  radius: 40.0,
                  backgroundImage:
                      NetworkImage(globals.projectsAvtaarURL ?? ''),
                  backgroundColor: const Color(0xFF778899),
                ),
              ),
      ),
    );
  }

  @override
  void addWebImageUrl() {
    if (globals.webImageUrl != null && globals.webImageUrl!.isNotEmpty) {
      globals.projectsAvtaarURL = globals.webImageUrl;
      setState(() {});
    }
  }
}
