import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/change_ownership_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class ChangeOwnerShipView extends StatefulWidget {
  final String timebankId;
  ChangeOwnerShipView({
    this.timebankId,
  });

  @override
  _ChangeOwnerShipViewState createState() => _ChangeOwnerShipViewState();
}

class _ChangeOwnerShipViewState extends State<ChangeOwnerShipView> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();

  var groupMembersList = List<String>();
  var ownerGroupsArr;
  UserModel selectedNewOwner = null;
  var allItems = List<String>();
  var admins, coordinators, members;
  UserModel loggedInUser;
  TimebankModel tbmodel;
  var futures = <Future>[];
  BuildContext parentContext;
  String user_error = '';
  bool dataLoaded = false;
  List<String> invtitedUsers = [];
  @override
  void initState() {
    super.initState();
    getMembersList();
  }

  void getMembersList() {
    FirestoreManager.getTimebankIdStream(
      timebankId: widget.timebankId,
    ).then((onValue) {
      setState(() {
        tbmodel = onValue;
        admins = onValue.admins;
        allItems.addAll(admins);
        groupMembersList = allItems;
        dataLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    loggedInUser = SevaCore.of(context).loggedInUser;
    parentContext = context;
    return Scaffold(
      resizeToAvoidBottomPadding: true,
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
      body: dataLoaded
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      loggedInUser.fullname,
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
                      S.of(context).changing_ownership_of +
                          ' ' +
                          tbmodel.name +
                          ' ' +
                          S.of(context).to_other_admin,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Europa',
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    timeBankOrGroupCard(),
                    SizedBox(
                      height: 15,
                    ),
//              getInfoWidget(),
//              SizedBox(
//                height: 15,
//              ),
                    Text(
                      S.of(context).change_to,
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
                      S.of(context).search_admin,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Europa',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    searchUser(),
                    Text(
                      user_error,
                      style: TextStyle(color: Colors.red, fontFamily: "Europa"),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    selectedNewOwner == null
                        ? Container()
                        : ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                selectedNewOwner.photoURL ??
                                    defaultUserImageURL,
                              ),
                            ),
                            title: Text(selectedNewOwner.fullname)),
                    SizedBox(
                      height: 15,
                    ),
                    optionButtons(),
                  ],
                ),
              ),
            )
          : LoadingIndicator(),
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
            S.of(context).cancel,
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa'),
          ),
          textColor: Colors.grey,
        ),
        FlatButton(
          child: Text(S.of(context).change,
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa')),
          textColor: FlavorConfig.values.theme.primaryColor,
          onPressed: () async {
            if (selectedNewOwner == null) {
              setState(() {
                user_error = S.of(context).select_user;
              });
            } else if (invtitedUsers.contains(selectedNewOwner.email)) {
              dialogBox(
                  message: S.of(context).change_ownership_already_invited);
            } else {
              showProgressDialog(S.of(context).sending_invitation);
              Map<String, dynamic> responseObj =
                  await checkChangeOwnershipStatus(
                      sevauserid: loggedInUser.sevaUserID,
                      timebankId: tbmodel.id);

              if (responseObj['transferable'] == true) {
                invtitedUsers.add(selectedNewOwner.email);
                sendNotificationToAdmin();
              } else {
                if (responseObj['tasksCheck'] == false) {
                  if (progressContext != null) {
                    Navigator.pop(progressContext);
                  }
                  dialogBox(
                      message:
                          S.of(context).change_ownership_pending_task_message);
                } else if (responseObj['pendingPaymentsCheck'] == false) {
                  if (progressContext != null) {
                    Navigator.pop(progressContext);
                  }
                  dialogBox(
                    message: S.of(context).change_ownership_pending_payment1 +
                            responseObj['planName'] ??
                        ' ' + S.of(context).change_ownership_pending_payment2,
                  );
                } else {
                  if (progressContext != null) {
                    Navigator.pop(progressContext);
                  }
                  getErrorDialog(context);
                }
                //Navigator.of(context).pop();
              }
            }
          },
        )
      ],
    );
  }

  void getSuccessDialogtwo() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Text(S.of(context).ownership_success),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(S.of(context).ok),
              onPressed: () {
                //  resetAndLoad();
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  BuildContext progressContext;
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

  void dialogBox({String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
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
//        dataCopy.retainWhere(
//            (s) => s.toLowerCase().contains(pattern.toLowerCase()));
//        //  return await Future.value(dataCopy);

        return await SearchManager.searchForUserWithTimebankIdFuture(
            queryString: pattern, validItems: groupMembersList);
      },
      itemBuilder: (context, suggestion) {
        return suggestion.sevaUserID != loggedInUser.sevaUserID
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
          user_error = '';
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

//  Widget getInfoWidget() {
//    return Container(
//      color: Colors.grey[100],
//      child: ListTile(
//        leading: Image.asset(
//          'lib/assets/images/info.png',
//          color: FlavorConfig.values.theme.primaryColor,
//          height: 30,
//          width: 30,
//        ),
//        title: Text(AppLocalizations.of(context)
//            .translate('transfer_ownership', 'transfer_hint_three')),
//      ),
//    );
//  }

//  Widget getDataList(ownerGroupsArr) {
//    return ListView.builder(
//        physics: NeverScrollableScrollPhysics(),
//        itemCount: ownerGroupsArr.length,
//        shrinkWrap: true,
//        itemBuilder: (context, index) {
//          return timeBankOrGroupCard(ownerGroupsArr[index]);
//        });
//  }

  void getSuccessDialog(
      {BuildContext context, String timebankName, String admin}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Text(
            '${S.of(context).invitation_sent1} $timebankName ${S.of(context).invitation_sent2} $admin ${S.of(context).invitation_sent3}',
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(S.of(context).close),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(parentContext).pop();
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
          content: Text(S.of(context).ownership_transfer_error),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
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

  void sendNotificationToAdmin() async {
    ChangeOwnershipModel changeOwnershipModel = ChangeOwnershipModel(
        creatorPhotoUrl: loggedInUser.photoURL,
        creatorEmail: loggedInUser.email,
        timebank: tbmodel.name,
        message: S.of(context).change_ownership_message1 +
            ' ' +
            tbmodel.name +
            ' ' +
            S.of(context).change_ownership_message2,
        creatorName: loggedInUser.fullname);

    NotificationsModel notification = NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: tbmodel.id,
        data: changeOwnershipModel.toMap(),
        isRead: false,
        type: NotificationType.TypeChangeOwnership,
        communityId: tbmodel.communityId,
        senderUserId: loggedInUser.sevaUserID,
        targetUserId: selectedNewOwner.sevaUserID);
    await Firestore.instance
        .collection('users')
        .document(selectedNewOwner.email)
        .collection("notifications")
        .document(notification.id)
        .setData(notification.toMap());
    if (progressContext != null) {
      Navigator.pop(progressContext);
    }
    getSuccessDialog(
        context: context,
        timebankName: tbmodel.name,
        admin: selectedNewOwner.fullname);
  }

  Widget timeBankOrGroupCard() {
    return Card(
      elevation: 1,
      child: ListTile(
        title: Text(tbmodel.name ?? ""),
      ),
    );
  }
}
