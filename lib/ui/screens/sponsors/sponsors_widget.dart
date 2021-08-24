import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/image_picker/image_picker_dialog_mobile.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import '../../../flavor_config.dart';

enum SponsorsMode { ABOUT, CREATE, EDIT }

// ignore: must_be_immutable
class SponsorsWidget extends StatefulWidget {
  List<SponsorDataModel> sponsors;
  final SponsorsMode sponsorsMode;
  final Color textColor;
  final double textSize;
  final bool isAdminVerified;
  final Function(
    List<SponsorDataModel> sponsors,
    SponsorDataModel addedSponsors,
  ) onSponsorsAdded;
  final Function(dynamic error) onError;
  final Function(
    List<SponsorDataModel> sponsors,
    SponsorDataModel removedSponsors,
  ) onSponsorsRemoved;

  SponsorsWidget({
    @required this.sponsors,
    @required this.sponsorsMode,
    this.onSponsorsAdded,
    this.textColor = const Color(0xFFF766FE0),
    this.textSize = 18.0,
    this.onSponsorsRemoved,
    this.isAdminVerified = false,
    this.onError,
  });

  @override
  _SponsorsWidgetState createState() => _SponsorsWidgetState();
}

class _SponsorsWidgetState extends State<SponsorsWidget> {
  int indexPosition;
  String userId = '';
  SponsorDataModel removedSponsors;
  SponsorDataModel addedSponsors;
  StreamController<SponsorDataModel> imageDatacontroller =
      StreamController.broadcast();
  @override
  Widget build(BuildContext context) {
    userId = SevaCore.of(context).loggedInUser.sevaUserID;
    switch (widget.sponsorsMode) {
      case SponsorsMode.CREATE:
        return createSponsors();
      case SponsorsMode.ABOUT:
        return defaultWidget();
      case SponsorsMode.EDIT:
        return editWidget(context);
      default:
        return defaultWidget();
    }
  }

  Widget editWidget(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            titleWidget(),
            SizedBox(
              width: 30,
            ),
            Offstage(
              offstage: widget.sponsors == null ||
                      widget.sponsors.length >= 5 ||
                      widget.isAdminVerified
                  ? !widget.isAdminVerified
                  : false,
              child: addIconWidget(),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Offstage(
          offstage: widget.sponsors == null || widget.sponsors.length < 1,
          child: Column(
            children: getList(context),
          ),
        ),
      ],
    );
  }

  List<Widget> getList(BuildContext context) {
    return List.generate(
      widget.sponsors == null
          ? 0
          : widget.sponsors.length > 5
              ? 5
              : widget.sponsors.length,
      (index) => Container(
          margin: EdgeInsets.only(right: 10),
          child: sponsorItemWidget(
              onTap: () {
                return showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    content: Container(
                      width: MediaQuery.of(context).size.width * 0.12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            onTap: () {
                              indexPosition = index;
                              chooseImage(
                                context: context,
                                name: widget.sponsors != null ||
                                        widget.sponsors.isNotEmpty
                                    ? widget.sponsors[indexPosition].name
                                    : '',
                                isEdit: true,
                              );
                            },
                            title: Text(S.of(context).change_image),
                            trailing: Icon(Icons.image),
                          ),
                          ListTile(
                            onTap: () {
                              indexPosition = index;
                              Navigator.of(dialogContext).pop();
                              editNameDialog(context);
                            },
                            title: Text(S.of(context).edit),
                            trailing: Icon(Icons.edit),
                          ),
                          ListTile(
                            onTap: () async {
                              removedSponsors = widget.sponsors[index];
                              widget.sponsors.removeAt(index);
                              widget.onSponsorsRemoved(
                                  widget.sponsors, removedSponsors);
                              Navigator.of(dialogContext).pop();
                            },
                            title: Text(S.of(context).delete),
                            trailing: Icon(Icons.delete),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomTextButton(
                                shape: StadiumBorder(),
                                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                                color: Colors.grey,
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: Text(
                                  S.of(context).cancel,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Europa',
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              name: widget.sponsors[index].name,
              logoUrl: widget.sponsors[index].logo)),
    );
  }

  Widget defaultWidget() {
    return Offstage(
      offstage: widget.sponsors == null || widget.sponsors.length < 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget(),
          SizedBox(
            height: 20,
          ),
          Column(
            children: List.generate(
              widget.sponsors.length > 5 ? 5 : widget.sponsors.length,
              (index) => sponsorItemWidget(
                  name: widget.sponsors[index].name,
                  logoUrl: widget.sponsors[index].logo),
            ),
          ),
        ],
      ),
    );
  }

  Widget sponsorItemWidget({
    @required String name,
    @required String logoUrl,
    Function onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
                child: logoUrl != null
                    ? CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          logoUrl ?? defaultUserImageURL,
                        ),
                      )
                    : CustomAvatar(
                        name: name,
                        radius: 18,
                        color: FlavorConfig.values.theme.primaryColor,
                        foregroundColor: Colors.black,
                        onTap: onTap,
                      ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(name)
          ],
        ),
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
                offstage:
                    widget.sponsors != null && widget.sponsors.length >= 5,
                child: addIconWidget()),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Offstage(
          offstage: widget.sponsors == null || widget.sponsors.length < 1,
          child: Column(
            children: List.generate(
              widget.sponsors == null
                  ? 0
                  : widget.sponsors.length > 5
                      ? 5
                      : widget.sponsors.length,
              (index) => Container(
                margin: EdgeInsets.only(right: 10),
                child: InkWell(
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
                                  Navigator.of(dialogContext).pop();
                                  logger.wtf(
                                      'create: ${widget.sponsors[indexPosition].name}');
                                  chooseImage(
                                      context: context,
                                      name: widget.sponsors[indexPosition].name,
                                      isEdit: false);
                                },
                                title: Text(S.of(context).change_image),
                                trailing: Icon(Icons.image),
                              ),
                              ListTile(
                                onTap: () {
                                  indexPosition = index;
                                  Navigator.of(dialogContext).pop();
                                  editNameDialog(context);
                                },
                                title: Text(S.of(context).edit_name),
                                trailing: Icon(Icons.edit),
                              ),
                              ListTile(
                                onTap: () async {
                                  removedSponsors = widget.sponsors[index];
                                  widget.sponsors.removeAt(index);
                                  widget.onSponsorsRemoved(
                                      widget.sponsors, removedSponsors);
                                  Navigator.of(dialogContext).pop();
                                },
                                title: Text(S.of(context).delete),
                                trailing: Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          CustomTextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: Text(
                              S.of(context).cancel,
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: sponsorItemWidget(
                      name: widget.sponsors[index].name,
                      logoUrl: widget.sponsors[index].logo),
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
        S.of(context).sponsored_by,
        style: TextStyle(
          color: widget.textColor, // ?? HexColor('#766FE0'),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget addIconWidget() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: IconButton(
        icon: Icon(
          Icons.add_circle,
          color: FlavorConfig.values.theme.primaryColor,
        ),
        onPressed: () async {
          showEnterNameDialog(context);
        },
      ),
    );
  }

  Future showEnterNameDialog(BuildContext context) async {
    final profanityDetector = ProfanityDetector();
    GlobalKey<FormState> _formKey = GlobalKey();
    String name;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: SizedBox(
            height: 216,
            width: MediaQuery.of(context).size.width - 60,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5, bottom: 20),
                  // width: 75,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 50,
                      height: 50,
                      child: InkWell(
                        onTap: () {
                          try {
                            showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return ImagePickerDialogMobile(
                                    imagePickerType: ImagePickerType.SPONSOR,
                                    onLinkCreated: (link) {
                                      // try {
                                      SponsorDataModel sponsorModel =
                                          SponsorDataModel(
                                        name: '',
                                        createdAt: DateTime.now()
                                            .millisecondsSinceEpoch,
                                        createdBy: userId,
                                        logo: link,
                                      );
                                      imageDatacontroller.add(sponsorModel);
                                      //   if (indexPosition == null) {
                                      //     if (widget.sponsors == null) {
                                      //       List<SponsorDataModel> x = [];
                                      //       x.add(sponsorModel);
                                      //       widget.sponsors = x;
                                      //       addedSponsors = sponsorModel;
                                      //     } else {
                                      //       widget.sponsors.add(sponsorModel);
                                      //       addedSponsors = sponsorModel;
                                      //     }
                                      //   } else {
                                      //     widget.sponsors[indexPosition] =
                                      //         sponsorModel;
                                      //     addedSponsors =
                                      //         widget.sponsors[indexPosition];
                                      //   }
                                      //   widget.onSponsorsAdded(
                                      //       widget.sponsors, addedSponsors);
                                      //   indexPosition = null;
                                      // } catch (e) {
                                      //   widget.onError(e);
                                      //   rethrow;
                                      // }
                                    },
                                  );
                                });
                          } catch (e) {
                            widget.onError(e);
                            rethrow;
                          }
                        },
                        child: StreamBuilder<SponsorDataModel>(
                          stream: imageDatacontroller.stream,
                          builder: (context, snapshot) {
                            return Image.network(
                              snapshot != null &&
                                      snapshot.data != null &&
                                      snapshot.data.logo != ''
                                  ? snapshot.data.logo
                                  : defaultCameraImageURL,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Sponsor Details',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Spacer(),
                          IconButton(
                            iconSize: 15,
                            icon: Icon(Icons.cancel,
                                size: 15, color: Colors.grey[400]),
                            onPressed: () => Navigator.of(viewContext).pop(),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: Colors.grey.shade200, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.of(context).name,
                                style: TextStyle(
                                  fontFamily: 'Europa',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Form(
                                key: _formKey,
                                child: SizedBox(
                                  height: 30,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: TextFormField(
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                        fontFamily: 'Europa',
                                      ),
                                      decoration: InputDecoration
                                          // .collapsed(
                                          //   border: InputBorder.none,
                                          //   hintText: 'Andreson Smith',
                                          //   hintStyle: TextStyle(
                                          //     fontFamily: 'Europa',
                                          //     fontSize: 12,
                                          //     color: Colors.grey[400],
                                          //   ),
                                          // ),
                                          (
                                        contentPadding:
                                            EdgeInsets.only(bottom: 8),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        hintText: 'Andreson Smith',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Europa',
                                          fontSize: 12,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      keyboardType: TextInputType.text,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      initialValue: indexPosition != null
                                          ? widget.sponsors[indexPosition].name
                                          : '',
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(50),
                                      ],
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return S
                                              .of(context)
                                              .validation_error_full_name;
                                        } else if (profanityDetector
                                            .isProfaneString(value)) {
                                          return S
                                              .of(context)
                                              .profanity_text_alert;
                                        } else {
                                          return null;
                                        }
                                      },
                                      onSaved: (value) => name = value,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 35),
                      StreamBuilder<Object>(
                          stream: imageDatacontroller.stream,
                          builder: (context, snapshot) {
                            return CustomTextButton(
                              shape: StadiumBorder(),
                              padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                              color: Theme.of(context).primaryColor,
                              // textColor: FlavorConfig.values.buttonTextColor,
                              child: Text(
                                'Add Sponser',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Europa',
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    if (indexPosition == null) {
                                      try {
                                        SponsorDataModel model = snapshot.data;
                                        if (model != null) {
                                          SponsorDataModel sponsorModel =
                                              SponsorDataModel(
                                            name: name,
                                            createdAt: DateTime.now()
                                                .millisecondsSinceEpoch,
                                            createdBy: userId,
                                            logo: model.logo,
                                          );
                                          if (indexPosition == null) {
                                            if (widget.sponsors == null) {
                                              List<SponsorDataModel> x = [];
                                              x.add(sponsorModel);
                                              widget.sponsors = x;
                                              addedSponsors = sponsorModel;
                                            } else {
                                              widget.sponsors.add(sponsorModel);
                                              addedSponsors = sponsorModel;
                                            }
                                          } else {
                                            widget.sponsors[indexPosition] =
                                                sponsorModel;
                                            addedSponsors =
                                                widget.sponsors[indexPosition];
                                          }

                                          widget.onSponsorsAdded(
                                              widget.sponsors, addedSponsors);
                                          indexPosition = null;
                                          imageDatacontroller.add(null);
                                        } else {
                                          SponsorDataModel sponsorModel =
                                              SponsorDataModel(
                                            name: name,
                                            createdAt: DateTime.now()
                                                .millisecondsSinceEpoch,
                                            createdBy: userId,
                                            logo: '',
                                          );
                                          if (indexPosition == null) {
                                            if (widget.sponsors == null) {
                                              List<SponsorDataModel> x = [];
                                              x.add(sponsorModel);
                                              widget.sponsors = x;
                                              addedSponsors = sponsorModel;
                                            } else {
                                              widget.sponsors.add(sponsorModel);
                                              addedSponsors = sponsorModel;
                                            }
                                          } else {
                                            widget.sponsors[indexPosition] =
                                                sponsorModel;
                                            addedSponsors =
                                                widget.sponsors[indexPosition];
                                          }
                                          widget.onSponsorsAdded(
                                              widget.sponsors, addedSponsors);
                                          indexPosition = null;
                                          imageDatacontroller.add(null);
                                        }
                                        Navigator.of(viewContext).pop();
                                      } catch (e) {
                                        widget.onError(e);
                                        rethrow;
                                      }
                                    }
                                  }
                                } catch (e) {
                                  widget.onError(e);
                                  rethrow;
                                }
                              },
                            );
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future editNameDialog(
    BuildContext context,
  ) async {
    final profanityDetector = ProfanityDetector();
    GlobalKey<FormState> _formKey = GlobalKey();
    String name;
    return showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            S.of(context).sponsor_name,
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
                      ? widget.sponsors[indexPosition].name
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
                  CustomTextButton(
                    shape: StadiumBorder(),
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Colors.grey,
                    child: Text(
                      S.of(context).cancel,
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                        color: Colors.white,
                        fontFamily: 'Europa',
                      ),
                    ),
                    onPressed: () {
                      indexPosition = null;
                      name = null;
                      Navigator.of(viewContext).pop();
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CustomTextButton(
                    shape: StadiumBorder(),
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      S.of(context).save,
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                        fontFamily: 'Europa',
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      try {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          // if (indexPosition == null) {
                          //   try {
                          //     SponsorDataModel sponsorModel = SponsorDataModel(
                          //         name: name,
                          //         createdAt:
                          //             DateTime.now().millisecondsSinceEpoch,
                          //         createdBy: SevaCore.of(context)
                          //             .loggedInUser
                          //             .sevaUserID,
                          //         logo: null);
                          //     if (indexPosition == null) {
                          //       if (widget.sponsors == null) {
                          //         List<SponsorDataModel> x = [];
                          //         x.add(sponsorModel);
                          //         widget.sponsors = x;
                          //         addedSponsors = sponsorModel;
                          //         // sponsors.add(sponsorModel);
                          //       } else {
                          //         widget.sponsors.add(sponsorModel);
                          //         addedSponsors = sponsorModel;
                          //       }
                          //     } else {
                          //       widget.sponsors[indexPosition] = sponsorModel;
                          //       addedSponsors = widget.sponsors[indexPosition];
                          //     }
                          //     indexPosition = null;
                          //     widget.onSponsorsAdded(
                          //         widget.sponsors, addedSponsors);
                          //     // Navigator.of(viewContext).pop();
                          //   } catch (e) {
                          //     widget.onError(e);
                          //     rethrow;
                          //   }
                          //   name = null;
                          // } else {
                          widget.sponsors[indexPosition].name = name;
                          addedSponsors = widget.sponsors[indexPosition];
                          widget.onSponsorsAdded(
                              widget.sponsors, addedSponsors);
                          indexPosition = null;
                          name = null;
                          // Navigator.of(viewContext).pop();
                          // }
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      } catch (e) {
                        widget.onError(e);
                        rethrow;
                      }
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

  Future addImageAlert({BuildContext context, @required String name}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            S.of(context).add_sponsor_image,
            style: TextStyle(fontSize: 15.0),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 15,
              ),
              child: CustomTextButton(
                shape: StadiumBorder(),
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                color: Theme.of(context).accentColor,
                onPressed: () async {
                  try {
                    SponsorDataModel sponsorModel = SponsorDataModel(
                        name: name,
                        createdAt: DateTime.now().millisecondsSinceEpoch,
                        createdBy: SevaCore.of(context).loggedInUser.sevaUserID,
                        logo: null);
                    if (indexPosition == null) {
                      if (widget.sponsors == null) {
                        List<SponsorDataModel> x = [];
                        x.add(sponsorModel);
                        widget.sponsors = x;
                        addedSponsors = sponsorModel;
                        // sponsors.add(sponsorModel);
                      } else {
                        widget.sponsors.add(sponsorModel);
                        addedSponsors = sponsorModel;
                      }
                    } else {
                      widget.sponsors[indexPosition] = sponsorModel;
                      addedSponsors = widget.sponsors[indexPosition];
                    }
                    indexPosition = null;
                    widget.onSponsorsAdded(widget.sponsors, addedSponsors);

                    Navigator.of(viewContext).pop();
                  } catch (e) {
                    widget.onError(e);
                    rethrow;
                  }
                },
                child: Text(
                  S.of(context).skip,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Europa',
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 15,
                bottom: 15,
              ),
              child: CustomTextButton(
                shape: StadiumBorder(),
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  Navigator.of(viewContext).pop();
                  chooseImage(
                    context: context,
                    name: name,
                    isEdit: false,
                  );
                },
                child: Text(
                  S.of(context).choose_image,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Europa',
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void chooseImage({BuildContext context, String name, bool isEdit}) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ImagePickerDialogMobile(
          imagePickerType: ImagePickerType.SPONSOR,
          onLinkCreated: (link) {
            try {
              SponsorDataModel sponsorModel = SponsorDataModel(
                name: name,
                createdAt: DateTime.now().millisecondsSinceEpoch,
                createdBy: userId,
                logo: link,
              );
              if (indexPosition == null) {
                if (widget.sponsors == null) {
                  List<SponsorDataModel> x = [];
                  x.add(sponsorModel);
                  widget.sponsors = x;
                  addedSponsors = sponsorModel;
                } else {
                  widget.sponsors.add(sponsorModel);
                  addedSponsors = sponsorModel;
                }
              } else {
                widget.sponsors[indexPosition] = sponsorModel;
                addedSponsors = widget.sponsors[indexPosition];
              }
              widget.onSponsorsAdded(widget.sponsors, addedSponsors);
              indexPosition = null;
              if (isEdit) {
                Navigator.of(dialogContext).pop();
              }
            } catch (e) {
              widget.onError(e);
              rethrow;
            }
          },
        );
      },
    );
  }
}
