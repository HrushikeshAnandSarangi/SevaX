import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/groupinvite_user_model.dart';
import 'package:sevaexchange/new_baseline/models/sponsored_group_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/components/sevaavatar/timebankcoverphoto.dart';

class TimebankCreate extends StatelessWidget {
  final String timebankId;
  final String communityCreatorId;
  TimebankCreate({@required this.timebankId, this.communityCreatorId});
  @override
  Widget build(BuildContext context) {
    return ExitWithConfirmation(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.5,
          // leading: BackButton(color: Colors.black54),
          title: Text(
            // 'Create a ${FlavorConfig.values.timebankTitle}',
            S.of(context).create_group,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        body: TimebankCreateForm(
          timebankId: timebankId,
          communityCreatorId: communityCreatorId,
        ),
      ),
    );
  }
}

// Create a Form Widget
class TimebankCreateForm extends StatefulWidget {
  final String timebankId;
  final String communityCreatorId;
  TimebankCreateForm({@required this.timebankId, this.communityCreatorId});
  @override
  TimebankCreateFormState createState() {
    return TimebankCreateFormState();
  }
}

// Create a corresponding State class. This class will hold the data related to
// the form.
class TimebankCreateFormState extends State<TimebankCreateForm> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<NewsCreateFormState>!
  final _formKey = GlobalKey<FormState>();
  var groupFound = false;
  TimebankModel timebankModel = TimebankModel({});
  TimebankModel parentTimebankModel = TimebankModel({});
  bool protectedVal = false;
  bool sponsored = false;
  GeoFirePoint location;
  String selectedAddress;
  TextEditingController searchTextController = TextEditingController();
  String errTxt;
  final nameNode = FocusNode();
  final aboutNode = FocusNode();
  final _textUpdates = StreamController<String>();
  final profanityDetector = ProfanityDetector();
  String duplicateGroupCheck = 'not_done';
  final _debouncer = Debouncer(milliseconds: 600);

  void initState() {
    super.initState();
    timebankModel.preventAccedentalDelete = true;
    globals.timebankAvatarURL = null;
    globals.timebankCoverURL = null;
    globals.addedMembersId = [];
    globals.addedMembersFullname = [];
    globals.addedMembersPhotoURL = [];
    selectedUsers = HashMap();
    // if ((FlavorConfig.appFlavor == Flavor.APP ||
    //     FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
    //   fetchCurrentlocation();
    // }
    getParentTimebank();
    // ignore: close_sinks
    searchTextController.addListener(() {
      _debouncer.run(() {
        String s = searchTextController.text;
        if (s.isEmpty) {
          setState(() {});
        } else {
          duplicateGroupCheck = 'not_done';
          SearchManager.searchGroupForDuplicate(
                  queryString: s.trim(),
                  communityId:
                      SevaCore.of(context).loggedInUser.currentCommunity)
              .then((groupFound) {
            if (groupFound) {
              setState(() {
                errTxt = S.of(context).group_exists;
              });
            } else {
              setState(() {
                groupFound = false;
                errTxt = null;
              });
            }
          }).whenComplete(() {
            setState(() {
              duplicateGroupCheck = 'done';
            });
          });
        }
      });
    });
  }

  Future<void> getParentTimebank() async {
    Future.delayed(Duration.zero, () async {
      parentTimebankModel = await FirestoreManager.getTimeBankForId(
          timebankId: widget.timebankId);
    });
    setState(() {});
  }

  HashMap<String, UserModel> selectedUsers = HashMap();
  String memberAssignment;

  void _writeToDB() {
    // _checkTimebankName();
    // if (!_exists) {

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    List<String> members = [SevaCore.of(context).loggedInUser.sevaUserID];
    selectedUsers.forEach((key, value) {
      members.add(value.sevaUserID);
    });
    Set<String> membersSet = members.toList().toSet();
    String id = Utils.getUuid();
    timebankModel.id = id;
    timebankModel.communityId =
        SevaCore.of(context).loggedInUser.currentCommunity;
    timebankModel.managedCreatorIds = [
      widget.communityCreatorId,
    ];
    timebankModel.creatorId = SevaCore.of(context).loggedInUser.sevaUserID;
    timebankModel.photoUrl = globals.timebankAvatarURL;
    timebankModel.cover_url = globals.timebankCoverURL;
    timebankModel.createdAt = timestamp;
    timebankModel.admins = [SevaCore.of(context).loggedInUser.sevaUserID];
    timebankModel.organizers = [SevaCore.of(context).loggedInUser.sevaUserID];
    timebankModel.emailId = SevaCore.of(context).loggedInUser.email;
    timebankModel.coordinators = [];
    timebankModel.members = membersSet.toList();
    timebankModel.children = [];
    timebankModel.balance = 0;
    timebankModel.protected = false;
    timebankModel.parentTimebankId = widget.timebankId;
    timebankModel.rootTimebankId = FlavorConfig.values.timebankId;
    timebankModel.address = selectedAddress;
    timebankModel.liveMode = !AppConfig.isTestCommunity;
    timebankModel.location =
        location == null ? GeoFirePoint(40.754387, -73.984291) : location;
    timebankModel.timebankConfigurations =
        parentTimebankModel.timebankConfigurations ??
            getNeighbourhoodPlanConfigurationModel();
    if (sponsored == true &&
        !isAccessAvailable(parentTimebankModel,
            SevaCore.of(context).loggedInUser.sevaUserID) &&
        parentTimebankModel.creatorId !=
            SevaCore.of(context).loggedInUser.sevaUserID) {
      timebankModel.sponsored = false;

      assembleAndSendRequest(
          creatorId: timebankModel.creatorId,
          timebankName: timebankModel.name,
          adminId: parentTimebankModel.creatorId,
          subTimebankId: timebankModel.id,
          targetTimebankId: parentTimebankModel.id,
          timebankPhotoUrl: timebankModel.photoUrl,
          creatorName: SevaCore.of(context).loggedInUser.fullname,
          creatorPhotoUrl: SevaCore.of(context).loggedInUser.photoURL,
          communityId: timebankModel.communityId);
    } else {
      timebankModel.sponsored = sponsored;
    }
    createTimebank(timebankModel: timebankModel);

    CollectionRef.communities
        .doc(SevaCore.of(context).loggedInUser.currentCommunity)
        .update(
      {
        "timebanks": FieldValue.arrayUnion([id]),
      },
    );
    sendInviteNotification();

    globals.timebankAvatarURL = null;
    globals.timebankCoverURL = null;
    globals.webImageUrl = null;
    globals.addedMembersId = [];
  }

  Map onActivityResult;

  @override
  Widget build(BuildContext context) {
    memberAssignment = "+ ${S.of(context).add_members}";
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: SingleChildScrollView(child: FadeAnimation(1.4, createSevaX)),
      ),
    );
  }

  Widget get createSevaX {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            S.of(context).group_subset,
            textAlign: TextAlign.center,
          ),
        ),
        Center(
            child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: <Widget>[
              TimebankCoverPhoto(),
              SizedBox(height: 10),
              Text(
                "${L.of(context).cover_picture_label_group}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 25),
              TimebankAvatar(),
              SizedBox(height: 5),
              Text(
                S.of(context).group_logo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              )
            ],
          ),
        )),
        headingText(S.of(context).name_your_group, true),
        TextFormField(
          textCapitalization: TextCapitalization.sentences,
          focusNode: nameNode,
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(aboutNode);
          },
          controller: searchTextController,
          onChanged: (value) {
            ExitWithConfirmation.of(context).fieldValues[1] = value;
          },
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            errorText: errTxt,
            hintText: S.of(context).timebank_name_hint,
          ),
          // keyboardType: TextInputType.multiline,
          // maxLines: 1,
          // inputFormatters: <TextInputFormatter>[
          //   WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9_ ]*"))
          // ],
          validator: (value) {
            if (value.isEmpty) {
              return S.of(context).validation_error_general_text;
            } else if (value.substring(0, 1).contains('_') &&
                !AppConfig.testingEmails.contains(AppConfig.loggedInEmail)) {
              return 'Creating community with "_" is not allowed';
            } else {
              timebankModel.name = value.trim();
              return null;
            }
          },
        ),
        headingText(S.of(context).about, true),
        TextFormField(
          textCapitalization: TextCapitalization.sentences,

          focusNode: aboutNode,
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          textInputAction: TextInputAction.done,
          decoration:
              InputDecoration(hintText: S.of(context).bit_more_about_group),
          // keyboardType: TextInputType.multiline,
          maxLines: 1,
          onChanged: (value) {
            ExitWithConfirmation.of(context).fieldValues[2] = value;
          },
          validator: (value) {
            if (value.isEmpty) {
              return S.of(context).validation_error_general_text;
            }
            timebankModel.missionStatement = value;
          },
        ),
        Row(
          children: <Widget>[
            headingText(S.of(context).private_group, false),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 10, 0, 0),
              child: infoButton(
                context: context,
                key: GlobalKey(),
                type: InfoType.PRIVATE_GROUP,
              ),
            ),
            TransactionsMatrixCheck(
              upgradeDetails: AppConfig.upgradePlanBannerModel.private_groups,
              comingFrom: ComingFrom.Groups,
              transaction_matrix_type: "private_groups",
              child: ConfigurationCheck(
                actionType: 'create_private_group',
                role: memberType(parentTimebankModel,
                    SevaCore.of(context).loggedInUser.sevaUserID),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 10, 0, 0),
                  child: Checkbox(
                    value: timebankModel.private,
                    onChanged: (bool value) {
                      setState(() {
                        timebankModel.private = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            headingText(S.of(context).prevent_accidental_delete, false),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 10, 0, 0),
              child: Checkbox(
                value: timebankModel.preventAccedentalDelete,
                onChanged: (bool value) {
                  setState(() {
                    timebankModel.preventAccedentalDelete = value;
                  });
                },
              ),
            ),
          ],
        ),
        // tappableInviteMembers,
        headingText(S.of(context).is_pin_at_right_place, false),
        Center(
          child: LocationPickerWidget(
            selectedAddress: selectedAddress,
            location: location,
            onChanged: (LocationDataModel dataModel) {
              setState(() {
                location = dataModel.geoPoint;
                this.selectedAddress = dataModel.location;
              });
            },
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: <Widget>[
            headingText(S.of(context).save_as_sponsored, false),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
              child: infoButton(
                context: context,
                key: GlobalKey(),
                type: InfoType.SPONSORED,
              ),
            ),
            Column(
              children: <Widget>[
                Divider(),
                TransactionsMatrixCheck(
                  upgradeDetails:
                      AppConfig.upgradePlanBannerModel.sponsored_groups,
                  transaction_matrix_type: "sponsored_groups",
                  comingFrom: ComingFrom.Groups,
                  child: ConfigurationCheck(
                    actionType: 'create_endorsed_group',
                    role: memberType(parentTimebankModel,
                        SevaCore.of(context).loggedInUser.sevaUserID),
                    child: Checkbox(
                      value: sponsored,
                      onChanged: (bool value) {
                        setState(() {
                          sponsored = !sponsored;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            alignment: Alignment.center,
            child: FutureBuilder<Object>(
              future: getTimeBankForId(timebankId: widget.timebankId),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Text(S.of(context).general_stream_error);
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Offstage();
                TimebankModel parentTimebank = snapshot.data;
                return CustomElevatedButton(
                  // color: Colors.blue,
                  onPressed: () {
                    if (errTxt != null ||
                        errTxt != "" ||
                        duplicateGroupCheck == 'not_done') {}
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    //if (location != null) {
                    if (_formKey.currentState.validate() &&
                        (errTxt == null || errTxt == "") &&
                        duplicateGroupCheck == 'done') {
//
//                            // If the form is valid, we want to show a Snackbar
                      _writeToDB();
//                            // return;
                      try {
                        parentTimebank.children.add(timebankModel.id);
                      } catch (e) {
                        FirebaseCrashlytics.instance.log(e.toString());
                      }
                      updateTimebank(timebankModel: parentTimebank);
                      Navigator.pop(context);
                    } else {
                      FocusScope.of(context).requestFocus(nameNode);
                    }
                  },

                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      S.of(context).create_group,
                      style: Theme.of(context).primaryTextTheme.button,
                    ),
                  ),
                  textColor: Colors.blue,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget headingText(String name, bool isMandatory) {
    if (isMandatory) {
      name = name + "*";
    }
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void sendInviteNotification() {
//    globals.addedMembersId.forEach((m) {
//      members.add(m);
//    });
    if (selectedUsers.length > 0) {
      selectedUsers.forEach((key, user) async {
        GroupInviteUserModel groupInviteUserModel = GroupInviteUserModel(
          timebankId: widget.timebankId,
          timebankName: timebankModel.name,
          timebankImage: timebankModel.photoUrl,
          aboutTimebank: timebankModel.missionStatement,
          adminName: SevaCore.of(context).loggedInUser.fullname,
          groupId: timebankModel.id,
        );

        NotificationsModel notification = NotificationsModel(
            id: utils.Utils.getUuid(),
            timebankId: widget.timebankId,
            data: groupInviteUserModel.toMap(),
            isRead: false,
            type: NotificationType.GroupJoinInvite,
            communityId: SevaCore.of(context).loggedInUser.currentCommunity,
            senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
            targetUserId: user.sevaUserID);

        await CollectionRef.users
            .doc(user.email)
            .collection("notifications")
            .doc(notification.id)
            .set(notification.toMap());
      });
    }
  }

  void addVolunteers() async {
    onActivityResult = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectMembersInGroup(
          timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
          userSelected:
              selectedUsers == null ? selectedUsers = HashMap() : selectedUsers,
          userEmail: SevaCore.of(context).loggedInUser.email,
          listOfalreadyExistingMembers: [],
        ),
      ),
    );

    if (onActivityResult != null &&
        onActivityResult.containsKey("membersSelected")) {
      selectedUsers = onActivityResult['membersSelected'];
      log("$selectedUsers");
      setState(() {
        if (selectedUsers.length == 0)
          memberAssignment = S.of(context).assign_to_volunteers;
        else
          memberAssignment =
              "${selectedUsers.length} ${S.of(context).volunteers_selected(selectedUsers.length)}";
      });
    } else {
      //no users where selected
    }
  }

  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value.length == 0) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }

  Widget get tappableInviteMembers {
    return (FlavorConfig.appFlavor == Flavor.APP ||
            FlavorConfig.appFlavor == Flavor.SEVA_DEV)
        ? GestureDetector(
            onTap: () async {
              addVolunteers();
            },
            child: Padding(
              padding: EdgeInsets.only(top: 15),
              child: Text(
                '${S.of(context).invite} +',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          )
        : Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: CustomTextButton(
              onPressed: () async {
                addVolunteers();
              },
              child: Text(
                memberAssignment,
                style: TextStyle(fontSize: 16.0, color: Colors.blue),
              ),
            ));
  }

  // void fetchCurrentlocation() {
  //   Location().getLocation().then((onValue) {
  //     location = GeoFirePoint(onValue.latitude, onValue.longitude);
  //     LocationUtility()
  //         .getFormattedAddress(
  //       location.latitude,
  //       location.longitude,
  //     )
  //         .then((address) {
  //       setState(() {
  //         this.selectedAddress = address;
  //       });
  //     });
  //   });
  // }

  void dispose() {
    super.dispose();
    _textUpdates.close();
  }
}

Future assembleAndSendRequest({
  String creatorId,
  String timebankName,
  String subTimebankId,
  String targetTimebankId,
  String adminId,
  String communityId,
  String timebankPhotoUrl,
  String timebankCoverUrl,
  String creatorName,
  String creatorPhotoUrl,
}) async {
  var sponsoredRequesrModel = _assembleSponsoredRequestModel(
      creatorId: creatorId,
      timebankName: timebankName,
      subtimebankId: subTimebankId,
      timebankPhotoUrl: timebankPhotoUrl,
      timebankCoverUrl: timebankCoverUrl,
      creatorName: creatorName,
      creatorPhotoUrl: creatorPhotoUrl);

  var notification = _assembleNotificationForSponsorRequest(
    sponsoredGroupModel: sponsoredRequesrModel,
    adminId: adminId,
    creatorId: creatorId,
    targetTimebankId: targetTimebankId,
    communityId: communityId,
  );

  await createAndSendSponserRequest(
    sponsoredGroupModel: sponsoredRequesrModel,
    notification: notification,
    targetTimebankId: targetTimebankId,
  ).commit();
}

NotificationsModel _assembleNotificationForSponsorRequest({
  String adminId,
  SponsoredGroupModel sponsoredGroupModel,
  String targetTimebankId,
  String creatorId,
  String communityId,
}) {
  return NotificationsModel(
    timebankId: targetTimebankId,
    id: sponsoredGroupModel.notificationId,
    targetUserId: adminId,
    isRead: false,
    isTimebankNotification: true,
    senderUserId: creatorId,
    type: NotificationType.APPROVE_SPONSORED_GROUP_REQUEST,
    data: sponsoredGroupModel.toMap(),
    communityId: communityId,
  );
}

WriteBatch createAndSendSponserRequest({
  String targetTimebankId,
  NotificationsModel notification,
  SponsoredGroupModel sponsoredGroupModel,
}) {
  WriteBatch batchWrite = CollectionRef.batch;
  batchWrite.set(
      CollectionRef.timebank
          .doc(
            targetTimebankId,
          )
          .collection("notifications")
          .doc(notification.id),
      (notification..isTimebankNotification = true).toMap());
  return batchWrite;
}

SponsoredGroupModel _assembleSponsoredRequestModel({
  String creatorId,
  String creatorName,
  String creatorPhotoUrl,
  String subtimebankId,
  String timebankName,
  String timebankPhotoUrl,
  String timebankCoverUrl,
}) {
  return SponsoredGroupModel(
    timebankId: subtimebankId,
    timebankTitle: timebankName,
    creatorName: creatorName,
    userPhotoUrl: creatorPhotoUrl,
    timebankPhotUrl: timebankPhotoUrl,
    timebankCoverUrl: timebankCoverUrl,
    timestamp: DateTime.now().millisecondsSinceEpoch,
    creatorId: creatorId,
    notificationId: utils.Utils.getUuid(),
  );
}
