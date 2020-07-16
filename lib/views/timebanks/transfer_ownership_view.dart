import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/user_exit_model.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/switch_timebank.dart';

class TransferOwnerShipView extends StatefulWidget {
  final String timebankId;
  final Map<String, dynamic> responseData;
  final String memberName;
  final String memberSevaUserId;
  final String memberPhotUrl;
  final bool isComingFromExit;

  TransferOwnerShipView(
      {this.timebankId,
      this.responseData,
      this.isComingFromExit,
      this.memberName,
      this.memberSevaUserId,
      this.memberPhotUrl});

  @override
  _TransferOwnerShipViewState createState() => _TransferOwnerShipViewState();
}

class _TransferOwnerShipViewState extends State<TransferOwnerShipView> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var groupMembersList = List<String>();
  var ownerGroupsArr;
  UserModel selectedNewOwner = null;
  var allItems = List<String>();
  var admins, coordinators, members;
  TimebankModel tbmodel;
  var futures = <Future>[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMembersList();
    ownerGroupsArr = widget.responseData['ownerGroupsArr'];
    //  print("ownerGroupsArr==============" + ownerGroupsArr.toString());
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
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios),
        ),
//      automaticallyImplyLeading: true,
        title: Text(
          widget.isComingFromExit
              ? AppLocalizations.of(context)
                  .translate('transfer_ownership', 'exit_user')
              : AppLocalizations.of(context)
                  .translate('transfer_ownership', 'remove_user'),
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
                AppLocalizations.of(context)
                    .translate('transfer_ownership', 'transfer_hint'),
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
//              getInfoWidget(),
//              SizedBox(
//                height: 15,
//              ),
              Text(
                AppLocalizations.of(context)
                    .translate('transfer_ownership', 'transfer_hint_two'),
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
                AppLocalizations.of(context)
                    .translate('transfer_ownership', 'search_user'),
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
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            AppLocalizations.of(context).translate('shared', 'cancel'),
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa'),
          ),
          textColor: Colors.grey,
        ),
        FlatButton(
          child: Text(
              widget.isComingFromExit
                  ? AppLocalizations.of(context).translate('members', 'exit')
                  : AppLocalizations.of(context).translate('members', 'Remove'),
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa')),
          textColor: FlavorConfig.values.theme.primaryColor,
          onPressed: () async {
            if (selectedNewOwner == null) {
              // print("reporter timebank creator id is ${tbmodel.creatorId}");
              ownerGroupsArr.forEach(
                (group) {
                  futures.add(
                    Firestore.instance
                        .collection('timebanknew')
                        .document(group['id'])
                        .updateData(
                      {
                        "creator_id": tbmodel.creatorId,
                        "email_id": tbmodel.emailId,
                        "admins": FieldValue.arrayUnion([tbmodel.creatorId]),
                        "members": FieldValue.arrayUnion([tbmodel.creatorId]),
                      },
                    ),
                  );
                },
              );
              await Future.wait(futures);
              Map<String, dynamic> responseObj = await removeMemberFromTimebank(
                  sevauserid: widget.memberSevaUserId, timebankId: tbmodel.id);
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
                print("groupppppp=== ${group['id']}");
                futures.add(
                  Firestore.instance
                      .collection('timebanknew')
                      .document(group['id'])
                      .updateData(
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
          hintText:
              AppLocalizations.of(context).translate('search_page', 'search'),
          filled: true,
          fillColor: Colors.grey[300],
          focusedBorder: OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.white),
            borderRadius: new BorderRadius.circular(25.7),
          ),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: new BorderRadius.circular(25.7)),
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
            AppLocalizations.of(context).translate('requests', 'no_users'),
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
        title: Text(AppLocalizations.of(context)
            .translate('transfer_ownership', 'transfer_hint_three')),
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
          content: new Text(AppLocalizations.of(context)
              .translate('transfer_ownership', 'removed_success')),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(AppLocalizations.of(context)
                  .translate('billing_plans', 'close')),
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
          content: new Text(AppLocalizations.of(context)
              .translate('transfer_ownership', 'transfer_error')),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(AppLocalizations.of(context)
                  .translate('billing_plans', 'close')),
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
    print("bhhfhff ${userExitModel} ");
    print(" timebank id ${tbmodel.id + tbmodel.members.toString()}");
    await Firestore.instance
        .collection('timebanknew')
        .document(tbmodel.id)
        .collection("notifications")
        .document(notification.id)
        .setData(notification.toMap());
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
