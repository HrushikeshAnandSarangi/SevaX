import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/views/requests/donations/donation_view.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../flavor_config.dart';
// import 'package:timezone/browser.dart';

class RequestDetailsAboutPage extends StatefulWidget {
  final RequestModel requestItem;
  final TimebankModel timebankModel;
  final bool applied;
  final bool isAdmin;
  RequestDetailsAboutPage({
    Key key,
    this.applied = false,
    this.requestItem,
    this.timebankModel,
    this.isAdmin,
  }) : super(key: key);

  @override
  _RequestDetailsAboutPageState createState() =>
      _RequestDetailsAboutPageState();
}

enum UserMode {
  APPROVED_MEMBER,
  ACCEPTED_MEMBER,
  COMPLETED_MEMBER,
  REQUEST_CREATOR,
  NOT_YET_SIGNED_UP,
  TIMEBANK_ADMIN,
  AWITING_FOR_APPROVAL_FROM_CREATOR,
  AWAITING_FOR_CREDIT_APPROVAL,
}

enum GoodStatus {
  GOODS_SUBMITTED,
  GOODS_APPROVED,
  GOODS_REJEJCTED,
}

enum CashStatus {
  CASH_DEPOSITED,
  CASH_CONFIRMED,
}

class _RequestDetailsAboutPageState extends State<RequestDetailsAboutPage> {
  UserMode userMode;
  GoodStatus goodsStatus;
  CashStatus cashStatus;

  String location = 'Location';
  TextStyle titleStyle = TextStyle(
    fontSize: 18,
    color: Colors.black,
  );

  TextStyle subTitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  @override
  void initState() {
    super.initState();
  }

  UserMode refreshUserViewMode() {
    String loggedInUser = SevaCore.of(context).loggedInUser.sevaUserID;

    switch (widget.requestItem.requestMode) {
      case RequestMode.PERSONAL_REQUEST:
        if (widget.requestItem.sevaUserId == loggedInUser)
          return UserMode.REQUEST_CREATOR;
        else if (widget.requestItem.acceptors.contains(loggedInUser) &&
            !(widget.requestItem.approvedUsers.contains(loggedInUser)))
          return UserMode.AWITING_FOR_APPROVAL_FROM_CREATOR;
        else if (widget.requestItem.approvedUsers.contains(loggedInUser))
          return UserMode.APPROVED_MEMBER;
        else if (widget.requestItem.acceptors.contains(loggedInUser))
          return UserMode.ACCEPTED_MEMBER;
        else {
          return UserMode.NOT_YET_SIGNED_UP;
        }
        break;

      case RequestMode.TIMEBANK_REQUEST:
        if (widget.timebankModel.admins.contains(loggedInUser))
          return UserMode.TIMEBANK_ADMIN;
        else
          return UserMode.NOT_YET_SIGNED_UP;

        break;

      default:
        return UserMode.NOT_YET_SIGNED_UP;
    }
  }

  var futures = <Future>[];

  Widget get appBarForMembers {
    return AppBar(
      backgroundColor: Colors.white,
      leading: BackButton(
        color: Colors.black,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
      title: Text(
        S.of(context).my_requests,
        style:
            TextStyle(fontFamily: "Europa", fontSize: 20, color: Colors.black),
      ),
    );
  }

  Widget get getAppBarToUserMode {
    switch (userMode) {
      case UserMode.TIMEBANK_ADMIN:
      case UserMode.REQUEST_CREATOR:
        return null;

      case UserMode.NOT_YET_SIGNED_UP:
      case UserMode.APPROVED_MEMBER:
      case UserMode.ACCEPTED_MEMBER:
      case UserMode.COMPLETED_MEMBER:
        return appBarForMembers;

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    userMode = refreshUserViewMode();
    if (widget.requestItem.acceptors != null ||
        widget.requestItem.acceptors.length != 0 ||
        widget.requestItem.approvedUsers.length != 0 ||
        widget.requestItem.invitedUsers != null ||
        widget.requestItem.invitedUsers.length != 0) {
      widget.requestItem.acceptors.forEach((memberEmail) {
        futures.add(getUserDetails(memberEmail: memberEmail));
      });

      isApplied = widget.requestItem.acceptors
              .contains(SevaCore.of(context).loggedInUser.email) ||
          widget.requestItem.approvedUsers
              .contains(SevaCore.of(context).loggedInUser.email) ||
          widget.requestItem.invitedUsers
              .contains(SevaCore.of(context).loggedInUser.sevaUserID) ||
          false;
    } else {
      isApplied = false;
    }

    return Scaffold(
      appBar: getAppBarToUserMode,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                children: <Widget>[
                  SizedBox(height: 20),
                  requestTitleComponent,
                  SizedBox(height: 10),
                  getRequestModeComponent,
                  timestampComponent,
                  addressComponent,
                  hostNameComponent,
                  widget.requestItem.requestType == RequestType.TIME
                      ? Column(
                          children: [
                            membersEngagedComponent,
                            SizedBox(height: 10),
                            engagedMembersPicturesScroll,
                          ],
                        )
                      : Container(),
                  requestDescriptionComponent,
                ],
              ),
            ),
            getBottomFrame,
          ],
        ),
      ),
    );
  }

  Widget get getRequestModeComponent {
    switch (widget.requestItem.requestType) {
      case RequestType.CASH:
        return cashDonationDetails;

      case RequestType.GOODS:
        return totalGoodsReceived;

      case RequestType.TIME:
        return Container();

      default:
        return Container();
    }
  }

  Future<dynamic> getUserDetails({String memberEmail}) async {
    var user = await Firestore.instance
        .collection("users")
        .document(memberEmail)
        .get();

    return user.data;
  }

  bool isApplied = false;

  Widget get getBottomFrame {
    return Container(
      decoration: BoxDecoration(color: Colors.white54, boxShadow: [
        BoxShadow(color: Colors.grey[300], offset: Offset(2.0, 2.0))
      ]),
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20, bottom: 20),
        child: getBottomFrameForUserMode,
      ),
    );
  }

  Widget get getBottomFrameForUserMode {
    switch (widget.requestItem.requestType) {
      case RequestType.CASH:
        return getBottomFrameForCashRequest;

      case RequestType.GOODS:
        return getBottomFrameForGoodRequest;

      case RequestType.TIME:
        return getBottomFrameForTimeRequest;

      default:
        return getBottomFrameForTimeRequest;
    }
  }

  Widget get getBottomFrameForGoodRequest {
    switch (goodsStatus) {
      case GoodStatus.GOODS_APPROVED:
      case GoodStatus.GOODS_REJEJCTED:
      case GoodStatus.GOODS_SUBMITTED:
        return goodsDonationSubmitted;

      default:
        return goodsDonationSubmitted;
    }
  }

  Widget get getBottomFrameForCashRequest {
    switch (cashStatus) {
      case CashStatus.CASH_CONFIRMED:
      case CashStatus.CASH_DEPOSITED:
        return cashDeposited;

      default:
        return cashDeposited;
    }
  }

  Widget get cashDeposited {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: 'Would you like to donate for this request.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Europa',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 5),
          width: 100,
          height: 32,
          child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(0),
            color: isApplied ? Theme.of(context).accentColor : Colors.green,
            child: Row(
              children: <Widget>[
                SizedBox(width: 1),
                Spacer(),
                Text(
                  'Donate',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
            onPressed: () {
              navigateToDonations();
            },
          ),
        ),
      ],
    );
  }

  Widget get goodsDonationSubmitted {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: 'Would you like to donate for this request.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Europa',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 5),
          width: 100,
          height: 32,
          child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(0),
            color: isApplied ? Theme.of(context).accentColor : Colors.green,
            child: Row(
              children: <Widget>[
                SizedBox(width: 1),
                Spacer(),
                Text(
                  'Donate',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
            onPressed: () {
              navigateToDonations();
            },
          ),
        )
      ],
    );
  }

  void navigateToDonations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonationView(
          timabankName: widget.timebankModel.name,
          requestModel: widget.requestItem,
        ),
      ),
    );
  }

  Widget get getBottomFrameForTimeRequest {
    switch (userMode) {
      case UserMode.TIMEBANK_ADMIN:
      case UserMode.REQUEST_CREATOR:
        return getBottombarForCreator;

      case UserMode.APPROVED_MEMBER:
      case UserMode.ACCEPTED_MEMBER:
      case UserMode.COMPLETED_MEMBER:
      case UserMode.AWITING_FOR_APPROVAL_FROM_CREATOR:
      case UserMode.NOT_YET_SIGNED_UP:
        return getBottombarForParticipant;

      default:
        return getBottombarForParticipant;
    }
  }

  Widget get getBottombarForCreator {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(style: TextStyle(color: Colors.black), children: [
              TextSpan(
                text: S.of(context).creator_of_request_message,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Europa',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget get getBottombarForParticipant {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: isApplied
                      ? S.of(context).applied_for_request
                      : S.of(context).particpate_in_request_question,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Europa',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 5),
          width: 100,
          height: 32,
          child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(0),
            color: isApplied ? Theme.of(context).accentColor : Colors.green,
            child: Row(
              children: <Widget>[
                SizedBox(width: 1),
                Spacer(),
                Text(
                  isApplied ? S.of(context).withdraw : S.of(context).apply,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
            onPressed: () {
              applyAction();
            },
          ),
        )
      ],
    );
  }

  void applyAction() {
    if (isApplied) {
      print("Withraw request");
      _withdrawRequest();
    } else {
      print("Accept request");
      _acceptRequest();
      Navigator.pop(context);
    }
  }

  void _acceptRequest() {
    Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
    acceptorList.add(SevaCore.of(context).loggedInUser.email);

    widget.requestItem.acceptors = acceptorList.toList();
    acceptRequest(
      loggedInUser: SevaCore.of(context).loggedInUser,
      requestModel: widget.requestItem,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      directToMember: !widget.timebankModel.protected,
    );
  }

  void _withdrawRequest() {
    bool isAlreadyApproved = widget.requestItem.approvedUsers
        .contains(SevaCore.of(context).loggedInUser.email);
    var assosciatedEmail = SevaCore.of(context).loggedInUser.email;

    Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
    acceptorList.remove(assosciatedEmail);
    widget.requestItem.acceptors = acceptorList.toList();

    if (widget.requestItem.approvedUsers.contains(assosciatedEmail)) {
      Set<String> approvedUsers = Set.from(widget.requestItem.approvedUsers);
      approvedUsers.remove(SevaCore.of(context).loggedInUser.email);
      widget.requestItem.approvedUsers = approvedUsers.toList();
    }

    acceptRequest(
      loggedInUser: SevaCore.of(context).loggedInUser,
      isAlreadyApproved: isAlreadyApproved,
      requestModel: widget.requestItem,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      isWithdrawal: true,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      directToMember: !widget.timebankModel.protected,
    );
    Navigator.pop(context);
  }

  Widget get membersEngagedComponent {
    if (widget.requestItem.requestType == RequestType.TIME)
      return Column(
        children: [
          SizedBox(height: 20),
          Text(
            '${widget.requestItem.approvedUsers.length} / ${widget.requestItem.numberOfApprovals} Accepted',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );

    return Offstage();
  }

  Widget get hostNameComponent {
    return CustomListTile(
      leading: Icon(
        Icons.person,
        color: Colors.grey,
      ),
      title: Text(
        "${S.of(context).hosted_by} ${widget.requestItem.fullName ?? ""}",
        style: titleStyle,
        maxLines: 1,
      ),
    );
  }

  Widget get requestTitleComponent {
    return Text(
      widget.requestItem.title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget get date {
    return Text(
      DateFormat(
              'EEEEEEE, MMMM dd',
              Locale(AppConfig.prefs.getString('language_code'))
                  .toLanguageTag())
          .format(
        getDateTimeAccToUserTimezone(
            dateTime: DateTime.fromMillisecondsSinceEpoch(
                widget.requestItem.requestStart),
            timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
      ),
      style: titleStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget get subtitleComponent {
    return Text(
      DateFormat(
                  'h:mm a',
                  Locale(AppConfig.prefs.getString('language_code'))
                      .toLanguageTag())
              .format(
            getDateTimeAccToUserTimezone(
                dateTime: DateTime.fromMillisecondsSinceEpoch(
                    widget.requestItem.requestStart),
                timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
          ) +
          ' - ' +
          DateFormat(
                  'h:mm a',
                  Locale(AppConfig.prefs.getString('language_code'))
                      .toLanguageTag())
              .format(
            getDateTimeAccToUserTimezone(
              dateTime: DateTime.fromMillisecondsSinceEpoch(
                  widget.requestItem.requestEnd),
              timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
            ),
          ),
      style: subTitleStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget get timestampComponent {
    return CustomListTile(
      leading: Icon(
        Icons.access_time,
        color: Colors.grey,
      ),
      title: date,
      subtitle: subtitleComponent,
      trailing: trailingComponent,
    );
  }

  Widget get addressComponent {
    return widget.requestItem.address != null
        ? CustomListTile(
            leading: Icon(
              Icons.location_on,
              color: Colors.grey,
            ),
            title: Text(
              location,
              style: titleStyle,
              maxLines: 1,
            ),
            subtitle: widget.requestItem.address != null
                ? Text(widget.requestItem.address)
                : Text(''),
          )
        : Container();
  }

  Widget get trailingComponent {
    return Container(
      height: 25,
      width: 90,
      child: widget.requestItem.sevaUserId ==
              SevaCore.of(context).loggedInUser.sevaUserID
          ? FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Color.fromRGBO(44, 64, 140, 1),
              child: Text(
                S.of(context).edit,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditRequest(
                      timebankId:
                          SevaCore.of(context).loggedInUser.currentTimebank,
                      requestModel: widget.requestItem,
                    ),
                  ),
                );
              },
            )
          : Container(),
    );
  }

  Widget get requestDescriptionComponent {
    return Text(
      widget.requestItem.description,
      style: TextStyle(fontSize: 16),
    );
  }

  Widget get engagedMembersPicturesScroll {
    futures.clear();
    return FutureBuilder(
      future: Future.wait(futures),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasError)
          return Text(
            '${S.of(context).general_stream_error}',
          );
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }

        if (widget.requestItem.approvedUsers.length == 0) {
          return Container(
            margin: EdgeInsets.only(left: 0, top: 10),
            child: Text(
              S.of(context).no_approved_members,
            ),
          );
        }

        var snap = snapshot.data.map((f) {
          return UserModel.fromDynamic(f ?? {});
        }).toList();
        return Container(
          height: 40,
          child: InkWell(
            onTap: () {
              print('tapped');
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: snap.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 3, right: 3, top: 8),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          snap[index].photoURL ?? defaultUserImageURL,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget get totalGoodsReceived {
    return CustomListTile(
      title: Text(
        'Total Goods Received',
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(''),
      leading: Icon(
        Icons.show_chart,
        color: Colors.grey,
      ),
      trailing: Text(
        widget.requestItem.goodsDonationDetails.requiredGoods.length.toString(),
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
          // fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget getBottombar() {
    return Container(
      decoration: BoxDecoration(color: Colors.white54, boxShadow: [
        BoxShadow(color: Colors.grey[300], offset: Offset(2.0, 2.0))
      ]),
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: widget.requestItem.sevaUserId ==
                              SevaCore.of(context).loggedInUser.sevaUserID
                          ? S.of(context).creator_of_request_message
                          : isApplied
                              ? S.of(context).applied_for_request
                              : S.of(context).particpate_in_request_question,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Europa',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Offstage(
              offstage: widget.requestItem.sevaUserId ==
                  SevaCore.of(context).loggedInUser.sevaUserID,
              child: Container(
                margin: EdgeInsets.only(right: 5),
                width: 100,
                height: 32,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(0),
                  color:
                      isApplied ? Theme.of(context).accentColor : Colors.green,
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 1),
                      Spacer(),
                      Text(
                        isApplied
                            ? S.of(context).withdraw
                            : S.of(context).apply,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                    ],
                  ),
                  onPressed: () {
                    if (SevaCore.of(context).loggedInUser.calendarId == null) {
                      _settingModalBottomSheet(context);
                    } else {
                      applyAction();
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showProtectedTimebankMessage() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(S.of(context).protected_timebank),
          content: Text(S.of(context).protected_timebank_alert_dialog),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              textColor: Colors.red,
              child: Text(
                S.of(context).close,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                  child: Text(
                    S.of(context).calendars_popup_desc,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child:
                                Image.asset("lib/assets/images/googlecal.png"),
                          ),
                          onTap: () async {
                            String redirectUrl =
                                "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl =
                                "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=google_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            applyAction();
                            Navigator.of(bc).pop();
                          }),
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child:
                                Image.asset("lib/assets/images/outlookcal.png"),
                          ),
                          onTap: () async {
                            String redirectUrl =
                                "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl =
                                "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            applyAction();
                            Navigator.of(bc).pop();
                          }),
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: Image.asset("lib/assets/images/ical.png"),
                          ),
                          onTap: () async {
                            String redirectUrl =
                                "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl =
                                "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=icloud_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            applyAction();
                            Navigator.of(bc).pop();
                          })
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    FlatButton(
                        child: Text(
                          S.of(context).do_it_later,
                          style: TextStyle(
                              color: FlavorConfig.values.theme.primaryColor),
                        ),
                        onPressed: () async {
                          applyAction();
                          Navigator.of(bc).pop();
                        }),
                  ],
                )
              ],
            ),
          );
        });
  }

  void _showAlreadyApprovedMessage() {
    // flutter defined function
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text(S.of(context).already_approved),
            content: Text(S.of(context).withdraw_request_failure),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: Text(S.of(context).close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget get cashDonationDetails {
    return Column(
      children: [
        CustomListTile(
          title: Text(
            'Total amount raised',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text('\$${widget.requestItem.cashModel.amountRaised}'),
          leading: Icon(
            Icons.show_chart,
            color: Colors.grey,
          ),
          trailing: Text(
            '',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 30, bottom: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              semanticsLabel: '20%',
              backgroundColor: Colors.grey[200],
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              minHeight: 10,
              value: (widget.requestItem.cashModel.amountRaised /
                  widget.requestItem.cashModel.targetAmount),
            ),
          ),
        )
      ],
    );
  }
}
