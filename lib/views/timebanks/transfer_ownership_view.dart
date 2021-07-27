import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/user_exit_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/switch_timebank.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class TransferOwnerShipView extends StatefulWidget {
  final String timebankId;
  final Map<String, dynamic> responseData;
  final String memberName;
  final String memberSevaUserId;
  final String memberPhotUrl;
  final bool isComingFromExit;
  final String memberEmail;

  TransferOwnerShipView(
      {this.timebankId,
      this.responseData,
      this.isComingFromExit,
      this.memberName,
      this.memberSevaUserId,
      this.memberPhotUrl,
      this.memberEmail});

  @override
  _TransferOwnerShipViewState createState() => _TransferOwnerShipViewState();
}

class _TransferOwnerShipViewState extends State<TransferOwnerShipView> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();
  List<String> groupMembersList = [];
  var ownerGroupsArr;
  UserModel selectedNewOwner = null;
  List<String> allItems = [];
  List<String> admins, coordinators, members;
  TimebankModel tbmodel;
  List<Future> futures = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMembersList();
    ownerGroupsArr = widget.responseData['ownerGroupsArr'];
  }

  void getMembersList() {
    FirestoreManager.getTimebankIdStream(
      timebankId: widget.timebankId,
    ).then((onValue) {
      setState(() {
        tbmodel = onValue;
        admins = onValue.admins;
        coordinators = onValue.coordinators;
        members = onValue.members;
        allItems.addAll(admins);
        allItems.addAll(coordinators);
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
          widget.isComingFromExit
              ? S.of(context).exit_user
              : S.of(context).remove_user,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Europa'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.memberName,
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Europa',
                    fontWeight: FontWeight.bold,
                    color: FlavorConfig.values.theme.primaryColor),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                S.of(context).transfer_data_hint,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Europa',
                ),
              ),
              SizedBox(
                height: 15,
              ),
              getDataList(ownerGroupsArr),
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
                S.of(context).search_user,
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
              selectedNewOwner == null
                  ? Container()
                  : ListTile(title: Text(selectedNewOwner.fullname)),
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
          child: Text(
              widget.isComingFromExit
                  ? S.of(context).exit
                  : S.of(context).remove,
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa')),
          textColor: FlavorConfig.values.theme.primaryColor,
          onPressed: () async {
            if (selectedNewOwner == null) {
              // print("reporter timebank creator id is ${tbmodel.creatorId}");
              ownerGroupsArr.forEach(
                (group) {
                  futures.add(
                    CollectionRef.timebank.doc(group['id']).update(
                      {
                        "creator_id": tbmodel.creatorId,
                        "email_id": tbmodel.emailId,
                        "organizers":
                            FieldValue.arrayUnion([tbmodel.creatorId]),
                        "members": FieldValue.arrayUnion([tbmodel.creatorId]),
                      },
                    ),
                  );
                },
              );
              await Future.wait(futures);
              Map<String, dynamic> responseObj = await removeMemberFromTimebank(
                  sevauserid: widget.memberSevaUserId, timebankId: tbmodel.id);
              // var responseObj2 = await storeRemoveMemberLog(
              //     timebankId: tbmodel.id,
              //     communityId: tbmodel.communityId,
              //     memberEmail: widget.memberEmail,
              //     memberUid: widget.memberSevaUserId,
              //     memberFullName: widget.memberName,
              //     memberPhotoUrl: widget.memberPhotUrl);

              if (responseObj['deletable'] == true) {
                if (widget.isComingFromExit) {
                  sendNotificationToAdmin();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SwitchTimebank(),
                    ),
                  );
                } else {
                  getSuccessDialog(context);
                  Navigator.of(context).pop();
                }
              } else {
                //  print("else error block");
                getErrorDialog(context);
                Navigator.of(context).pop();
              }
            } else {
              //  print("new owner creator id is ${selectedNewOwner.sevaUserID}");
              ownerGroupsArr.forEach((group) {
                futures.add(
                  CollectionRef.timebank.doc(group['id']).update(
                    {
                      "creator_id": selectedNewOwner.sevaUserID,
                      "email_id": selectedNewOwner.email,
                      "admins":
                          FieldValue.arrayUnion([selectedNewOwner.sevaUserID]),
                      "members":
                          FieldValue.arrayUnion([selectedNewOwner.sevaUserID]),
                    },
                  ),
                );
              });
              await Future.wait(futures);
              Map<String, dynamic> responseObj = await removeMemberFromTimebank(
                  sevauserid: widget.memberSevaUserId, timebankId: tbmodel.id);
              //  print("===response data of removal is${responseObj.toString()}===");
              if (responseObj['deletable'] == true) {
                //   print("else block---done transferring and removing the user from timebank");
                if (widget.isComingFromExit) {
                  sendNotificationToAdmin();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => HomePageRouter(),
                      ),
                      (Route<dynamic> route) => false);
                } else {
                  getSuccessDialog(context);
                  Navigator.of(context).pop();
                }
              } else {
                //  print("else error block");
                getErrorDialog(context);
                Navigator.of(context).pop();
              }
            }
          },
        )
      ],
    );
  }

  Widget searchUser() {
    return TypeAheadField<UserModel>(
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      textFieldConfiguration: TextFieldConfiguration(
        controller: _textEditingController,
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
              // color: _textEditingController.text.length > 1
              //     ? Colors.black
              //     : Colors.grey,
            ),
            onTap: () {
              _textEditingController.clear();
              controller.close();
            },
          ),
        ),
      ),
      suggestionsBoxController: controller,
      suggestionsCallback: (pattern) async {
//        List<String> dataCopy = [];
//        // interests.forEach((k, v) => dataCopy.add(v));
//        print(dataCopy);
//        dataCopy.retainWhere(
//            (s) => s.toLowerCase().contains(pattern.toLowerCase()));
//        //  return await Future.value(dataCopy);

        return await SearchManager.searchForUserWithTimebankIdFuture(
            queryString: pattern, validItems: groupMembersList);
      },
      itemBuilder: (context, suggestion) {
        // print("suggest ${suggestion}");
        return suggestion.sevaUserID != widget.memberSevaUserId
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  suggestion.fullname,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              )
            : Offstage();
      },
      noItemsFoundBuilder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            S.of(context).no_user_found,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      },
      onSuggestionSelected: (suggestion) {
        setState(() {
          selectedNewOwner = suggestion;
        });
        _textEditingController.clear();

//        if (!_selectedInterests.containsValue(suggestion)) {
//          controller.close();
//          String id = interests.keys
//              .firstWhere((k) => interests[k] == suggestion);
//          _selectedInterests[id] = suggestion;
//          setState(() {});
//        }
      },
    );
  }

  Widget getInfoWidget() {
    return Container(
      color: Colors.grey[100],
      child: ListTile(
        leading: Image.asset(
          'lib/assets/images/info.png',
          color: FlavorConfig.values.theme.primaryColor,
          height: 30,
          width: 30,
        ),
        title: Text(S.of(context).transer_hint_data_deletion),
      ),
    );
  }

  Widget getDataList(ownerGroupsArr) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: ownerGroupsArr.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return timeBankOrGroupCard(ownerGroupsArr[index]);
        });
  }

  void getSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Text(S.of(context).user_removal_success),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            CustomTextButton(
              child: Text(S.of(context).close),
              onPressed: () {
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

  void sendNotificationToAdmin({
    String communityId,
  }) async {
    UserExitModel userExitModel = UserExitModel(
        userPhotoUrl: widget.memberPhotUrl,
        timebank: tbmodel.name,
        reason: globals.userExitReason ?? "",
        userName: widget.memberName);

    NotificationsModel notification = NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: tbmodel.id,
        data: userExitModel.toMap(),
        isRead: false,
        type: NotificationType.TypeMemberExitTimebank,
        communityId: tbmodel.communityId,
        senderUserId: widget.memberSevaUserId,
        targetUserId: tbmodel.creatorId);

    await CollectionRef.timebank
        .doc(tbmodel.id)
        .collection("notifications")
        .doc(notification.id)
        .set((notification..isTimebankNotification = true).toMap());
  }
}

Widget timeBankOrGroupCard(ownerGroupData) {
  return Card(
    elevation: 1,
    child: ListTile(
      title: Text(ownerGroupData['name']),
    ),
  );
}
