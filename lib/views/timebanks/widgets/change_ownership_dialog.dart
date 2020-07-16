import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/change_ownership_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/timebanks/billing/billing_plan_details.dart';
import 'package:sevaexchange/views/timebanks/billing/billing_view.dart';

import '../../core.dart';

class ChangeOwnershipDialog extends StatefulWidget {
  final ChangeOwnershipModel changeOwnershipModel;
  final String timeBankId;
  final String notificationId;
  final NotificationsModel notificationModel;
  final UserModel loggedInUser;
  final BuildContext parentContext;
  ChangeOwnershipDialog({
    this.changeOwnershipModel,
    this.timeBankId,
    this.notificationId,
    this.notificationModel,
    this.loggedInUser,
    this.parentContext,
  });

  @override
  _ChangeOwnershipDialogViewState createState() =>
      _ChangeOwnershipDialogViewState(changeOwnershipModel, timeBankId,
          notificationId, notificationModel, loggedInUser);
}

class _ChangeOwnershipDialogViewState extends State<ChangeOwnershipDialog> {
  final ChangeOwnershipModel changeOwnershipModel;
  final String timeBankId;
  final String notificationId;
  final NotificationsModel notificationModel;
  final UserModel loggedInUser;

  _ChangeOwnershipDialogViewState(
    this.changeOwnershipModel,
    this.timeBankId,
    this.notificationId,
    this.notificationModel,
    this.loggedInUser,
  );
  List<FocusNode> focusNodes;
  CommunityModel communityModel = CommunityModel({});
  GlobalKey<FormState> _billingInformationKey = GlobalKey();
  BuildContext progressContext;
  var scollContainer = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCommunityDetails();
    focusNodes = List.generate(8, (_) => FocusNode());
  }

  void getCommunityDetails() async {
    await FirestoreManager.getCommunityDetailsByCommunityId(
            communityId: widget.loggedInUser.currentCommunity)
        .then((value) {
      communityModel = value;
      print("community ${communityModel.payment.toString()}");
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))),
      content: Form(
        //key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getCloseButton(context),
            Container(
              height: 70,
              width: 70,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    changeOwnershipModel.creatorPhotoUrl ??
                        defaultUserImageURL),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                AppLocalizations.of(widget.parentContext)
                    .translate('change_ownership', 'change_ownership_title'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                changeOwnershipModel.timebank ?? "Timebank name not updated",
              ),
            ),
//              Padding(
//                padding: EdgeInsets.all(0.0),
//                child: Text(
//                  "About ${requestInvitationModel.}",
//                  style: TextStyle(
//                      fontSize: 13, fontWeight: FontWeight.bold),
//                ),
//              ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(widget.parentContext)
                        .translate('change_ownership', 'change_message') +
                    changeOwnershipModel.timebank +
                    AppLocalizations.of(widget.parentContext)
                        .translate('change_ownership', 'change_message_two'),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                  AppLocalizations.of(widget.parentContext)
                      .translate('change_ownership', 'change_alert'),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    color: FlavorConfig.values.theme.primaryColor,
                    child: Text(
                      AppLocalizations.of(widget.parentContext)
                          .translate('change_ownership', 'accept'),
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      //Once approved
                      getAdvisoryDialog(context, changeOwnershipModel.timebank);

                      // showProgressDialog(context, 'Accepting Invitation');
//                      approveInvitation(
//                        model: changeOwnershipModel,
//                        notificationId: widget.notificationId,
//                      );

//                      if (progressContext != null) {
//                        Navigator.pop(progressContext);
//                      }

                      // Navigator.of(context).pop();
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                ),
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    color: Theme.of(context).accentColor,
                    child: Text(
                      AppLocalizations.of(widget.parentContext)
                          .translate('notifications', 'decline'),
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      await FirestoreManager.readUserNotification(
                          notificationId, loggedInUser.email);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void cardsHeadingWidget() {
    String planName = '';
    print('curr ${loggedInUser.currentCommunity}');
    print('curr plan ${communityModel.payment["planId"]}');
    if (communityModel.payment["planId"] != null &&
            communityModel.payment["planId"] == 'community_plan' ||
        communityModel.billMe == true) {
      showProgressDialog(AppLocalizations.of(context)
          .translate('createtimebank', 'updating_details'));
      changeOwnership(
              primaryTimebank: communityModel.primary_timebank,
              adminId: loggedInUser.sevaUserID,
              communityId: communityModel.id,
              adminEmail: loggedInUser.email,
              notificaitonId: notificationId)
          .commit()
          .then((onValue) {
        if (progressContext != null) {
          Navigator.pop(progressContext);
        }
        getSuccessDialog();
      });
    } else {
      Firestore.instance
          .collection('cards')
          .document(loggedInUser.currentCommunity)
          .get()
          .then((value) {
        print("value ${value.data}");
        if (value.data != null) {
          planName = value.data['currentplan'];
          print('planname $planName');
          if (planName == '' && !communityModel.payment.containsKey("planId")) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BillingPlanDetails(
                  user: loggedInUser,
                  isPlanActive: false,
                  autoImplyLeading: true,
                  isPrivateTimebank: communityModel.private,
                ),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BillingView(
                  loggedInUser.currentCommunity,
                  planName,
                  user: loggedInUser,
                  notificationId: notificationId,
                  isFromChangeOwnership: true,
                  changeOwnershipModel: changeOwnershipModel,
                  communityModel: communityModel,
                ),
              ),
            );
          }
        } else {
          print('no plan ');
        }
      });
    }
  }

  void resetAndLoad() async {
    await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) =>
                SevaCore(loggedInUser: loggedInUser, child: HomePageRouter())),
        (Route<dynamic> route) => false);
  }

  void getSuccessDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Text(AppLocalizations.of(widget.parentContext)
              .translate('change_ownership', 'ownership_suceess')),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(AppLocalizations.of(widget.parentContext)
                  .translate('homepage', 'ok')),
              onPressed: () {
                resetAndLoad();
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void getAdvisoryDialog(BuildContext mContext, String timebankName) {
    showDialog(
      context: mContext,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(widget.parentContext)
                      .translate('change_ownership', 'change_message') +
                  timebankName +
                  AppLocalizations.of(widget.parentContext)
                      .translate('change_ownership', 'change_advisory')),
              SizedBox(height: 15),
              Row(
                children: [
                  Spacer(),
                  FlatButton(
                    child: Text(
                        AppLocalizations.of(widget.parentContext)
                            .translate('shared', 'cancel'),
                        style: TextStyle(
                            fontSize: dialogButtonSize, color: Colors.red)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    color: Theme.of(mContext).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      AppLocalizations.of(widget.parentContext)
                          .translate('homepage', 'ok'),
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();

                      _billingBottomsheet(mContext);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
          ],
        );
      },
    );
  }

  WriteBatch changeOwnership({
    String primaryTimebank,
    String adminId,
    String communityId,
    String adminEmail,
    String notificaitonId,
  }) {
    //add to timebank members

    WriteBatch batch = Firestore.instance.batch();
    var timebankRef =
        Firestore.instance.collection('timebanknew').document(primaryTimebank);

    var personalNotifications = Firestore.instance
        .collection('users')
        .document(adminEmail)
        .collection("notifications")
        .document(notificaitonId);

    var addToCommunityRef =
        Firestore.instance.collection('communities').document(communityId);

    batch.updateData(addToCommunityRef, {
      'created_by': adminId,
      'primary_email': adminEmail,
      'billing_address': communityModel.billing_address.toMap()
    });

    batch.updateData(timebankRef, {
      "creator_id": adminId,
      "email_id": adminEmail,
    });

    batch.updateData(personalNotifications, {'isRead': true});

    return batch;
  }

  BuildContext dialogContext;

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

  void scrollToTop() {
    scollContainer.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void scrollToBottom() {
    scollContainer.animateTo(
      scollContainer.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void declineInvitationbRequest({
    ChangeOwnershipModel model,
    String notificationId,
  }) {
//    rejectInviteRequest(
//      requestId: model.requestId,
//      rejectedUserId: userModel.sevaUserID,
//      notificationId: notificationId,
//    );
//
//    FirestoreManager.readUserNotification(notificationId, userModel.email);
  }

  void approveInvitation({
    ChangeOwnershipModel model,
    String notificationId,
  }) {
//    FirestoreManager.readUserNotification(notificationId, user.email);
  }
  void _billingBottomsheet(
    BuildContext mcontext,
  ) {
    showModalBottomSheet(
        context: mcontext,
        builder: (BuildContext bc) {
          return Container(
            child: _scrollingList(
              focusNodes,
              bc,
            ),
          );
        });
  }

  Widget _scrollingList(
    List<FocusNode> focusNodes,
    BuildContext bc,
  ) {
    print(focusNodes);
    Widget _cityWidget() {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (input) {
            // FocusScope.of(bc).requestFocus(focusNodes[0]);
            FocusScope.of(bc).unfocus();
          },
          onChanged: (value) {
            print(value);
            communityModel.billing_address.city = value;
          },
          focusNode: focusNodes[0],
          validator: (value) {
            return value.isEmpty
                ? AppLocalizations.of(widget.parentContext)
                    .translate('createtimebank', 'err_empty')
                : null;
          },
          decoration: getInputDecoration(
              fieldTitle: AppLocalizations.of(widget.parentContext)
                  .translate('createtimebank', 'city')),
        ),
      );
    }

    Widget _stateWidget() {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (input) {
            // FocusScope.of(bc).requestFocus(focusNodes[1]);
            FocusScope.of(bc).unfocus();
          },
          onChanged: (value) {
            communityModel.billing_address.state = value;
          },
          validator: (value) {
            return value.isEmpty
                ? AppLocalizations.of(widget.parentContext)
                    .translate('createtimebank', 'err_empty')
                : null;
          },
          focusNode: focusNodes[1],
          decoration: getInputDecoration(
              fieldTitle: AppLocalizations.of(widget.parentContext)
                  .translate('createtimebank', 'state')),
        ),
      );
    }

    Widget _pinCodeWidget() {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (input) {
            // FocusScope.of(bc).requestFocus(focusNodes[3]);
            FocusScope.of(bc).unfocus();
          },
          onChanged: (value) {
            print(value);
            communityModel.billing_address.pincode = int.parse(value);
          },
          validator: (value) {
            return value.isEmpty
                ? AppLocalizations.of(widget.parentContext)
                    .translate('createtimebank', 'err_empty')
                : null;
          },
          focusNode: focusNodes[3],
          keyboardType: TextInputType.number,
          maxLength: 15,
          decoration: getInputDecoration(
              fieldTitle: AppLocalizations.of(widget.parentContext)
                  .translate('createtimebank', 'zip')),
        ),
      );
    }

    Widget _additionalNotesWidget() {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          onFieldSubmitted: (input) {
            scrollToBottom();
          },
          onChanged: (value) {
            communityModel.billing_address.additionalnotes = value;
          },
          focusNode: focusNodes[7],
          textInputAction: TextInputAction.done,
          decoration: getInputDecoration(
              fieldTitle: AppLocalizations.of(widget.parentContext)
                  .translate('createtimebank', 'additional_notes')),
        ),
      );
    }

    Widget _streetAddressWidget() {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          onFieldSubmitted: (input) {
            FocusScope.of(bc).unfocus();
          },
          onChanged: (value) {
            communityModel.billing_address.street_address1 = value;
          },
          validator: (value) {
            return value.isEmpty
                ? AppLocalizations.of(widget.parentContext)
                    .translate('createtimebank', 'err_empty')
                : null;
          },
          focusNode: focusNodes[4],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
              fieldTitle: AppLocalizations.of(widget.parentContext)
                  .translate('createtimebank', 'street_add1')),
        ),
      );
    }

    Widget _streetAddressTwoWidget() {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
            textCapitalization: TextCapitalization.sentences,
            onFieldSubmitted: (input) {
              // FocusScope.of(bc).requestFocus(focusNodes[6]);
              FocusScope.of(bc).unfocus();
            },
            onChanged: (value) {
              communityModel.billing_address.street_address2 = value;
            },
            focusNode: focusNodes[5],
            textInputAction: TextInputAction.next,
            decoration: getInputDecoration(
              fieldTitle: AppLocalizations.of(widget.parentContext)
                  .translate('createtimebank', 'street_add2'),
            )),
      );
    }

    Widget _countryNameWidget() {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (input) {
            // FocusScope.of(bc).requestFocus(focusNodes[2]);
            FocusScope.of(bc).unfocus();
          },
          onChanged: (value) {
            communityModel.billing_address.country = value;
          },
          validator: (value) {
            return value.isEmpty
                ? AppLocalizations.of(widget.parentContext)
                    .translate('createtimebank', 'err_empty')
                : null;
          },
          focusNode: focusNodes[2],
          decoration: getInputDecoration(
            fieldTitle: AppLocalizations.of(widget.parentContext)
                .translate('createtimebank', 'country_name'),
          ),
        ),
      );
    }

    Widget _companyNameWidget() {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,

          onFieldSubmitted: (input) {
            // FocusScope.of(bc).requestFocus(focusNodes[7]);
            FocusScope.of(bc).unfocus();
          },
          onChanged: (value) {
            communityModel.billing_address.companyname = value;
          },
          // validator: (value) {
          //   return value.isEmpty ? 'Field cannot be left blank*' : null;
          // },
          focusNode: focusNodes[6],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: AppLocalizations.of(widget.parentContext)
                .translate('createtimebank', 'company_name'),
          ),
        ),
      );
    }

    Widget _continueBtn() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(100, 10, 100, 20),
        child: RaisedButton(
          child: Text(
            AppLocalizations.of(widget.parentContext)
                .translate('createtimebank', 'continue'),
            style: Theme.of(bc).primaryTextTheme.button,
          ),
          onPressed: () async {
            FocusScope.of(bc).requestFocus(FocusNode());
            if (_billingInformationKey.currentState.validate()) {
              if (communityModel.billing_address.country == null) {
                scrollToTop();
              } else {
                print("All Good");
                cardsHeadingWidget();
                //  Navigator.pop(context);
                // _pc.close();
                //scrollIsOpen = false;
              }
            }
          },
        ),
      );
    }

    return Container(
      // var scrollController = Sc
      //adding a margin to the top leaves an area where the user can swipe
      //to open/close the sliding panel
      margin: const EdgeInsets.only(top: 15.0),
      color: Colors.white,
      child: Form(
        key: _billingInformationKey,
        child: ListView(
          controller: scollContainer,
          children: <Widget>[
            _billingDetailsTitle,
            _cityWidget(),
            _stateWidget(),
            _countryNameWidget(),
            _pinCodeWidget(),
            _streetAddressWidget(),
            _streetAddressTwoWidget(),
            _companyNameWidget(),
            _additionalNotesWidget(),
            _continueBtn(),
            SizedBox(
              height: 220,
            ),
          ],
        ),
      ),
    );
  }

  Widget get _billingDetailsTitle {
    return Container(
//        margin: EdgeInsets.fromLTRB(10, 0, 20, 10),
        margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  AppLocalizations.of(widget.parentContext)
                      .translate('createtimebank', 'profile_info_title'),
                  style: TextStyle(
                      color: FlavorConfig.values.theme.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    //_pc.close();
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Text(
                      ''' x ''',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }

  Widget _getCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        alignment: FractionalOffset.topRight,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'lib/assets/images/close.png',
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration getInputDecoration({String fieldTitle}) {
    return InputDecoration(
      errorStyle: TextStyle(
        color: Colors.red,
        wordSpacing: 2.0,
      ),
//      focusedBorder: OutlineInputBorder(
//        borderSide: BorderSide(color: Colors.greenAccent, width: 1.0),
//      ),
//      border: OutlineInputBorder(
//          gapPadding: 0.0, borderRadius: BorderRadius.circular(1.5)),
//      enabledBorder: OutlineInputBorder(
//        borderSide: BorderSide(color: Colors.green, width: 1.0),
//      ),
      hintText: fieldTitle,

      alignLabelWithHint: true,
    );
  }
}
