import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/calender_event_confirm_dialog.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/projects_helper.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/views/requests/donations/donation_view.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';
import 'package:timeago/timeago.dart' as timeAgo;
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
  AWAITING_FOR_APPROVAL_FROM_CREATOR,
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
  );

  bool isAdmin = false;
  bool canDeleteRequest = false;
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
          return UserMode.AWAITING_FOR_APPROVAL_FROM_CREATOR;
        else if (widget.requestItem.approvedUsers.contains(loggedInUser))
          return UserMode.APPROVED_MEMBER;
        else if (widget.requestItem.acceptors.contains(loggedInUser))
          return UserMode.ACCEPTED_MEMBER;
        else if (isAccessAvailable(widget.timebankModel, loggedInUser))
          return UserMode.TIMEBANK_ADMIN;
        else {
          return UserMode.NOT_YET_SIGNED_UP;
        }
        break;

      case RequestMode.TIMEBANK_REQUEST:
        if (widget.requestItem.sevaUserId == loggedInUser) {
          return UserMode.REQUEST_CREATOR;
        } else if (isAccessAvailable(widget.timebankModel, loggedInUser)) {
          return UserMode.TIMEBANK_ADMIN;
        } else {
          return UserMode.NOT_YET_SIGNED_UP;
        }
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
        // S.of(context).request_details,
        'Request Details',
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
                  createdAt,
                  addressComponent,
                  hostNameComponent,
                  widget.requestItem.requestType == RequestType.TIME
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
    if (widget.requestItem.sevaUserId ==
        SevaCore.of(context).loggedInUser.sevaUserID) {
      return getBottombarForCreator;
    } else {
      switch (goodsStatus) {
        case GoodStatus.GOODS_APPROVED:
        case GoodStatus.GOODS_REJEJCTED:
        case GoodStatus.GOODS_SUBMITTED:
          return goodsDonationSubmitted;

        default:
          return goodsDonationSubmitted;
      }
    }
  }

  Widget get getBottomFrameForCashRequest {
    if (widget.requestItem.sevaUserId ==
        SevaCore.of(context).loggedInUser.sevaUserID) {
      return getBottombarForCreator;
    } else {
      switch (cashStatus) {
        case CashStatus.CASH_CONFIRMED:
        case CashStatus.CASH_DEPOSITED:
          return cashDeposited;

        default:
          return cashDeposited;
      }
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
                  text: S.of(context).would_like_to_donate,
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
                  S.of(context).donate,
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
                  text: S.of(context).would_like_to_donate,
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
                  S.of(context).donate,
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
          notificationId: null,
        ),
      ),
    );
  }

  Widget get getBottomFrameForTimeRequest {
    switch (userMode) {
      case UserMode.REQUEST_CREATOR:
        return getBottombarForCreator;

      case UserMode.TIMEBANK_ADMIN:
      case UserMode.APPROVED_MEMBER:
      case UserMode.ACCEPTED_MEMBER:
      case UserMode.COMPLETED_MEMBER:
      case UserMode.AWAITING_FOR_APPROVAL_FROM_CREATOR:
      case UserMode.NOT_YET_SIGNED_UP:
        return getBottombarForParticipant;

      default:
        return getBottombarForParticipant;
    }
  }

  Widget get getBottombarForCreator {
    if (widget.requestItem.requestType == RequestType.TIME) {
      canDeleteRequest = widget.requestItem.sevaUserId ==
              SevaCore.of(context).loggedInUser.sevaUserID &&
          widget.requestItem.acceptors.length == 0 &&
          widget.requestItem.approvedUsers.length == 0 &&
          widget.requestItem.invitedUsers.length == 0;
    } else if (widget.requestItem.requestType == RequestType.GOODS) {
      canDeleteRequest = widget.requestItem.sevaUserId ==
              SevaCore.of(context).loggedInUser.sevaUserID &&
          widget.requestItem.goodsDonationDetails.donors == null;
    } else {
      canDeleteRequest = widget.requestItem.sevaUserId ==
              SevaCore.of(context).loggedInUser.sevaUserID &&
          widget.requestItem.cashModel.amountRaised == 0;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: S.of(context).creator_of_request_message,
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
          offstage: !canDeleteRequest,
          child: Container(
            margin: EdgeInsets.only(right: 5),
            width: 100,
            height: 32,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(0),
              color: Colors.green,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 1),
                  Spacer(),
                  Text(
                    S.of(context).delete,
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
                deleteRequestDialog();
              },
            ),
          ),
        )
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

  void applyAction() async {
    if (isApplied) {
      _withdrawRequest();
    } else {
      if (widget.requestItem.projectId != null &&
          widget.requestItem.projectId.isNotEmpty) {
        await ProjectMessagingRoomHelper.createAdvisoryForJoiningMessagingRoom(
          context: context,
          requestId: widget.requestItem.id,
          projectId: widget.requestItem.projectId,
          timebankId: widget.requestItem.timebankId,
          candidateUserModel: SevaCore.of(context).loggedInUser,
          requestMode: widget.requestItem.requestMode,
        ).then((value) {
          proccedWithCalander();
        });
      } else {
        proccedWithCalander();
      }
    }
  }

  void proccedWithCalander() {
    if (SevaCore.of(context).loggedInUser.calendarId != null) {
      showDialog(
        context: context,
        builder: (_context) {
          return CalenderEventConfirmationDialog(
            title: widget.requestItem.title,
            isrequest: true,
            cancelled: () async {
              await _acceptRequest();
              Navigator.pop(_context);
              Navigator.pop(context);
            },
            addToCalender: () async {
              await _acceptRequest();
              Set<String> acceptorList =
                  Set.from(widget.requestItem.allowedCalenderUsers);
              acceptorList.add(SevaCore.of(context).loggedInUser.email);
              widget.requestItem.allowedCalenderUsers = acceptorList.toList();
              await FirestoreManager.updateRequest(
                  requestModel: widget.requestItem);
              Navigator.pop(_context);
              Navigator.pop(context);
            },
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (_context) {
          return CalenderEventConfirmationDialog(
            title: widget.requestItem.title,
            isrequest: true,
            cancelled: () async {
              await _acceptRequest();
              Navigator.pop(_context);
              Navigator.pop(context);
            },
            addToCalender: () async {
              await _acceptRequest();
              Navigator.pop(_context);
              _settingModalBottomSheet(context);
            },
          );
        },
      );
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
    bool alreadyCompleted = false;
    if (widget.requestItem.transactions != null) {
      for (int i = 0; i < widget.requestItem.transactions.length; i++) {
        if (widget.requestItem.transactions[i].to ==
            SevaCore.of(context).loggedInUser.sevaUserID) {
          alreadyCompleted = true;
          break;
        }
      }
    }
    if (!alreadyCompleted) {
      bool isAlreadyApproved = widget.requestItem.approvedUsers
          .contains(SevaCore.of(context).loggedInUser.email);
      var assosciatedEmail = SevaCore.of(context).loggedInUser.email;
      Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
      acceptorList.remove(assosciatedEmail);
      widget.requestItem.acceptors = acceptorList.toList();
      if (widget.requestItem.allowedCalenderUsers.contains(assosciatedEmail)) {
        Set<String> allowedCalenderUsersList =
            Set.from(widget.requestItem.allowedCalenderUsers);
        allowedCalenderUsersList.remove(assosciatedEmail);
        widget.requestItem.allowedCalenderUsers =
            allowedCalenderUsersList.toList();
      }
      if (widget.requestItem.approvedUsers.contains(assosciatedEmail)) {
        Set<String> approvedUsers = Set.from(widget.requestItem.approvedUsers);
        Set<String> calenderUsers =
            Set.from(widget.requestItem.allowedCalenderUsers);
        approvedUsers.remove(SevaCore.of(context).loggedInUser.email);
        if (calenderUsers.contains(SevaCore.of(context).loggedInUser.email)) {
          calenderUsers.remove(SevaCore.of(context).loggedInUser.email);
          widget.requestItem.allowedCalenderUsers = calenderUsers.toList();
        }
        widget.requestItem.approvedUsers = approvedUsers.toList();
      }

      if (widget.requestItem.projectId != null &&
          widget.requestItem.projectId.isNotEmpty)
        ProjectMessagingRoomHelper.removeMemberFromProjectCommuication(
          projectId: widget.requestItem.projectId,
          timebankId: widget.requestItem.timebankId,
          candidateUserModel: SevaCore.of(context).loggedInUser,
          requestMode: widget.requestItem.requestMode,
        );

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
    } else {
      _showAlreadyApprovedMessage();
    }
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
      DateFormat('EEEEEEE, MMMM dd', Locale(getLangTag()).toLanguageTag())
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
      // DateFormat('h:mm a', Locale(getLangTag()).toLanguageTag()).format(
      //       getDateTimeAccToUserTimezone(
      //           dateTime: DateTime.fromMillisecondsSinceEpoch(
      //               widget.requestItem.requestStart),
      //           timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
      //     ) +
      DateFormat.MMMd(getLangTag()).add_jm().format(
                getDateTimeAccToUserTimezone(
                  dateTime: DateTime.fromMillisecondsSinceEpoch(
                    widget.requestItem.requestStart,
                  ),
                  timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
                ),
              ) +
          ' - ' +
          DateFormat.MMMd(getLangTag()).add_jm().format(
                getDateTimeAccToUserTimezone(
                  dateTime: DateTime.fromMillisecondsSinceEpoch(
                      widget.requestItem.requestEnd),
                  timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
                ),
                // ),
                // DateFormat('h:mm a', Locale(getLangTag()).toLanguageTag()).format(
                //   getDateTimeAccToUserTimezone(
                //     dateTime: DateTime.fromMillisecondsSinceEpoch(
                //         widget.requestItem.requestEnd),
                //     timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
                //   ),
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

  Widget get createdAt {
    return Text(
      timeAgo
          .format(
              DateTime.fromMillisecondsSinceEpoch(
                  widget.requestItem.postTimestamp),
              locale: Locale(getLangTag()).toLanguageTag())
          .replaceAll('hours ago', 'h'),
      style: TextStyle(
        fontFamily: 'Europa',
        fontSize: 16,
        color: Colors.black38,
      ),
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
    switch (widget.requestItem.requestType) {
      case RequestType.GOODS:
        return getAddressWidgetForGoodsDonationRequest;

      case RequestType.CASH:
        return getCashDetailsForCashDonations;

      case RequestType.TIME:
        return timeDetailsForTimerequest;

      default:
        return timeDetailsForTimerequest;
    }
  }

  Widget get timeDetailsForTimerequest {
    return Text(
      widget.requestItem.description,
      style: TextStyle(fontSize: 16),
    );
  }

  Widget get getCashDetailsForCashDonations {
    switch (widget.requestItem.cashModel.paymentType) {
      case RequestPaymentType.ACH:
        return getACHDetails;

      case RequestPaymentType.ZELLEPAY:
        return timeDetailsForTimerequest;

      case RequestPaymentType.PAYPAL:
        return timeDetailsForTimerequest;

      default:
        return timeDetailsForTimerequest;
    }
  }

  // Widget get getZelpayAndPaypalDetails

  Widget get getACHDetails {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            widget.requestItem.description,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Text(
          "Account number : " +
              widget.requestItem.cashModel.achdetails.account_number,
        ),
        Text(
          "${S.of(context).bank_address} : " +
              widget.requestItem.cashModel.achdetails.bank_address,
        ),
        Text(
          "Bank Name : " + widget.requestItem.cashModel.achdetails.bank_name,
        ),
        Text(
          "${S.of(context).routing_number} : " +
              widget.requestItem.cashModel.achdetails.routing_number,
        ),
      ],
    );
  }

  Widget get getAddressWidgetForGoodsDonationRequest {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.requestItem.description,
          style: TextStyle(fontSize: 16),
        ),
        Container(
          margin: EdgeInsets.only(top: 20),
          child: Text(
            'Donation Address',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Text(
            widget.requestItem.goodsDonationDetails.address ?? '',
          ),
        ),
      ],
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
            onTap: () {},
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
    return FutureBuilder<int>(
        future: FirestoreManager.getRequestRaisedGoods(
            requestId: widget.requestItem.id),
        builder: (context, snapshot) {
          return CustomListTile(
            title: Text(
              S.of(context).total_goods_recevied,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(''),
            leading: Image.asset(
              SevaAssetIcon.donateGood,
              height: 30,
              width: 30,
            ),
            trailing: Text(
              "${snapshot.data ?? ''}",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                // fontWeight: FontWeight.bold,
              ),
            ),
          );
        });
  }

//  Widget getBottombar() {
//    canDeleteRequest = widget.requestItem.sevaUserId ==
//            SevaCore.of(context).loggedInUser.sevaUserID &&
//        widget.requestItem.acceptors.length == 0 &&
//        widget.requestItem.approvedUsers.length == 0 &&
//        widget.requestItem.invitedUsers.length == 0;
//    return Container(
//      decoration: BoxDecoration(color: Colors.white54, boxShadow: [
//        BoxShadow(color: Colors.grey[300], offset: Offset(2.0, 2.0))
//      ]),
//      child: Padding(
//        padding: const EdgeInsets.only(top: 20.0, left: 20, bottom: 20),
//        child: Row(
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: <Widget>[
//            Expanded(
//              child: RichText(
//                text: TextSpan(
//                  style: TextStyle(color: Colors.black),
//                  children: [
//                    TextSpan(
//                      text: widget.requestItem.sevaUserId ==
//                              SevaCore.of(context).loggedInUser.sevaUserID
//                          ? S.of(context).creator_of_request_message
//                          : isApplied
//                              ? S.of(context).applied_for_request
//                              : S.of(context).particpate_in_request_question,
//                      style: TextStyle(
//                        fontSize: 16,
//                        fontFamily: 'Europa',
//                        fontWeight: FontWeight.bold,
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//            ),
//            Offstage(
//              offstage: widget.requestItem.sevaUserId ==
//                  SevaCore.of(context).loggedInUser.sevaUserID,
//              child: Container(
//                margin: EdgeInsets.only(right: 5),
//                width: 100,
//                height: 32,
//                child: FlatButton(
//                  shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.circular(20),
//                  ),
//                  padding: EdgeInsets.all(0),
//                  color:
//                      isApplied ? Theme.of(context).accentColor : Colors.green,
//                  child: Row(
//                    children: <Widget>[
//                      SizedBox(width: 1),
//                      Spacer(),
//                      Text(
//                        isApplied
//                            ? S.of(context).withdraw
//                            : S.of(context).apply,
//                        textAlign: TextAlign.center,
//                        style: TextStyle(
//                          color: Colors.white,
//                        ),
//                      ),
//                      Spacer(
//                        flex: 1,
//                      ),
//                    ],
//                  ),
//                  onPressed: () {
//                    if (SevaCore.of(context).loggedInUser.calendarId == null) {
//                      log("user has calendarrrrrrrrr");
//                      _settingModalBottomSheet(context);
//                    } else {
//                      log("user has no calendarrrrrrrrr");
//                      applyAction();
//                    }
//                  },
//                ),
//              ),
//            )
//          ],
//        ),
//      ),
//    );
//  }

  void deleteRequestDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            S.of(context).delete_request,
          ),
          content: Text(
            S.of(context).delete_request_confirmation,
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => {Navigator.of(dialogContext).pop()},
              child: Text(
                S.of(context).cancel,
                style: TextStyle(fontSize: dialogButtonSize, color: Colors.red),
              ),
            ),
            FlatButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              textColor: FlavorConfig.values.buttonTextColor,
              onPressed: () async {
                await deleteRequest().commit();
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                S.of(context).delete,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget optionText({String title}) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
      ),
    );
  }

  WriteBatch deleteRequest() {
    //add to timebank members

    WriteBatch batch = Firestore.instance.batch();
    var requestRef = Firestore.instance
        .collection('requests')
        .document(widget.requestItem.id);

    if (widget.requestItem.projectId != null) {
      var projectsRef = Firestore.instance
          .collection('projects')
          .document(widget.requestItem.projectId);
      batch.updateData(projectsRef, {
        'pendingRequests': FieldValue.arrayRemove([widget.requestItem.id])
      });
    }

    batch.delete(requestRef);

    return batch;
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
    Map<String, dynamic> stateOfcalendarCallback = {
      "email": SevaCore.of(context).loggedInUser.email,
      "mobile": globals.isMobile,
      "envName": FlavorConfig.values.envMode,
      "eventsArr": []
    };
    log("inside bottom sheet");
    var stateVar = jsonEncode(stateOfcalendarCallback);
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
                      TransactionsMatrixCheck(
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calendar_sync",
                        comingFrom: ComingFrom.Requests,
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset(
                                  "lib/assets/images/googlecal.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=google_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              Set<String> acceptorList = Set.from(
                                  widget.requestItem.allowedCalenderUsers);
                              acceptorList
                                  .add(SevaCore.of(context).loggedInUser.email);
                              widget.requestItem.allowedCalenderUsers =
                                  acceptorList.toList();
                              await FirestoreManager.updateRequest(
                                  requestModel: widget.requestItem);
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                              Navigator.pop(context);
                            }),
                      ),
                      TransactionsMatrixCheck(
                        comingFrom: ComingFrom.Requests,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calendar_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset(
                                  "lib/assets/images/outlookcal.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${stateVar}&redirect_uri=$redirectUrl";

                              Set<String> acceptorList = Set.from(
                                  widget.requestItem.allowedCalenderUsers);
                              acceptorList
                                  .add(SevaCore.of(context).loggedInUser.email);
                              widget.requestItem.allowedCalenderUsers =
                                  acceptorList.toList();
                              await FirestoreManager.updateRequest(
                                  requestModel: widget.requestItem);

                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                              Navigator.pop(context);
                            }),
                      ),
                      TransactionsMatrixCheck(
                        comingFrom: ComingFrom.Requests,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calendar_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset("lib/assets/images/ical.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=icloud_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              Set<String> acceptorList = Set.from(
                                  widget.requestItem.allowedCalenderUsers);
                              acceptorList
                                  .add(SevaCore.of(context).loggedInUser.email);
                              widget.requestItem.allowedCalenderUsers =
                                  acceptorList.toList();
                              await FirestoreManager.updateRequest(
                                  requestModel: widget.requestItem);
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                              Navigator.pop(context);
                            }),
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    FlatButton(
                        child: Text(
                          S.of(context).skip_for_now,
                          style: TextStyle(
                              color: FlavorConfig.values.theme.primaryColor),
                        ),
                        onPressed: () async {
                          Navigator.of(bc).pop();
                          Navigator.pop(context);
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
    var currentPercentage = widget.requestItem.cashModel.amountRaised /
        widget.requestItem.cashModel.targetAmount;
    return Column(
      children: [
        CustomListTile(
          title: Text(
            S.of(context).total_amount_raised,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text('\$${widget.requestItem.cashModel.amountRaised}'),
          leading: Image.asset(
            widget.requestItem.requestType == RequestType.CASH
                ? SevaAssetIcon.donateCash
                : SevaAssetIcon.donateGood,
            height: 30,
            width: 30,
          ),
          trailing: Text(
            '',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        Stack(
          children: <Widget>[
            SizedBox(
              height: 22,
              child: Container(
                margin: EdgeInsets.only(left: 30, bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                    minHeight: 25,
                    value: (widget.requestItem.cashModel.amountRaised /
                        widget.requestItem.cashModel.targetAmount),
                  ),
                ),
              ),
            ),
            Positioned(
              child: Center(
                child: Text(
                  "${(currentPercentage * 100)}%",
                  style: TextStyle(
                    fontSize: 10,
                    color: currentPercentage > 50 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
