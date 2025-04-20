import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/change_ownership_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/user_exit_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/switch_timebank.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/user_profile_image.dart';

import '../../../labels.dart';
import '../../core.dart';

class TransferGroupOwnerShip extends StatefulWidget {
  final String timebankId;
  final TimebankModel timebankModel;

  TransferGroupOwnerShip({
    required this.timebankId,
    required this.timebankModel,
  });

  @override
  _TransferGroupOwnerShipState createState() => _TransferGroupOwnerShipState();
}

class _TransferGroupOwnerShipState extends State<TransferGroupOwnerShip> {
  late SuggestionsController controller;
  TextEditingController _textEditingController = TextEditingController();
  List<String> groupMembersList = [];
  UserModel? selectedNewOwner;
  List<String> allItems = [];
  late List<String> admins;
  late List<String> organizers;
  late List<String> members;
  late TimebankModel tbmodel;
  List<Future> futures = [];
  BuildContext? parentContext;
  String user_error = '';
  bool dataLoaded = false;
  List<String> invtitedUsers = [];

  @override
  void initState() {
    super.initState();
    controller = SuggestionsController();
    getMembersList();
  }

  void getMembersList() {
    FirestoreManager.getTimebankIdStream(
      timebankId: widget.timebankId,
    ).then((onValue) {
      setState(() {
        dataLoaded = true;
        tbmodel = onValue;
        admins = onValue.admins;
        organizers = onValue.organizers;
        members = onValue.members;
        allItems.addAll(admins);
        allItems.addAll(organizers);
        allItems.addAll(members);
        groupMembersList = allItems;
        logger.d(groupMembersList);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios),
        ),
//      automaticallyImplyLeading: true,
        title: Text(
          S.of(context).change_ownership,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Europa'),
        ),
        centerTitle: true,
      ),
      body: !dataLoaded
          ? LoadingIndicator()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      SevaCore.of(context).loggedInUser.fullname ?? '',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Europa',
                          fontWeight: FontWeight.bold,
                          color: FlavorConfig.values.theme!.primaryColor),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: S.of(context).changing_ownership_of + ' of ',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Europa',
                            ),
                          ),
                          TextSpan(
                            text: tbmodel.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Europa',
                            ),
                          ),
                          TextSpan(
                            text: S.of(context).to_other_admin,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Europa',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    //getDataList(ownerGroupsArr),
                    timeBankOrGroupCard(tbmodel.name),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      S.of(context).transfer_to,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Europa',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      S.of(context).search_by_email_name,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Europa',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    searchUser(),
                    SizedBox(
                      height: 15,
                    ),
                    if (selectedNewOwner == null)
                      Container()
                    else
                      ListTile(
                          leading: UserProfileImage(
                            photoUrl: selectedNewOwner!.photoURL!,
                            email: selectedNewOwner!.email!,
                            userId: selectedNewOwner!.sevaUserID!,
                            height: 50,
                            width: 50,
                            timebankModel: tbmodel,
                          ),
                          title: Text(selectedNewOwner!.fullname ?? '')),
                    SizedBox(
                      height: 15,
                    ),
                    optionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget optionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        CustomTextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            S.of(context).cancel,
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa'),
          ),
          textColor: Colors.grey,
        ),
        CustomTextButton(
          child: Text(S.of(context).change,
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa')),
          textColor: FlavorConfig.values.theme!.primaryColor,
          onPressed: () async {
            if (selectedNewOwner == null) {
              setState(() {
                user_error = S.of(context).select_user;
              });
            }
            {
              showProgressDialog(S.of(context).changing_ownership_of +
                  ' ' +
                  S.of(context).please_wait);
              Map<String, dynamic> responseObj =
                  await checkChangeOwnershipStatus(
                sevauserid: SevaCore.of(context).loggedInUser.sevaUserID!,
                timebankId: tbmodel.id,
              );

              if (responseObj['transferable'] == true) {
                if (tbmodel.admins != null &&
                    (tbmodel.admins.contains(
                            SevaCore.of(context).loggedInUser.sevaUserID) ||
                        tbmodel.organizers.contains(
                            SevaCore.of(context).loggedInUser.sevaUserID))) {
                  await CollectionRef.timebank.doc(tbmodel.id).update(
                    {
                      "admins": FieldValue.arrayRemove(
                          [SevaCore.of(context).loggedInUser.sevaUserID]),
                      "organizers": FieldValue.arrayRemove(
                          [SevaCore.of(context).loggedInUser.sevaUserID]),
                    },
                  );
                }

                await CollectionRef.timebank.doc(tbmodel.id).update(
                  {
                    "creator_id": selectedNewOwner!.sevaUserID,
                    "email_id": selectedNewOwner!.email,
                    "admins":
                        FieldValue.arrayUnion([selectedNewOwner!.sevaUserID]),
                    "organizers":
                        FieldValue.arrayUnion([selectedNewOwner!.sevaUserID]),
                    "members":
                        FieldValue.arrayUnion([selectedNewOwner!.sevaUserID]),
                  },
                );
                sendNotifications();
              } else if (responseObj['tasksCheck'] == false) {
                if (progressContext != null) {
                  Navigator.pop(progressContext!);
                }
                dialogBox(
                    message:
                        S.of(context).change_ownership_pending_task_message);
              } else if (responseObj['transferable'] == false) {
                //
                if (progressContext != null) {
                  Navigator.pop(progressContext!);
                }
                getErrorDialog(context);
              } else {
                if (progressContext != null) {
                  Navigator.pop(progressContext!);
                }
                getErrorDialog(context);
                Navigator.of(context).pop();
              }
            }
          },
        )
      ],
    );
  }

  BuildContext? progressContext;
  void showProgressDialog(String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          progressContext = createDialogContext;
          return AlertDialog(
            title: Text(message),
            content: LinearProgressIndicator(),
          );
        });
  }

  void dialogBox({String? message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Text(message!),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            CustomTextButton(
              child: Text(S.of(context).close),
              textColor: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget searchUser() {
    return TypeAheadField<UserModel>(
      suggestionsCallback: (pattern) async {
        return await SearchManager.searchForUserWithTimebankIdFuture(
            queryString: pattern, validItems: groupMembersList);
      },
      itemBuilder: (context, suggestion) {
        return suggestion.sevaUserID !=
                SevaCore.of(context).loggedInUser.sevaUserID
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  suggestion.fullname ?? '',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              )
            : Offstage();
      },
      onSelected: (suggestion) {
        setState(() {
          selectedNewOwner = suggestion;
        });
        _textEditingController.clear();
      },
      errorBuilder: (context, error) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            S.of(context).no_user_found,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      },
      emptyBuilder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            S.of(context).no_user_found,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      },
      builder: (context, textEditingController, focusNode) {
        return TextField(
          controller: _textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: S.of(context).search,
            filled: true,
            fillColor: Colors.grey[300],
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(25.7),
            ),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(25.7)),
            contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
            ),
            suffixIcon: InkWell(
              splashColor: Colors.transparent,
              child: Icon(
                Icons.clear,
                color: Colors.grey,
              ),
              onTap: () {
                _textEditingController.clear();
              },
            ),
          ),
        );
      },
    );
  }

  Widget getInfoWidget() {
    return Container(
      color: Colors.grey[100],
      child: ListTile(
        leading: Image.asset(
          'lib/assets/images/info.png',
          color: FlavorConfig.values.theme!.primaryColor!,
          height: 30,
          width: 30,
        ),
        title: Text(S.of(context).transer_hint_data_deletion),
      ),
    );
  }

  void getSuccessDialog(
      {BuildContext? context, String? timebankName, String? admin}) {
    showDialog(
      context: context!,
      builder: (BuildContext _context) {
        // return object of type Dialog
        return AlertDialog(
          content: Text(
            '${S.of(context).change_ownership_successful.replaceAll('**groupName', timebankName!).replaceAll('**newOwnerName', admin!)}',
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text(S.of(context).close),
              onPressed: () {
                Navigator.of(_context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void getErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Text(S.of(context).error_occured),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            CustomTextButton(
              child: Text(S.of(context).close),
              textColor: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void sendNotifications() async {
    CommunityModel communityModel =
        await FirestoreManager.getCommunityDetailsByCommunityId(
            communityId: tbmodel.communityId);
    ChangeOwnershipModel changeOwnershipModel = ChangeOwnershipModel(
      creatorPhotoUrl: SevaCore.of(context).loggedInUser.photoURL,
      creatorEmail: SevaCore.of(context).loggedInUser.email,
      timebank: tbmodel.name,
      message: S
              .of(context)
              .you_have_been_made_the_new_owner_of_group_name_subtitle +
          ' ' +
          tbmodel.name,
      creatorName: SevaCore.of(context).loggedInUser.fullname,
    );

    Map<String, dynamic> notificationsData = {
      'new_owner_name': selectedNewOwner!.fullname,
      'old_owner_name': SevaCore.of(context).loggedInUser.fullname,
      'group_name': tbmodel.name,
      'group_photourl': tbmodel.photoUrl,
    };

    NotificationsModel notification = NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: tbmodel.id,
        data: changeOwnershipModel.toMap(),
        isRead: false,
        type: NotificationType.TypeChangeGroupOwnership,
        communityId: tbmodel.communityId,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        isTimebankNotification: false,
        senderPhotoUrl:
            SevaCore.of(context).loggedInUser.photoURL ?? defaultUserImageURL,
        targetUserId: selectedNewOwner!.sevaUserID);
    NotificationsModel notificationToCommunityCreator = NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: communityModel.primary_timebank,
        data: notificationsData,
        isRead: false,
        type: NotificationType
            .TYPE_CHANGE_GROUP_OWNERSHIP_UPDATE_TO_COMMUNITY_OWNER,
        communityId: tbmodel.communityId,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        isTimebankNotification: false,
        senderPhotoUrl:
            SevaCore.of(context).loggedInUser.photoURL ?? defaultUserImageURL,
        targetUserId: communityModel.created_by);
    await CollectionRef.userNotification(selectedNewOwner!.email!)
        .doc(notification.id)
        .set(notification.toMap());
    await CollectionRef.userNotification(communityModel.primary_email)
        .doc(notificationToCommunityCreator.id)
        .set(notificationToCommunityCreator.toMap());
    if (progressContext != null) {
      Navigator.pop(progressContext!);
    }
    getSuccessDialog(
        context: context,
        timebankName: tbmodel.name,
        admin: selectedNewOwner!.fullname);
  }
}

Widget timeBankOrGroupCard(String timebankName) {
  return Card(
    elevation: 1,
    child: ListTile(
      title: Text(timebankName ?? ''),
    ),
  );
}
