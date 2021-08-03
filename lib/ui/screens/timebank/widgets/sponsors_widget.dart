import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/image_picker/image_picker_dialog_mobile.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../../../../flavor_config.dart';

enum SponsorsMode { ABOUT, CREATE, EDIT }

class SponsorsWidget extends StatefulWidget {
  final TimebankModel timebankModel;
  final SponsorsMode sponsorsMode;
  final Function(TimebankModel timebankModel) onCreated;
  final Function(TimebankModel timebankModel) onRemoved;
  final Color titleColor;

  SponsorsWidget(
      {this.timebankModel,
      @required this.sponsorsMode,
      this.onCreated,
      this.onRemoved,
      this.titleColor});

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
                  !isMemberAnAdmin(widget.timebankModel,
                      SevaCore.of(context).loggedInUser.sevaUserID),
              child: addIconWidget(widget.timebankModel, context),
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
                child: InkWell(
                  onTap: isMemberAnAdmin(widget.timebankModel,
                          SevaCore.of(context).loggedInUser.sevaUserID)
                      ? () {
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
                                        chooseImage(
                                            context: context,
                                            timebankModel: widget.timebankModel,
                                            name: widget.timebankModel
                                                .sponsors[indexPosition].name);
                                      },
                                      title: Text(S.of(context).change_image),
                                      trailing: Icon(Icons.image),
                                    ),
                                    ListTile(
                                      onTap: () {
                                        indexPosition = index;
                                        Navigator.of(dialogContext).pop();

                                        showEnterNameDialog(
                                            context: context,
                                            timebankModel:
                                                widget.timebankModel);
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 15,
                                    bottom: 15,
                                  ),
                                  child: CustomTextButton(
                                    shape: StadiumBorder(),
                                    color: Colors.grey,
                                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: Text(
                                      S.of(context).cancel,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Europa',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                  child: sponsorItemWidget(
                      name: widget.timebankModel.sponsors[index].name,
                      logoUrl: widget.timebankModel.sponsors[index].logo),
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
              (index) => sponsorItemWidget(
                  name: widget.timebankModel.sponsors[index].name,
                  logoUrl: widget.timebankModel.sponsors[index].logo),
            ),
          ),
        ],
      ),
    );
  }

  Widget sponsorItemWidget({@required String name, @required String logoUrl}) {
    return Container(
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
                      onTap: () {},
                    ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(name)
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
                offstage: widget.timebankModel.sponsors != null &&
                    widget.timebankModel.sponsors.length >= 5,
                child: addIconWidget(widget.timebankModel, context)),
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

                                    chooseImage(
                                        context: context,
                                        timebankModel: widget.timebankModel,
                                        name: widget.timebankModel
                                            .sponsors[indexPosition].name);
                                  },
                                  title: Text(S.of(context).change_image),
                                  trailing: Icon(Icons.image),
                                ),
                                ListTile(
                                  onTap: () {
                                    indexPosition = index;
                                    Navigator.of(dialogContext).pop();

                                    showEnterNameDialog(
                                        context: context,
                                        timebankModel: widget.timebankModel);
                                  },
                                  title: Text(S.of(context).edit_name),
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
                        name: widget.timebankModel.sponsors[index].name,
                        logoUrl: widget.timebankModel.sponsors[index].logo),
                  )),
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
          color: widget.titleColor ?? HexColor('#766FE0'),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget addIconWidget(TimebankModel timebankModel, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: IconButton(
        icon: Icon(
          Icons.add_circle,
          color: FlavorConfig.values.theme.primaryColor,
        ),
        onPressed: () async {
          showEnterNameDialog(context: context, timebankModel: timebankModel);
        },
      ),
    );
  }

  Future showEnterNameDialog(
      {BuildContext context, TimebankModel timebankModel}) async {
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
                      indexPosition == null
                          ? S.of(context).next
                          : S.of(context).save,
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                        color: Colors.white,
                        fontFamily: 'Europa',
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();

                        if (indexPosition == null) {
                          await addImageAlert(
                              timebankModel: timebankModel,
                              name: name,
                              context: context);

                          name = null;
                          Navigator.of(viewContext).pop();
                        } else {
                          timebankModel.sponsors[indexPosition].name = name;
                          indexPosition = null;
                          name = null;
                          widget.onCreated(timebankModel);
                          Navigator.of(viewContext).pop();
                        }
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

  Future addImageAlert(
      {BuildContext context,
      TimebankModel timebankModel,
      @required String name}) async {
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
            CustomElevatedButton(
              onPressed: () async {
                chooseImage(
                    context: context, timebankModel: timebankModel, name: name);
              },
              child: Text(S.of(context).choose_image),
            ),
            CustomTextButton(
                onPressed: () async {
                  SponsorDataModel sponsorModel = SponsorDataModel(
                      name: name,
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                      createdBy: SevaCore.of(context).loggedInUser.sevaUserID,
                      logo: null);
                  if (indexPosition == null) {
                    timebankModel.sponsors.add(sponsorModel);
                  } else {
                    timebankModel.sponsors[indexPosition] = sponsorModel;
                  }
                  indexPosition = null;

                  widget.onCreated(timebankModel);

                  Navigator.of(viewContext).pop();
                },
                child: Text(
                  S.of(context).skip,
                  style: TextStyle(color: Colors.red),
                ))
          ],
        );
      },
    );
  }

  void chooseImage(
      {BuildContext context, TimebankModel timebankModel, String name}) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return ImagePickerDialogMobile(
            imagePickerType: ImagePickerType.SPONSOR,
            onLinkCreated: (link) {
              SponsorDataModel sponsorModel = SponsorDataModel(
                  name: name,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  createdBy: SevaCore.of(context).loggedInUser.sevaUserID,
                  logo: link);
              if (indexPosition == null) {
                timebankModel.sponsors.add(sponsorModel);
              } else {
                timebankModel.sponsors[indexPosition] = sponsorModel;
              }

              widget.onCreated(timebankModel);
              indexPosition = null;

              Navigator.of(dialogContext).pop();
            },
          );
        });
  }
}
