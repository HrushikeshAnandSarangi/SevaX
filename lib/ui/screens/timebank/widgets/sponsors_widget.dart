import 'dart:io';
import 'dart:developer';
import 'package:file_picker/file_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/new_baseline/models/profanity_image_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:path/path.dart' as pathExt;

import '../../../../flavor_config.dart';

enum SponsorsMode { ABOUT, CREATE, EDIT }

class SponsorsWidget extends StatefulWidget {
  final TimebankModel timebankModel;
  final SponsorsMode sponsorsMode;
  final Function(TimebankModel timebankModel) onCreated;
  final Function(TimebankModel timebankModel) onRemoved;

  SponsorsWidget(
      {this.timebankModel,
      @required this.sponsorsMode,
      this.onCreated,
      this.onRemoved});

  @override
  _SponsorsWidgetState createState() => _SponsorsWidgetState();
}

class _SponsorsWidgetState extends State<SponsorsWidget> {
  int indexPosition;
  bool isAccessAvailable = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.sponsorsMode) {
      case SponsorsMode.CREATE:
        return createSponsors();
      case SponsorsMode.ABOUT:
        return defaultWidget();
      case SponsorsMode.EDIT:
        return editWidget();
      default:
        return defaultWidget();
    }
  }

  Widget editWidget() {
    return Column(
      children: [
        Row(
          children: [
            titleWidget(),
            SizedBox(
              width: 30,
            ),
            Offstage(
              offstage: widget.timebankModel.sponsors.length >= 5 ||
                  !isOwnerCreator(widget.timebankModel,
                      SevaCore.of(context).loggedInUser.sevaUserID),
              child: addIconWidget(widget.timebankModel),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Offstage(
          offstage: widget.timebankModel.sponsors == null ||
              widget.timebankModel.sponsors.length < 1,
          child: Column(
            children: List.generate(
              widget.timebankModel.sponsors.length > 5
                  ? 5
                  : widget.timebankModel.sponsors.length,
              (index) => Container(
                margin: EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    InkWell(
                      onTap: isOwnerCreator(widget.timebankModel,
                              SevaCore.of(context).loggedInUser.sevaUserID)
                          ? () {
                              return showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  content: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.12,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          onTap: () async {
                                            indexPosition = index;
                                            getLogoFile(widget.timebankModel);
                                            // String _path;
                                            // // PickedFile image =
                                            // //     await ImagePicker().getImage(source: ImageSource.gallery);
                                            // try {
                                            //   _path = await FilePicker.getFilePath(
                                            //       type: FileType.custom, allowedExtensions: ['jpg','jpeg','gif','png']);
                                            // } on PlatformException catch (e) {
                                            //   throw e;
                                            // }
                                            //
                                            // String _extension =
                                            //     pathExt.extension(_path).split('?').first;
                                            // log("exten ${_extension}");
                                            //
                                            // if (_extension == 'gif' || _extension == '.gif') {
                                            //   showProgressDialog(context);
                                            //   uploadImage(File(_path), widget.timebankModel);
                                            // } else {
                                            //   cropImage(_path, widget.timebankModel);
                                            // }

                                            // Navigator.of(dialogContext).pop();
                                          },
                                          title: Text(S.of(context).edit),
                                          trailing: Icon(Icons.edit),
                                        ),
                                        ListTile(
                                          onTap: () {
                                            indexPosition = index;

                                            showUploadImageDialog(
                                                context: context,
                                                imageUrl: widget.timebankModel
                                                    .sponsors[index].logo,
                                                timebankModel:
                                                    widget.timebankModel);
                                          },
                                          title: Text(L.of(context).edit_name),
                                          trailing: Icon(Icons.edit),
                                        ),
                                        ListTile(
                                          onTap: () async {
                                            widget.timebankModel.sponsors
                                                .removeAt(index);
                                            widget.onRemoved(
                                                widget.timebankModel);
                                            Navigator.of(dialogContext).pop();
                                          },
                                          title: Text(S.of(context).delete),
                                          trailing: Icon(Icons.delete),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                      child: Text(S.of(context).cancel),
                                    ),
                                  ],
                                ),
                              );
                            }
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                              widget.timebankModel.sponsors[index].logo ??
                                  defaultUserImageURL,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(widget.timebankModel.sponsors[index].name)
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget defaultWidget() {
    return Offstage(
      offstage: widget.timebankModel.sponsors == null ||
          widget.timebankModel.sponsors.length < 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget(),
          SizedBox(
            height: 20,
          ),
          Column(
            children: List.generate(
              widget.timebankModel.sponsors.length > 5
                  ? 5
                  : widget.timebankModel.sponsors.length,
              (index) => Container(
                margin: EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            widget.timebankModel.sponsors[index].logo ??
                                defaultUserImageURL,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(widget.timebankModel.sponsors[index].name)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createSponsors() {
    return Column(
      children: [
        Row(
          children: [
            titleWidget(),
            SizedBox(
              width: 30,
            ),
            Offstage(
                offstage: widget.timebankModel.sponsors.length >= 5,
                child: addIconWidget(widget.timebankModel)),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Offstage(
          offstage: widget.timebankModel.sponsors == null ||
              widget.timebankModel.sponsors.length < 1,
          child: Column(
            children: List.generate(
              widget.timebankModel.sponsors.length > 5
                  ? 5
                  : widget.timebankModel.sponsors.length,
              (index) => Container(
                margin: EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        return showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            content: Container(
                              width: MediaQuery.of(context).size.width * 0.12,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    onTap: () async {
                                      indexPosition = index;
                                      getLogoFile(widget.timebankModel);
                                    },
                                    title: Text(S.of(context).edit),
                                    trailing: Icon(Icons.edit),
                                  ),
                                  ListTile(
                                    onTap: () async {
                                      widget.timebankModel.sponsors
                                          .removeAt(index);
                                      widget.onRemoved(widget.timebankModel);
                                      Navigator.of(dialogContext).pop();
                                    },
                                    title: Text(S.of(context).delete),
                                    trailing: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: Text(S.of(context).cancel),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                              widget.timebankModel.sponsors[index].logo ??
                                  defaultUserImageURL,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(widget.timebankModel.sponsors[index].name)
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget titleWidget() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Text(
       L.of(context).sponsored_by,
        style: TextStyle(
          color: HexColor('#766FE0'),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget addIconWidget(TimebankModel timebankModel) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: IconButton(
        icon: Icon(
          Icons.add_circle,
          color: FlavorConfig.values.theme.primaryColor,
        ),
        onPressed: () async {
          getLogoFile(timebankModel);
          // String _path;
          // // PickedFile image =
          // //     await ImagePicker().getImage(source: ImageSource.gallery);
          // try {
          //   _path = await FilePicker.getFilePath(
          //       type: FileType.custom, allowedExtensions: ['jpg','jpeg','gif','png']);
          // } on PlatformException catch (e) {
          //   throw e;
          // }
          // String _extension =
          //     pathExt.extension(_path).split('?').first;
          // log("exten ${_extension}");
          //
          // if (_extension == 'gif' || _extension == '.gif') {
          //   showProgressDialog(context);
          //   uploadImage(File(_path), timebankModel);
          // } else {
          //   cropImage(_path, timebankModel);
          // }
        },
      ),
    );
  }

  Future<String> uploadImage(dynamic file, TimebankModel timebankModel) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    String imageURL;
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('sponsorsLogos')
        .child(
            SevaCore.of(context).loggedInUser.email + timestampString + '.jpg');

    StorageUploadTask uploadTask = ref.putFile(
      file,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'Timebank Logo'},
      ),
    );

    imageURL = await (await uploadTask.onComplete).ref.getDownloadURL();

    await profanityCheck(
        imageURL: imageURL,
        storagePath: ref.path,
        timebankModel: timebankModel);
    return imageURL;
  }

  Future<void> profanityCheck(
      {String imageURL,
      @required String storagePath,
      TimebankModel timebankModel}) async {
    ProfanityImageModel profanityImageModel = ProfanityImageModel();
    ProfanityStatusModel profanityStatusModel = ProfanityStatusModel();
    // _newsImageURL = imageURL;
    profanityImageModel = await checkProfanityForImage(
      imageUrl: imageURL,
      storagePath: storagePath,
    );

    if (profanityImageModel == null) {
      if (dialogContext != null) {
        Navigator.of(dialogContext).pop();
      }
      showFailedLoadImage(context: context).then((value) {
        Navigator.of(context).pop();
      });
    } else {
      profanityStatusModel =
          await getProfanityStatus(profanityImageModel: profanityImageModel);

      if (profanityStatusModel.isProfane) {
        if (dialogContext != null) {
          Navigator.of(dialogContext).pop();
        }
        showProfanityImageAlert(
                context: context, content: profanityStatusModel.category)
            .then((status) {
          if (status == 'Proceed') {
            FirebaseStorage.instance
                .getReferenceFromUrl(imageURL)
                .then((reference) {
              reference.delete();
            });
          }
        });
      } else {
        Navigator.of(dialogContext).pop();

        showUploadImageDialog(
            context: context, imageUrl: imageURL, timebankModel: timebankModel);
        // Navigator.of(context).pop();
      }
    }
  }

  BuildContext dialogContext;

  void showProgressDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(S.of(context).loading),
            content: LinearProgressIndicator(),
          );
        });
  }

  Future showUploadImageDialog(
      {BuildContext context,
      String imageUrl,
      TimebankModel timebankModel}) async {
    final profanityDetector = ProfanityDetector();
    GlobalKey<FormState> _formKey = GlobalKey();
    String name;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
           L.of(context).sponsor_name,
            style: TextStyle(fontSize: 15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration:
                      InputDecoration(hintText: S.of(context).enter_name),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  initialValue: indexPosition != null
                      ? timebankModel.sponsors[indexPosition].name
                      : '',
                  style: TextStyle(fontSize: 17.0),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  validator: (value) {
                    if (value.isEmpty) {
                      return S.of(context).validation_error_full_name;
                    } else if (profanityDetector.isProfaneString(value)) {
                      return S.of(context).profanity_text_alert;
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) => name = value,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  FlatButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      S.of(context).submit,
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        SponsorDataModel sponsorModel = SponsorDataModel(
                            name: name,
                            createdAt: DateTime.now().millisecondsSinceEpoch,
                            createdBy:
                                SevaCore.of(context).loggedInUser.sevaUserID,
                            logo: imageUrl);
                        if (indexPosition == null) {
                          timebankModel.sponsors.add(sponsorModel);
                        } else {
                          timebankModel.sponsors[indexPosition] = sponsorModel;
                        }
                        if (widget.sponsorsMode == SponsorsMode.CREATE) {
                          widget.onCreated(timebankModel);
                          Navigator.of(viewContext).pop();
                        } else {
                          await FirestoreManager.updateTimebank(
                                  timebankModel: timebankModel)
                              .then((onValue) {
                            Navigator.of(viewContext).pop();
                          });
                        }
                      }
                    },
                  ),
                  FlatButton(
                    child: Text(
                      S.of(context).cancel,
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(viewContext).pop(null);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void getLogoFile(TimebankModel timebankModel) async {
    String _path;
    // PickedFile image =
    //     await ImagePicker().getImage(source: ImageSource.gallery);
    try {
      _path = await FilePicker.getFilePath(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'gif', 'png', 'webp']);
    } on PlatformException catch (e) {
      throw e;
    }

    String _extension = pathExt.extension(_path).split('?').first;
    log("exten ${_extension}");

    if (_extension == 'gif' || _extension == '.gif') {
      showProgressDialog(context);
      uploadImage(File(_path), timebankModel);
    } else {
      cropImage(_path, timebankModel);
    }
  }

  Future cropImage(String path, TimebankModel timebankModel) async {
    File croppedFile;
    ImageCropper.cropImage(
      sourcePath: path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 200,
      maxHeight: 200,
    ).then((value) {
      if (value != null) {
        croppedFile = value;
        showProgressDialog(context);
        uploadImage(croppedFile, timebankModel);
      }
    });
  }
}
