import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/change_ownership_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
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
    // TODO: implement initState
    super.initState();
    getMembersList();
    //  print("ownerGroupsArr==============" + ownerGroupsArr.toString());
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
          AppLocalizations.of(context)
              .translate('change_ownership', 'change_ownership_title'),
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
                      AppLocalizations.of(context)
                              .translate('change_ownership', 'change_hint') +
                          tbmodel.name +
                          AppLocalizations.of(context).translate(
                              'change_ownership', 'change_hint_three'),
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
                      AppLocalizations.of(context)
                          .translate('change_ownership', 'change_hint_two'),
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
                          .translate('change_ownership', 'search_admin'),
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
          : Center(
              child: CircularProgressIndicator(),
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
              AppLocalizations.of(context)
                  .translate('change_ownership', 'change'),
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa')),
          textColor: FlavorConfig.values.theme.primaryColor,
          onPressed: () async {
            if (selectedNewOwner == null) {
              setState(() {
                user_error = AppLocalizations.of(context)
                    .translate('change_ownership', 'users_empty');
              });
            } else if (invtitedUsers.contains(selectedNewOwner.email)) {
              dialogBox(
                  message: AppLocalizations.of(context)
                      .translate('change_ownership', 'already_invited'));
            } else {
              showProgressDialog(AppLocalizations.of(context)
                  .translate('members', 'sending_invitation'));
              Map<String, dynamic> responseObj =
                  await checkChangeOwnershipStatus(
                      sevauserid: loggedInUser.sevaUserID,
                      timebankId: tbmodel.id);
              print(
                  "else error block ${responseObj.keys.toString() + " " + responseObj.values.toString()}");

              if (responseObj['transferable'] == true) {
                print('yes transferable ');
                invtitedUsers.add(selectedNewOwner.email);
                sendNotificationToAdmin();
              } else {
                if (responseObj['tasksCheck'] == false) {
                  if (progressContext != null) {
                    Navigator.pop(progressContext);
                  }
                  dialogBox(
                      message: AppLocalizations.of(context)
                          .translate('change_ownership', 'pending_task'));
                } else if (responseObj['pendingPaymentsCheck'] == false) {
                  if (progressContext != null) {
                    Navigator.pop(progressContext);
                  }
                  dialogBox(
                      message: AppLocalizations.of(context).translate(
                                  'change_ownership', 'pending_payment') +
                              responseObj['planName'] ??
                          '' +
                              AppLocalizations.of(context).translate(
                                  'change_ownership', 'pending_payment_two'));
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
          content: new Text(AppLocalizations.of(context)
              .translate('change_ownership', 'ownership_suceess')),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                  AppLocalizations.of(context).translate('homepage', 'ok')),
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
          content: new Text(message),
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
            AppLocalizations.of(context).translate('requests', 'no_users'),
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
          content: new Text(AppLocalizations.of(context)
                  .translate('change_ownership', 'invitation_sent') +
              timebankName +
              AppLocalizations.of(context)
                  .translate('change_ownership', 'invitation_sent_two') +
              admin +
              AppLocalizations.of(context)
                  .translate('change_ownership', 'invitation_sent_three')),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(AppLocalizations.of(context)
                  .translate('billing_plans', 'close')),
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

  void sendNotificationToAdmin() async {
    ChangeOwnershipModel changeOwnershipModel = ChangeOwnershipModel(
        creatorPhotoUrl: loggedInUser.photoURL,
        creatorEmail: loggedInUser.email,
        timebank: tbmodel.name,
        message: AppLocalizations.of(context)
                .translate('change_ownership', 'change_message') +
            tbmodel.name +
            AppLocalizations.of(context)
                .translate('change_ownership', 'change_message_two'),
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
    print("bhhfhff ${changeOwnershipModel} ");
    print(" timebank id ${tbmodel.id + tbmodel.members.toString()}");
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
