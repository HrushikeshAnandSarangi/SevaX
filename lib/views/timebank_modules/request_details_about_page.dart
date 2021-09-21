import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/calendar_events/models/kloudless_models.dart';
import 'package:sevaexchange/components/calendar_events/module/index.dart';
import 'package:sevaexchange/components/calender_event_confirm_dialog.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/basic_user_details.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/acceptor_model.dart';
import 'package:sevaexchange/new_baseline/models/borrow_accpetor_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/ui/screens/borrow_agreement/borrow_agreement_pdf.dart';
import 'package:sevaexchange/ui/screens/notifications/pages/personal_notifications.dart';
import 'package:sevaexchange/ui/screens/offers/pages/lending_offer_details.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/lending_item_card_widget.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/lending_place_card_widget.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/lending_place_details_widget.dart';
import 'package:sevaexchange/ui/screens/request/pages/oneToManyCreatorCompleteRequestPage.dart';
import 'package:sevaexchange/ui/screens/request/pages/oneToManySpeakerTimeEntryComplete_page.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/projects_helper.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request/edit_request.dart';
import 'package:sevaexchange/views/requests/approveBorrowRequest.dart';
import 'package:sevaexchange/views/requests/donations/donation_view.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';
import 'package:sevaexchange/widgets/full_screen_widget.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:url_launcher/url_launcher.dart';

import '../../flavor_config.dart';
// import 'package:timezone/browser.dart';

class RequestDetailsAboutPage extends StatefulWidget {
  final RequestModel requestItem;
  final TimebankModel timebankModel;
  final bool applied;
  final bool isAdmin;
  final CommunityModel communityModel;

  RequestDetailsAboutPage({
    Key key,
    this.applied = false,
    @required this.requestItem,
    this.timebankModel,
    this.isAdmin,
    this.communityModel,
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
  TIMEBANK_CREATOR,
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
  var recurringRequestsDocs;
  bool deletingParent = false;
  bool isApproved = false;

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
    // logger.i("===>>   " + widget.requestItem.requestMode.toString());

    switch (widget.requestItem.requestMode) {
      case RequestMode.PERSONAL_REQUEST:
        if (utils.isDeletable(
            contentCreatorId: widget.requestItem.sevaUserId,
            context: context,
            communityCreatorId:
                // BlocProvider.of<HomeDashBoardBloc>(context)
                //     .selectedCommunityModel.created_by
                isPrimaryTimebank(
                        parentTimebankId: widget.timebankModel.parentTimebankId)
                    ? widget.timebankModel.creatorId
                    : widget.timebankModel.managedCreatorIds.length > 0
                        ? widget.timebankModel.managedCreatorIds.first
                        : widget.timebankModel.creatorId,
            // ? widget.timebankModel.creatorId
            // : widget.timebankModel.managedCreatorIds.first,
            // '',
            timebankCreatorId: widget.timebankModel.creatorId))
          return UserMode.TIMEBANK_CREATOR;
        else if (widget.requestItem.sevaUserId == loggedInUser)
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
        if (utils.isDeletable(
          contentCreatorId: widget.requestItem.sevaUserId,
          context: context,
          communityCreatorId:
              // BlocProvider.of<HomeDashBoardBloc>(context)
              //     .selectedCommunityModel
              //     .created_by
              isPrimaryTimebank(
                      parentTimebankId: widget.timebankModel.parentTimebankId)
                  ? widget.timebankModel.creatorId
                  : widget.timebankModel.managedCreatorIds.first,
          timebankCreatorId: widget.timebankModel.creatorId,
        )) return UserMode.TIMEBANK_CREATOR;

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
        S.of(context).request_details,
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

      isApproved = widget.requestItem.approvedUsers
          .contains(SevaCore.of(context).loggedInUser.email);

      log('is approved?  ' + isApproved.toString());

      isApplied = widget.requestItem.acceptors
              .contains(SevaCore.of(context).loggedInUser.email) ||
          widget.requestItem.approvedUsers
              .contains(SevaCore.of(context).loggedInUser.email) ||
          widget.requestItem.invitedUsers
              .contains(SevaCore.of(context).loggedInUser.sevaUserID) ||
          false;
    } else {
      isApplied = false;
      isApproved = false;
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
                  (widget.requestItem.imageUrls == null ||
                          widget.requestItem.imageUrls.length < 1)
                      ? Container()
                      : requestImages,
                  SizedBox(height: 20),
                  requestTitleComponent,
                  SizedBox(height: 5),
                  widget.requestItem.requestType == RequestType.BORROW
                      ? borrowRequestItemPlaceTag(widget.requestItem.roomOrTool)
                      : Container(),
                  SizedBox(height: 5),
                  widget.requestItem.requestType == RequestType.BORROW &&
                          widget.requestItem.roomOrTool ==
                              LendingType.ITEM.readable &&
                          widget.requestItem.borrowModel.requiredItems != null
                      ? borrowItemsWidget
                      : Container(),
                  SizedBox(height: 10),
                  getRequestModeComponent,
                  widget.requestItem.requestType == RequestType.BORROW
                      ? Container()
                      : timestampComponent,
                  widget.requestItem.requestType == RequestType.BORROW
                      ? timestampComponentBorrowRequest
                      : Container(),
                  widget.requestItem.requestType == RequestType.BORROW
                      ? Container()
                      : createdAt,
                  widget.requestItem.requestType == RequestType.BORROW
                      ? Container()
                      : addressComponent,
                  widget.requestItem.requestType == RequestType.BORROW
                      ? Container()
                      : hostNameComponent,
                  widget.requestItem.requestType == RequestType.BORROW
                      ? requestDescriptionComponent
                      : Container(),
                  widget.requestItem.requestType == RequestType.BORROW
                      ? addressComponentBorrowRequest
                      : Container(),
                  (widget.requestItem.requestType == RequestType.BORROW &&
                          SevaCore.of(context).loggedInUser.sevaUserID !=
                              widget.requestItem.sevaUserId)
                      ? requestedByBorrowRequestComponent
                      : Container(),
                  (widget.requestItem.requestType ==
                              RequestType.ONE_TO_MANY_REQUEST &&
                          widget.requestItem.oneToManyRequestAttenders.length >=
                              1 &&
                          (userMode == UserMode.TIMEBANK_CREATOR ||
                              userMode == UserMode.REQUEST_CREATOR ||
                              userMode == UserMode.TIMEBANK_ADMIN))
                      ? Expanded(
                          flex: 1,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.width * 0.24,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('${widget.requestItem.oneToManyRequestAttenders.length} ' +
                                    S.of(context).of_text +
                                    ' ${widget.requestItem.numberOfApprovals}' +
                                    S.of(context).people_applied_for_request),
                                StreamBuilder(
                                    stream: CollectionRef.requests
                                        .doc(widget.requestItem.id)
                                        .collection('oneToManyAttendeesDetails')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Text(
                                          S.of(context).no_image_available,
                                        );
                                      } else {
                                        return Expanded(
                                          flex: 1,
                                          child: ListView.builder(
                                            reverse: true,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                snapshot.data.docs.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(snapshot
                                                                    .data
                                                                    .docs[index]
                                                                ['photoURL'] ??
                                                            defaultUserImageURL),
                                                    minRadius: 23.0),
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    }),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  (widget.requestItem.requestType ==
                              RequestType.ONE_TO_MANY_REQUEST &&
                          widget.requestItem.selectedInstructor != null &&
                          (userMode == UserMode.TIMEBANK_CREATOR ||
                              userMode == UserMode.REQUEST_CREATOR ||
                              userMode == UserMode.TIMEBANK_ADMIN))
                      ? Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.of(context).speaker,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  CircleAvatar(
                                      backgroundImage: NetworkImage(widget
                                              .requestItem
                                              .selectedInstructor
                                              .photoURL ??
                                          defaultUserImageURL),
                                      minRadius: 34.0),
                                  SizedBox(width: 25),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            widget.requestItem
                                                .selectedInstructor.fullname,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500)),
                                        SizedBox(height: 7),
                                        widget
                                                    .requestItem
                                                    .selectedSpeakerTimeDetails
                                                    .speakingTime ==
                                                null
                                            ? Text(
                                                S.of(context).hours_not_updated,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey))
                                            : Text(
                                                S
                                                        .of(context)
                                                        .duration_of_session +
                                                    widget
                                                        .requestItem
                                                        .selectedSpeakerTimeDetails
                                                        .speakingTime
                                                        .toString() +
                                                    ' ' +
                                                    (widget
                                                                .requestItem
                                                                .selectedSpeakerTimeDetails
                                                                .speakingTime >
                                                            1.0
                                                        ? S.of(context).hours
                                                        : S.of(context).hour),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                            ],
                          ),
                        )
                      : Container(),
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
                  widget.requestItem.requestType == RequestType.BORROW
                      ? Container()
                      : requestDescriptionComponent,
                  SizedBox(height: 20),
                  (widget.requestItem.requestType == RequestType.BORROW &&
                          widget.requestItem.approvedUsers.length > 0 &&
                          (widget.requestItem.email ==
                                  SevaCore.of(context).loggedInUser.email ||
                              widget.requestItem.approvedUsers.contains(
                                  SevaCore.of(context).loggedInUser.email)))
                      ? approvedBorrowRequestViewAgreementComponent
                      : Container(),
                  SizedBox(height: 10),
                ],
              ),
            ),
            getBottomFrame,
            HideWidget(
              hide: widget.requestItem.sevaUserId !=
                      SevaCore.of(context).loggedInUser.sevaUserID ||
                  widget.requestItem.accepted == true,
              child: InkWell(
                onTap: () async {
                  await CollectionRef.requests
                      .doc(widget.requestItem.id)
                      .update({'accepted': true});
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  color: FlavorConfig.values.theme.primaryColor,
                  child: Center(
                    child: Text(
                      S.of(context).close + ' ' + S.of(context).request,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget get requestImages {
    return Container(
      height: 200,
      child: ListView.builder(
          itemCount: widget.requestItem.imageUrls.length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return FullScreenImage(
                          imageUrl: widget.requestItem.imageUrls[index],
                        );
                      });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Image.network(widget.requestItem.imageUrls[index]),
                ));
          }),
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
    var user = await CollectionRef.users.doc(memberEmail).get();

    return user.data();
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
        return widget.requestItem.accepted
            ? requestClosed
            : getBottomFrameForCashRequest;

      case RequestType.GOODS:
        return widget.requestItem.accepted
            ? requestClosed
            : getBottomFrameForGoodRequest;

      case RequestType.BORROW:
        return widget.requestItem.accepted
            ? requestClosed
            : getBottomFrameForBorrowRequest;

      case RequestType.TIME:
        return widget.requestItem.accepted
            ? requestClosed
            : getBottomFrameForTimeRequest;

      case RequestType.ONE_TO_MANY_REQUEST:
        return widget.requestItem.accepted
            ? requestClosed
            : getBottomFrameForOneToManyRequest;

      default:
        return getBottomFrameForTimeRequest;
    }
  }

  Widget get getBottomFrameForOneToManyRequest {
    if (UserMode == UserMode.TIMEBANK_CREATOR) {
      return getBottombarForTimebankCreator;
    } else if (widget.requestItem.sevaUserId ==
        SevaCore.of(context).loggedInUser.sevaUserID) {
      return getBottombarForCreator;
    } else if (widget.requestItem.acceptors
        .contains(SevaCore.of(context).loggedInUser.email)) {
      return getOneToManySpeakerWidget;
    } else {
      return getBottombarAttenders;
    }
  }

  Widget get requestClosed {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).request_closed,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Europa',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget get getOneToManySpeakerWidget {
    if (widget.requestItem.acceptors
            .contains(SevaCore.of(context).loggedInUser.email) &&
        widget.requestItem.approvedUsers
            .contains(SevaCore.of(context).loggedInUser.email)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: (widget.requestItem.acceptors.contains(
                                SevaCore.of(context).loggedInUser.email) &&
                            widget.requestItem.isSpeakerCompleted)
                        ? S.of(context).requested_for_completion
                        : S.of(context).you_are_the_speaker +
                            widget.requestItem.title,
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
          // widget.requestItem.isSpeakerCompleted
          //     ? Container()
          //     : speakerWithdrawOneToManyRequest,

          widget.requestItem.isSpeakerCompleted
              ? Container()
              : speakerCompleteOneToManyRequest,
          SizedBox(width: 7),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: widget.requestItem.acceptors
                            .contains(SevaCore.of(context).loggedInUser.email)
                        ? S.of(context).you_are_the_speaker +
                            widget.requestItem.title
                        : S.of(context).you_are_the_speaker +
                            widget.requestItem.title,
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
          SizedBox(width: 3),
          rejectOneToManySpeakerRequest,
          SizedBox(width: 6),
          acceptOneToManySpeakerRequest,
          SizedBox(width: 7),
        ],
      );
    }
  }

  Widget get acceptOneToManySpeakerRequest {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: CustomTextButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(0),
        color: FlavorConfig.values.theme.primaryColor,
        child: Row(
          children: <Widget>[
            SizedBox(width: 1),
            Spacer(),
            Text(
              S.of(context).accept,
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
        onPressed: () async {
          showDialog(
              context: context,
              builder: (BuildContext viewContext) {
                return AlertDialog(
                  title:
                      Text(S.of(context).oneToManyRequestSpeakerAcceptRequest),
                  actions: <Widget>[
                    CustomTextButton(
                      color: Theme.of(context).primaryColor,
                      child: Text(
                        S.of(context).yes,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onPressed: () async {
                        await oneToManySpeakerInviteAccepted(
                            widget.requestItem, context);

                        Navigator.of(viewContext).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                    CustomTextButton(
                      color: Theme.of(context).accentColor,
                      child: Text(
                        S.of(context).no,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(viewContext).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });

          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (context) {
          //       return OneToManySpeakerTimeEntry(
          //         requestModel: widget.requestItem,
          //         onFinish: () async {
          //           await oneToManySpeakerInviteAccepted(
          //               widget.requestItem, context);
          //           // await onDismissed();
          //         },
          //       );
          //     },
          //   ),
          // );
        },
      ),
    );
  }

  Widget get rejectOneToManySpeakerRequest {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: CustomTextButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(0),
        color: Theme.of(context).accentColor,
        child: Row(
          children: <Widget>[
            SizedBox(width: 1),
            Spacer(),
            Text(
              S.of(context).reject,
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
          showDialog(
              context: context,
              builder: (BuildContext viewContext) {
                return AlertDialog(
                  title: Text(S.of(context).speaker_reject_invite_dialog),
                  actions: <Widget>[
                    CustomTextButton(
                      color: Theme.of(context).primaryColor,
                      child: Text(
                        S.of(context).yes,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onPressed: () async {
                        Navigator.of(viewContext).pop();
                        await oneToManySpeakerInviteRejected(
                                widget.requestItem, context)
                            .then((e) => Navigator.of(context).pop());
                        // await onDismissed();
                      },
                    ),
                    CustomTextButton(
                      color: Theme.of(context).accentColor,
                      child: Text(
                        S.of(context).no,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(viewContext).pop();
                      },
                    ),
                  ],
                );
              });
        },
      ),
    );
  }

  Widget get speakerWithdrawOneToManyRequest {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: CustomTextButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(0),
        color: Theme.of(context).accentColor,
        child: Row(
          children: <Widget>[
            SizedBox(width: 1),
            Spacer(),
            Text(
              S.of(context).withdraw,
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
          showDialog(
              context: context,
              builder: (BuildContext viewContext) {
                return AlertDialog(
                  title:
                      Text(S.of(context).oneToManyRequestSpeakerWithdrawDialog),
                  actions: <Widget>[
                    CustomTextButton(
                      color: Theme.of(context).primaryColor,
                      child: Text(
                        S.of(context).yes,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onPressed: () async {
                        Navigator.of(viewContext).pop();
                        await oneToManySpeakerInviteRejected(
                            widget.requestItem, context);
                        // await onDismissed();
                      },
                    ),
                    CustomTextButton(
                      color: Theme.of(context).accentColor,
                      child: Text(
                        S.of(context).no,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(viewContext).pop();
                      },
                    ),
                  ],
                );
              });
        },
      ),
    );
  }

  Widget get speakerCompleteOneToManyRequest {
    return Container(
      width: MediaQuery.of(context).size.width * 0.29,
      child: CustomTextButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(0),
        color: FlavorConfig.values.theme.primaryColor,
        child: Row(
          children: <Widget>[
            SizedBox(width: 1),
            Spacer(),
            Text(
              S.of(context).speaker_claim_credits,
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
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return OneToManySpeakerTimeEntryComplete(
                  userModel: SevaCore.of(context).loggedInUser,
                  requestModel: widget.requestItem,
                  onFinish: () async {
                    await oneToManySpeakerRequestCompleted(
                        widget.requestItem, context);
                    Navigator.of(context).pop();
                  },
                  isFromtasks: false,
                );
              },
            ),
          ).then((e) => Navigator.of(context).pop());

          // showDialog(
          //     context: context,
          //     builder: (BuildContext viewContext) {
          //       return AlertDialog(
          //         title: Text('Are you sure you want to complete the request?'),
          //         actions: <Widget>[
          //           CustomTextButton(
          //             color: Theme.of(context).primaryColor,
          //             child: Text(
          //               S.of(context).yes,
          //               style: TextStyle(fontSize: 16, color: Colors.white),
          //             ),
          //             onPressed: () async {
          //               Navigator.of(viewContext).pop();
          //               await oneToManySpeakerRequestCompleted(
          //                   widget.requestItem, context);
          //               Navigator.of(context).pop();
          //               // await onDismissed();
          //             },
          //           ),
          //           CustomTextButton(
          //             color: Theme.of(context).accentColor,
          //             child: Text(
          //               S.of(context).no,
          //               style: TextStyle(fontSize: 16, color: Colors.white),
          //             ),
          //             onPressed: () {
          //               Navigator.of(viewContext).pop();
          //             },
          //           ),
          //         ],
          //       );
          //     });
        },
      ),
    );
  }

  Widget get getBottomFrameForGoodRequest {
    if (userMode == UserMode.TIMEBANK_CREATOR) {
      return getBottombarForTimebankCreator;
    } else if (widget.requestItem.sevaUserId ==
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
    if (userMode == UserMode.TIMEBANK_CREATOR) {
      return getBottombarForTimebankCreator;
    } else if (widget.requestItem.sevaUserId ==
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
        cashRequestActionForPartcipant,
      ],
    );
  }

  Widget get cashRequestActionForPartcipant {
    return Container(
      margin: EdgeInsets.only(right: 5),
      width: 100,
      height: 32,
      child: CustomTextButton(
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
        goodsRequestActionButtonForParticipant,
      ],
    );
  }

  Widget get goodsRequestActionButtonForParticipant {
    return Container(
      margin: EdgeInsets.only(right: 5),
      width: 100,
      height: 32,
      child: CustomTextButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(0),
        color: Theme.of(context).accentColor,
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
      case UserMode.TIMEBANK_CREATOR:
        return getBottombarForTimebankCreator;

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

  Widget get getBottomFrameForBorrowRequest {
    switch (userMode) {
      case UserMode.TIMEBANK_CREATOR:
        return getBottombarForTimebankCreator;

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

  Widget get getBottombarForTimebankCreator {
    String textLabel = '';
    Widget actionWidget;
    Widget actionWidgetTwo;
    var canDelete = false;
    if (widget.requestItem.requestType == RequestType.TIME) {
      canDelete = widget.requestItem.acceptors.length == 0 &&
          widget.requestItem.approvedUsers.length == 0 &&
          widget.requestItem.invitedUsers.length == 0;

      textLabel = widget.requestItem.sevaUserId ==
              SevaCore.of(context).loggedInUser.sevaUserID
          ? S.of(context).creator_of_request_message
          : isApplied
              ? S.of(context).accepted_this_request
              : S.of(context).particpate_in_request_question;

      actionWidget = widget.requestItem.sevaUserId ==
              SevaCore.of(context).loggedInUser.sevaUserID
          ? Container()
          : timeRequestActionWidgetForParticipant;
    } else if (widget.requestItem.requestType == RequestType.GOODS) {
      canDelete = widget.requestItem.goodsDonationDetails.donors == null ||
          widget.requestItem.goodsDonationDetails.donors.length < 1;
      textLabel = widget.requestItem.sevaUserId ==
              SevaCore.of(context).loggedInUser.sevaUserID
          ? S.of(context).creator_of_request_message
          : S.of(context).would_like_to_donate;

      actionWidget = widget.requestItem.sevaUserId ==
              SevaCore.of(context).loggedInUser.sevaUserID
          ? Container()
          : goodsRequestActionButtonForParticipant;
    } else if (widget.requestItem.requestType == RequestType.BORROW) {
      canDelete = widget.requestItem.participantDetails != null &&
          widget.requestItem.acceptors.length == 0;

      if (widget.requestItem.approvedUsers.length >= 1) {
        textLabel = (widget.requestItem.sevaUserId ==
                    SevaCore.of(context).loggedInUser.sevaUserID ||
                widget.requestItem.approvedUsers
                    .contains(SevaCore.of(context).loggedInUser.email))
            ? S.of(context).request_approved
            : S.of(context).request_has_been_assigned_to_a_member;
      } else if (widget.requestItem.roomOrTool == 'PLACE') {
        textLabel = widget.requestItem.sevaUserId ==
                SevaCore.of(context).loggedInUser.sevaUserID
            ? S.of(context).creator_of_request_message
            : S.of(context).borrow_request_for_place;
      } else {
        textLabel = widget.requestItem.sevaUserId ==
                SevaCore.of(context).loggedInUser.sevaUserID
            ? S.of(context).creator_of_request_message
            : S.of(context).borrow_request_for_item;
      }

      actionWidget = widget.requestItem.sevaUserId ==
              SevaCore.of(context).loggedInUser.sevaUserID
          ? Container()
          : (widget.requestItem.approvedUsers.length >= 1
              ? Container()
              : timeRequestActionWidgetForParticipant);
    } else if (widget.requestItem.requestType ==
        RequestType.ONE_TO_MANY_REQUEST) {
      canDelete = widget.requestItem.acceptors.length == 0 &&
          widget.requestItem.approvedUsers.length == 0 &&
          widget.requestItem.invitedUsers.length == 0;

      if (widget.requestItem.sevaUserId ==
          SevaCore.of(context).loggedInUser.sevaUserID) {
        actionWidget = Container();
      } else if (widget.requestItem.acceptors
          .contains(SevaCore.of(context).loggedInUser.email)) {
        actionWidget = acceptOneToManySpeakerRequest;
        actionWidgetTwo = rejectOneToManySpeakerRequest;
      } else if (widget.requestItem.acceptors
          .contains(SevaCore.of(context).loggedInUser.email)) {
        actionWidget = Container();
      } else {
        actionWidget = oneToManyRequestActionWidgetForParticipant;
      }
    } else {
      canDelete = widget.requestItem.cashModel.amountRaised == 0 ||
          widget.requestItem.cashModel.amountRaised == null;
      textLabel = widget.requestItem.sevaUserId ==
              SevaCore.of(context).loggedInUser.sevaUserID
          ? S.of(context).creator_of_request_message
          : S.of(context).would_like_to_donate;
      actionWidget = widget.requestItem.sevaUserId ==
              SevaCore.of(context).loggedInUser.sevaUserID
          ? Container()
          : cashRequestActionForPartcipant;
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
                  text: textLabel,
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
        canDelete
            ? Row(
                children: [
                  actionWidget,
                  actionWidgetTwo == null ? Container() : actionWidgetTwo,
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 8),
                    width: 100,
                    height: 32,
                    child: CustomTextButton(
                      shape: StadiumBorder(),
                      color: Colors.red,
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
                        deleteRequestDialog(widget.requestItem);
                      },
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  actionWidget,
                  actionWidgetTwo == null ? Container() : actionWidgetTwo,
                ],
              ),
      ],
    );
  }

  Widget get getBottombarForCreator {
    log('inside  creator');

    if (widget.requestItem.requestType == RequestType.ONE_TO_MANY_REQUEST &&
        widget.requestItem.isSpeakerCompleted) {
      return getBottombarForCreatorSpeakerCompleted;
    } else {
      return (widget.requestItem.acceptors
              .contains(SevaCore.of(context).loggedInUser.email))
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: widget.requestItem.isSpeakerCompleted
                              ? S.of(context).request_completed_by_speaker
                              : S.of(context).creator_of_request_message,
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
                SizedBox(width: 5),
                Container(
                  width: MediaQuery.of(context).size.width * 0.29,
                  child: CustomTextButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(0),
                    color: FlavorConfig.values.theme.primaryColor,
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 1),
                        Spacer(),
                        Text(
                          S.of(context).speaker_claim_credits,
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
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return OneToManySpeakerTimeEntryComplete(
                              userModel: SevaCore.of(context).loggedInUser,
                              requestModel: widget.requestItem,
                              onFinish: () async {
                                await oneToManySpeakerRequestCompleted(
                                    widget.requestItem, context);
                                Navigator.of(context).pop();
                              },
                              isFromtasks: false,
                            );
                          },
                        ),
                      ).then((e) => Navigator.of(context).pop());

                      // showDialog(
                      //     context: context,
                      //     builder: (BuildContext viewContext) {
                      //       return AlertDialog(
                      //         title: Text('Are you sure you want to complete the request?'),
                      //         actions: <Widget>[
                      //           CustomTextButton(
                      //             color: Theme.of(context).primaryColor,
                      //             child: Text(
                      //               S.of(context).yes,
                      //               style: TextStyle(fontSize: 16, color: Colors.white),
                      //             ),
                      //             onPressed: () async {
                      //               Navigator.of(viewContext).pop();
                      //               await oneToManySpeakerRequestCompleted(
                      //                   widget.requestItem, context);

                      //               Navigator.of(context).pop();

                      //               // await onDismissed();
                      //             },
                      //           ),
                      //           CustomTextButton(
                      //             color: Theme.of(context).accentColor,
                      //             child: Text(
                      //               S.of(context).no,
                      //               style: TextStyle(fontSize: 16, color: Colors.white),
                      //             ),
                      //             onPressed: () {
                      //               Navigator.of(viewContext).pop();
                      //             },
                      //           ),
                      //         ],
                      //       );
                      //     });
                    },
                  ),
                ),
                SizedBox(width: 7),
              ],
            )
          : Row(
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
    }
  }

  Widget get getBottombarAttenders {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: widget.requestItem.oneToManyRequestAttenders
                          .contains(SevaCore.of(context).loggedInUser.email)
                      ? S.of(context).accepted_this_request
                      : widget.requestItem.isSpeakerCompleted == true
                          ? S.of(context).this_request_has_now_ended
                          : widget.requestItem.oneToManyRequestAttenders
                                      .length >=
                                  widget.requestItem.numberOfApprovals
                              ? S.of(context).maximumNoOfParticipants
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
        ((widget.requestItem.oneToManyRequestAttenders.length >=
                        widget.requestItem.numberOfApprovals ||
                    widget.requestItem.isSpeakerCompleted == true) &&
                !widget.requestItem.oneToManyRequestAttenders
                    .contains(SevaCore.of(context).loggedInUser.email))
            ? Container()
            : oneToManyRequestActionWidgetForParticipant,
      ],
    );
  }

  Widget get getBottombarForCreatorSpeakerCompleted {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: widget.requestItem.isSpeakerCompleted
                      ? S.of(context).request_completed_by_speaker
                      : S.of(context).creator_of_request_message,
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
          child: CustomTextButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(0),
            color: Theme.of(context).accentColor,
            child: Row(
              children: <Widget>[
                SizedBox(width: 1),
                Spacer(),
                Text(
                  S.of(context).reject,
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
            onPressed: () async {
              await oneToManyCreatorRequestCompletionRejected(
                  widget.requestItem, context);

              showDialog(
                  context: context,
                  builder: (BuildContext viewContext) {
                    return AlertDialog(
                      title: Text(S.of(context).reject_request_completion),
                      actions: <Widget>[
                        CustomTextButton(
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            S.of(context).yes,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          onPressed: () async {
                            Navigator.of(viewContext).pop();
                            await oneToManyCreatorRequestCompletionRejectedTimebankNotifications(
                                    widget.requestItem,
                                    context,
                                    SevaCore.of(context).loggedInUser,
                                    false)
                                .then((e) => Navigator.of(context).pop());
                          },
                        ),
                        CustomTextButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            S.of(context).no,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.of(viewContext).pop();
                          },
                        ),
                      ],
                    );
                  });

              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     duration: Duration(seconds: 3),
              //     content: Text(
              //       'Rejection notification has been sent.',
              //     ),
              //   ),
              // );
            },
          ),
        ),
        SizedBox(width: 2),
        Container(
          margin: EdgeInsets.only(right: 5),
          width: 100,
          height: 32,
          child: CustomTextButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(0),
            color: Theme.of(context).primaryColor,
            child: Row(
              children: <Widget>[
                SizedBox(width: 1),
                Spacer(),
                Text(
                  S.of(context).approve,
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
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OneToManyCreatorCompleteRequestPage(
                    requestModel: widget.requestItem,
                    onFinish: () async {},
                  ),
                ),
              ).then((val) => Navigator.of(context).pop());
            },
          ),
        ),
      ],
    );
  }

  Widget get getBottombarForParticipant {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        widget.requestItem.requestType == RequestType.ONE_TO_MANY_REQUEST
            ? Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: isApplied
                            ? S.of(context).accepted_this_request
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
              )
            : widget.requestItem.requestType == RequestType.BORROW &&
                    widget.requestItem.approvedUsers
                        .contains(SevaCore.of(context).loggedInUser.email)
                ? Container(
                    width: 370,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: (widget.requestItem.approvedUsers
                                                  .length >=
                                              1 &&
                                          widget.requestItem.requestType ==
                                              RequestType.BORROW)
                                      ? ((widget.requestItem.sevaUserId ==
                                                  SevaCore.of(context)
                                                      .loggedInUser
                                                      .sevaUserID ||
                                              widget.requestItem.approvedUsers
                                                  .contains(SevaCore.of(context)
                                                      .loggedInUser
                                                      .email))
                                          ? S.of(context).request_approved
                                          : S
                                              .of(context)
                                              .request_has_been_assigned_to_a_member)
                                      : isApplied
                                          ? S.of(context).applied_for_request
                                          : (widget.requestItem.roomOrTool ==
                                                  'PLACE'
                                              ? S
                                                  .of(context)
                                                  .borrow_request_for_place
                                              : S
                                                  .of(context)
                                                  .borrow_request_for_item),
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
                          width: 153,
                          child: CustomTextButton(
                            color: Theme.of(context).primaryColor,
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 1),
                                Spacer(),
                                Text(
                                  widget.requestItem.roomOrTool ==
                                          LendingType.PLACE.readable
                                      ? widget.requestItem.borrowModel
                                              .isCheckedIn
                                          ? S.of(context).check_out_text
                                          : S.of(context).check_in_text
                                      : widget.requestItem.borrowModel
                                              .itemsCollected
                                          ? S.of(context).items_returned
                                          : S.of(context).items_collected,
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
                            onPressed: () async {
                              if (widget.requestItem.roomOrTool ==
                                  LendingType.ITEM.readable) {
                                if (!widget
                                    .requestItem.borrowModel.itemsCollected) {
                                  logger.e('ITEMS GIVEN TO BORROWER');
                                  widget.requestItem.borrowModel
                                      .itemsCollected = true;
                                  await updateRequest(
                                      requestModel: widget.requestItem);
                                  Navigator.pop(context);
                                } else if (widget.requestItem.borrowModel
                                            .itemsCollected ==
                                        true &&
                                    !widget.requestItem.borrowModel
                                        .itemsReturned) {
                                  logger.e(
                                      'ITEMS RECEIVED BACK - COMES TO COMPLETE REQUEST');

                                  showDialog(
                                    context: context,
                                    builder: (_context) => AlertDialog(
                                      title: Text(S
                                          .of(context)
                                          .item_received_alert_dialouge),
                                      actions: [
                                        CustomTextButton(
                                          onPressed: () {
                                            Navigator.of(_context).pop();
                                          },
                                          child: Text(
                                            S.of(context).not_yet,
                                            style: TextStyle(
                                                fontSize: 17,
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                        ),
                                        CustomTextButton(
                                          onPressed: () async {
                                            widget.requestItem.borrowModel
                                                    .itemsReturned =
                                                true; //confirmed items are returned
                                            widget.requestItem.acceptors = [];
                                            widget.requestItem.accepted =
                                                true; //so that we can know that this request has completed
                                            widget.requestItem.isNotified =
                                                true; //resets to false otherwise
                                            var notificationId =
                                                await getNotificationId(
                                              SevaCore.of(context).loggedInUser,
                                              //redundant because function does not use user model
                                              widget.requestItem,
                                            ).then((notificationId) async {
                                              await lenderReceivedBackCheck(
                                                  notificationId:
                                                      notificationId,
                                                  requestModelUpdated:
                                                      widget.requestItem,
                                                  context: context);

                                              await updateRequest(
                                                  requestModel:
                                                      widget.requestItem);

                                              Navigator.of(_context).pop();

                                              Navigator.pop(context);
                                            });
                                          },
                                          child: Text(
                                            S.of(context).yes,
                                            style: TextStyle(fontSize: 17),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return;
                                }
                              } else {
                                if (!widget
                                    .requestItem.borrowModel.isCheckedIn) {
                                  widget.requestItem.borrowModel.isCheckedIn =
                                      true;
                                  await updateRequest(
                                      requestModel: widget.requestItem);
                                  Navigator.pop(context);
                                } else if (widget.requestItem.borrowModel
                                            .isCheckedIn ==
                                        true &&
                                    !widget
                                        .requestItem.borrowModel.isCheckedOut) {
                                  showDialog(
                                    context: context,
                                    builder: (_context) => AlertDialog(
                                      title: Text(S
                                          .of(context)
                                          .item_received_alert_dialouge),
                                      actions: [
                                        CustomTextButton(
                                          onPressed: () {
                                            Navigator.of(_context).pop();
                                          },
                                          child: Text(
                                            S.of(context).not_yet,
                                            style: TextStyle(
                                                fontSize: 17,
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                        ),
                                        CustomTextButton(
                                          onPressed: () async {
                                            widget.requestItem.borrowModel
                                                    .isCheckedOut =
                                                true; //confirmed items are returned
                                            widget.requestItem.acceptors = [];
                                            widget.requestItem.accepted =
                                                true; //so that we can know that this request has completed
                                            widget.requestItem.isNotified =
                                                true; //resets to false otherwise

                                            await getNotificationId(
                                              SevaCore.of(context).loggedInUser,
                                              //redundant because function does not use user model
                                              widget.requestItem,
                                            ).then((notificationId) async {
                                              await lenderReceivedBackCheck(
                                                  notificationId:
                                                      notificationId,
                                                  requestModelUpdated:
                                                      widget.requestItem,
                                                  context: context);

                                              await updateRequest(
                                                  requestModel:
                                                      widget.requestItem);

                                              Navigator.of(_context).pop();

                                              Navigator.pop(context);
                                            });
                                          },
                                          child: Text(
                                            S.of(context).yes,
                                            style: TextStyle(fontSize: 17),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return;
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(width:50),
                      ],
                    ),
                  )
                : Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: widget.requestItem.approvedUsers.contains(
                                        SevaCore.of(context)
                                            .loggedInUser
                                            .email) ||
                                    widget.requestItem.acceptors.contains(
                                        SevaCore.of(context).loggedInUser.email)
                                ? S.of(context).accepted_this_request
                                : widget.requestItem.approvedUsers.length > 0
                                    ? S
                                        .of(context)
                                        .request_has_been_assigned_to_a_member
                                    : S
                                        .of(context)
                                        .particpate_in_request_question,
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
        (widget.requestItem.approvedUsers.length >= 1 &&
                widget.requestItem.requestType == RequestType.BORROW)
            ? Container()
            : timeRequestActionWidgetForParticipant,
      ],
    );
  }

  Widget get oneToManyRequestActionWidgetForParticipant {
    return Container(
      margin: EdgeInsets.only(right: 5),
      width: 100,
      height: 32,
      child: CustomTextButton(
        color: widget.requestItem.oneToManyRequestAttenders
                .contains(SevaCore.of(context).loggedInUser.email)
            ? Theme.of(context).accentColor
            : Colors.green,
        child: Row(
          children: <Widget>[
            SizedBox(width: 1),
            Spacer(),
            Text(
              widget.requestItem.oneToManyRequestAttenders
                      .contains(SevaCore.of(context).loggedInUser.email)
                  ? S.of(context).withdraw
                  : S.of(context).yes,
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
    );
  }

  Widget get timeRequestActionWidgetForParticipant {
    return Container(
      margin: EdgeInsets.only(right: 12),
      width: 100,
      height: 32,
      child: CustomTextButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(0),
        color: Theme.of(context).accentColor,
        child: Row(
          children: <Widget>[
            SizedBox(width: 1),
            Spacer(),
            widget.requestItem.requestType == RequestType.BORROW
                ? Text(
                    isApplied ? S.of(context).cancel : S.of(context).accept,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                : Text(
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
          if (widget.requestItem.requestType == RequestType.BORROW) {
            //widget.requestItem.roomOrTool == 'PLACE'
            //?
            borrowApplyAction();
            //: proccedWithCalander();
          } else {
            applyAction();
          }
        },
      ),
    );
  }

  void applyAction() async {
    var batch = CollectionRef.batch;
    if (widget.requestItem.requestType == RequestType.ONE_TO_MANY_REQUEST) {
      if (widget.requestItem.oneToManyRequestAttenders
          .contains(SevaCore.of(context).loggedInUser.email)) {
        //REMOVING ATTENDEE
        widget.requestItem.participantDetails
            .remove(SevaCore.of(context).loggedInUser.email);

        Set<String> attenders =
            Set.from(widget.requestItem.oneToManyRequestAttenders);
        attenders.remove(SevaCore.of(context).loggedInUser.email);

        widget.requestItem.oneToManyRequestAttenders = attenders.toList();
        batch.delete(
          CollectionRef.requests
              .doc(widget.requestItem.id)
              .collection('oneToManyAttendeesDetails')
              .doc(SevaCore.of(context).loggedInUser.email),
        );

        batch.update(CollectionRef.requests.doc(widget.requestItem.id),
            widget.requestItem.toMap());
        await batch.commit();
        Navigator.pop(context);
      } else {
        //ADDING ATTENDEE
        logger.i('-------------' + 'COMING TO ADD');

        AcceptorModel acceptorModel = AcceptorModel(
          timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
          memberEmail: SevaCore.of(context).loggedInUser.email,
          memberName: SevaCore.of(context).loggedInUser.fullname,
          communityName: widget.timebankModel.name,
          communityId: SevaCore.of(context).loggedInUser.currentCommunity,
          memberPhotoUrl: SevaCore.of(context).loggedInUser.photoURL,
        );
        widget.requestItem
                .participantDetails[SevaCore.of(context).loggedInUser.email] =
            acceptorModel.toMap();

        Set<String> attenders =
            Set.from(widget.requestItem.oneToManyRequestAttenders);
        attenders.add(SevaCore.of(context).loggedInUser.email);

        widget.requestItem.oneToManyRequestAttenders = attenders.toList();
        BasicUserDetails attendeeObject = BasicUserDetails(
          fullname: SevaCore.of(context).loggedInUser.fullname,
          email: SevaCore.of(context).loggedInUser.email,
          photoURL:
              SevaCore.of(context).loggedInUser.photoURL ?? defaultUserImageURL,
          sevaUserID: SevaCore.of(context).loggedInUser.sevaUserID,
        );
        batch.set(
            CollectionRef.requests
                .doc(widget.requestItem.id)
                .collection('oneToManyAttendeesDetails')
                .doc(SevaCore.of(context).loggedInUser.email),
            attendeeObject.toMap());

        batch.update(CollectionRef.requests.doc(widget.requestItem.id),
            widget.requestItem.toMap());
        await batch.commit();

        Navigator.pop(context);
      }
    } else if (isApplied) {
      _withdrawRequest();
    } else {
      if (widget.requestItem.projectId != null &&
          widget.requestItem.projectId.isNotEmpty &&
          widget.requestItem.projectId != 'None') {
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

  void borrowApplyAction() async {
    if (widget.requestItem.acceptors
        .contains(SevaCore.of(context).loggedInUser.email)) {
      _withdrawRequest();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AcceptBorrowRequest(
            requestModel: widget.requestItem,
            timeBankId: widget.requestItem.timebankId,
            userId: SevaCore.of(context).loggedInUser.sevaUserID,
            parentContext: context,
            onTap: () async {
              log('Came out of accept borrow request');

              proccedWithCalander();

              // await updateAcceptBorrowRequest(
              //   requestModel: widget.requestItem,
              //   //participantDetails: participantDetails,
              //   userEmail: SevaCore.of(context).loggedInUser.email,
              // );
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    }
  }

  void proccedWithCalander() async {
    await _acceptRequest();

    KloudlessWidgetManager<ApplyMode, RequestModel>().syncCalendar(
      context: context,
      builder: KloudlessWidgetBuilder().fromContext<ApplyMode, RequestModel>(
        context: context,
        model: widget.requestItem,
        id: widget.requestItem.id,
      ),
    );
    Navigator.pop(context);
  }

  void _acceptRequest() async {
    CommunityModel communityModel;
    await CollectionRef.communities
        .doc(widget.timebankModel.communityId)
        .get()
        .then((value) {
      communityModel = CommunityModel(value.data());
      setState(() {});
    });
    Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
    acceptorList.add(SevaCore.of(context).loggedInUser.email);

    widget.requestItem.acceptors = acceptorList.toList();
    AcceptorModel acceptorModel = AcceptorModel(
      sevauserid: SevaCore.of(context).loggedInUser.sevaUserID,
      memberPhotoUrl: SevaCore.of(context).loggedInUser.photoURL,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      communityName: widget.timebankModel.name,
      //communityModel.name,
      memberName: SevaCore.of(context).loggedInUser.fullname,
      memberEmail: SevaCore.of(context).loggedInUser.email,
      timebankId: widget.timebankModel.id,
    );
    widget.requestItem
            .participantDetails[SevaCore.of(context).loggedInUser.email] =
        acceptorModel.toMap();

    acceptRequest(
      loggedInUser: SevaCore.of(context).loggedInUser,
      requestModel: widget.requestItem,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      communityId: widget.requestItem.communityId,
      directToMember: !widget.timebankModel.protected,
      acceptorModel: acceptorModel,
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
      widget.requestItem.participantDetails
          .remove(SevaCore.of(context).loggedInUser.email);

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
        communityId: widget.requestItem.communityId,
        directToMember: !widget.timebankModel.protected,
      );

      if (widget.requestItem.requestType == RequestType.BORROW) {
        removeAcceptorDataBorrowRequest(
            acceptorEmail: SevaCore.of(context).loggedInUser.email,
            requestModel: widget.requestItem);
      }

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

  Widget get requestedByBorrowRequestComponent {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          S.of(context).requested_by,
          style: titleStyle,
          maxLines: 1,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                widget.requestItem.photoUrl ?? defaultUserImageURL,
              ),
              backgroundColor: Colors.white,
              radius: MediaQuery.of(context).size.width / 12,
            ),
            SizedBox(width: 25),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.requestItem.fullName,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
                  ),
                  SizedBox(height: 7),
                  createdAt,
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
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
        overflow: TextOverflow.ellipsis,
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

  Widget get subtitleComponentBorrowRequest {
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
      style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
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

  Widget get timestampComponentBorrowRequest {
    return CustomListTile(
      leading: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Card(
            color: Colors.transparent,
            elevation: 3,
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 15,
                  decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(7),
                          topRight: Radius.circular(7))),
                ),
                Container(
                  width: 58,
                  height: 38,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(7),
                          bottomRight: Radius.circular(7))),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              DateFormat('dd', Locale(getLangTag()).toLanguageTag()).format(
                getDateTimeAccToUserTimezone(
                    dateTime: DateTime.fromMillisecondsSinceEpoch(
                        widget.requestItem.requestStart),
                    timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
              ),
              style: TextStyle(fontSize: 24, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 8),
        child: date,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: subtitleComponentBorrowRequest,
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(left: 5, top: 18),
        child: trailingComponent,
      ),
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

  Widget get addressComponentBorrowRequest {
    String locationSubitleFinal = '';
    String locationTitle = '';

    if (widget.requestItem.address != null) {
      List locationTitleList = widget.requestItem.address.split(',');
      locationTitle = locationTitleList[0];

      List locationSubitleList = widget.requestItem.address.split(',');
      locationSubitleList.removeAt(0);

      locationSubitleFinal = locationSubitleList
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '');

      return widget.requestItem.address != null
          ? CustomListTile(
              leading: Icon(
                Icons.location_on,
                color: Colors.black,
              ),
              title: Text(
                widget.requestItem.address.trim() != null ? locationTitle : '',
                style: titleStyle,
                maxLines: 1,
              ),
              subtitle: widget.requestItem.address != null
                  ? Text(locationSubitleFinal.trim(),
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w600))
                  : Text(''),
            )
          : Container();
    } else {
      return Text(S.of(context).location_not_provided,
          style: TextStyle(color: Colors.grey));
    }
  }

  Widget get trailingComponent {
    if (widget.requestItem.requestType == RequestType.CASH &&
        widget.requestItem.cashModel.amountRaised != 0) {
      return Container();
    }
    return Container(
      height: 39,
      width: 90,
      child: widget.requestItem.sevaUserId ==
                  SevaCore.of(context).loggedInUser.sevaUserID &&
              widget.requestItem.accepted == false
          ? CustomTextButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Color.fromRGBO(44, 64, 140, 1),
              child: Text(
                S.of(context).edit,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditRequest(
                      timebankId: widget.requestItem.timebankId,
                      requestModel: widget.requestItem,
                    ),
                  ),
                ).then((value) => Navigator.pop(context));
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

      case RequestType.BORROW:
        return descriptionForBorrowRequest;

      case RequestType.ONE_TO_MANY_REQUEST:
        return detailsForOneToManyRequest;

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

  Widget get descriptionForBorrowRequest {
    return Text(widget.requestItem.description,
        style: TextStyle(fontSize: 16, color: Colors.grey));
  }

  Widget get detailsForOneToManyRequest {
    return Text(
      widget.requestItem.description,
      style: TextStyle(fontSize: 16),
    );
  }

  Widget get approvedBorrowRequestViewAgreementComponent {
    return FutureBuilder<BorrowAcceptorModel>(
        future: FirestoreManager.getBorrowRequestAcceptorModel(
            requestId: widget.requestItem.id,
            acceptorEmail: widget.requestItem.approvedUsers[0]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (snapshot.data == null) {
            return Center(
              child: Text(S.of(context).request_agreement_not_available),
            );
          }
          BorrowAcceptorModel borrowAcceptorModel = snapshot.data;
          return Container(
            height: widget.requestItem.roomOrTool == LendingType.ITEM.readable
                ? 320
                : 610, //to be fixed (give dynamic height)
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.requestItem.email ==
                        SevaCore.of(context).loggedInUser.email
                    ? Container()
                    : Expanded(
                        child: Text(
                          (widget.requestItem.roomOrTool ==
                                      LendingType.ITEM.readable
                                  ? S.of(context).offering_items_to
                                  : S.of(context).offering_place_to) +
                              borrowAcceptorModel.acceptorName,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                Text(
                  (widget.requestItem.roomOrTool == LendingType.ITEM.readable
                          ? S.of(context).collect_and_return_items
                          : S.of(context).length_of_stay) +
                      DateFormat('dd MMM,\nhh:mm a',
                              Locale(getLangTag()).toLanguageTag())
                          .format(
                        getDateTimeAccToUserTimezone(
                            dateTime: DateTime.fromMillisecondsSinceEpoch(
                                widget.requestItem.requestStart),
                            timezoneAbb:
                                SevaCore.of(context).loggedInUser.timezone),
                      ) +
                      ' to ' +
                      DateFormat('dd MMM,\nhh:mm a',
                              Locale(getLangTag()).toLanguageTag())
                          .format(
                        getDateTimeAccToUserTimezone(
                            dateTime: DateTime.fromMillisecondsSinceEpoch(
                                widget.requestItem.requestEnd),
                            timezoneAbb:
                                SevaCore.of(context).loggedInUser.timezone),
                      ),
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 10,
                ),
                widget.requestItem.roomOrTool == LendingType.ITEM.readable
                    ? FutureBuilder<List<LendingModel>>(
                        future: LendingOffersRepo.getApprovedLendingModels(
                            lendingModelsIds:
                                borrowAcceptorModel.borrowedItemsIds),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return LoadingIndicator();
                          }
                          if (snapshot.data == null) {
                            return Container();
                          }
                          List<LendingModel> modelList = snapshot.data;
                          return ListView.builder(
                              itemCount: modelList.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: LendingItemCardWidget(
                                    hidden: true,
                                    lendingItemModel:
                                        modelList[index].lendingItemModel,
                                  ),
                                );
                              });
                        })
                    : FutureBuilder<LendingModel>(
                        future: LendingOffersRepo.getLendingModel(
                            lendingId: borrowAcceptorModel.borrowedPlaceId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return LoadingIndicator();
                          }
                          if (snapshot.data == null) {
                            return Container();
                          }
                          LendingModel model = snapshot.data;
                          return Container(
                            width: 400,
                            // height: 450,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LendingPlaceDetailsWidget(
                                  lendingModel: model,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                model.lendingPlaceModel.contactInformation !=
                                        null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            S.of(context).contact_information,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            model.lendingPlaceModel
                                                    .contactInformation ??
                                                '',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      )
                                    : Container(),
                              ],
                            ),
                          );
                        }),
                GestureDetector(
                  child: Text(
                      borrowAcceptorModel.borrowAgreementLink == null ||
                              borrowAcceptorModel.borrowAgreementLink == ''
                          ? S.of(context).request_agreement_not_available
                          : S.of(context).click_to_view_request_agreement,
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600)),
                  onTap: () async {
                    if (borrowAcceptorModel.borrowAgreementLink == null ||
                        borrowAcceptorModel.borrowAgreementLink == '') {
                      return null;
                    } else {
                      await openPdfViewer(
                          borrowAcceptorModel.borrowAgreementLink,
                          'Request Agreement Document',
                          context);
                    }
                  },
                ),
                addressComponentBorrowRequestForApproved(
                    borrowAcceptorModel.selectedAddress ?? '', context),
              ],
            ),
          );
        });
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
          "${S.of(context).account_no} : " +
              widget.requestItem.cashModel.achdetails.account_number,
        ),
        Text(
          "${S.of(context).bank_address} : " +
              widget.requestItem.cashModel.achdetails.bank_address,
        ),
        Text(
          "${S.of(context).bank_name} : " +
              widget.requestItem.cashModel.achdetails.bank_name,
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
            S.of(context).donation_address,
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
//                child: CustomTextButton(
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

  void deleteRequestDialog(RequestModel requestItem) {
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
            CustomTextButton(
              shape: StadiumBorder(),
              color: utils.HexColor("#d2d2d2"),
              textColor: Colors.white,
              onPressed: () => {Navigator.of(dialogContext).pop()},
              child: Text(
                S.of(context).cancel,
                style: TextStyle(fontSize: dialogButtonSize),
              ),
            ),
            CustomTextButton(
              shape: StadiumBorder(),
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              onPressed: () async {
                if (requestItem.parent_request_id == requestItem.id) {
                  LinearProgressIndicator();
                  await fetchRecurringRequestsDocs(requestItem);
                  deleteParentRequest(requestItem).commit();
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
                } else {
                  try {
                    await deleteRequest();
                  } on Exception catch (e) {
                    logger.i("Exception caught");
                  }
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
                }
                ;
              },
              child: Text(
                S.of(context).delete,
                style: TextStyle(fontSize: dialogButtonSize),
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

  Future fetchRecurringRequestsDocs(RequestModel requestItem) async {
    recurringRequestsDocs = await CollectionRef.requests
        .where('parent_request_id', isEqualTo: requestItem.parent_request_id)
        //.where('autoGenerated', isEqualTo: true)
        .get();
  }

  WriteBatch deleteParentRequest(RequestModel requestItem) {
    WriteBatch batch = CollectionRef.batch;
    var docs = recurringRequestsDocs.docs;

//below if condition for, if only one request is remaining in the recurring request list.
//To avoid index error.
    if (docs.length <= 1) {
      var delete1 = CollectionRef.requests.doc(requestItem.id);
      batch.delete(delete1);
    } else if (docs.length > 1) {
      Map<String, dynamic> subsequentDocMap = docs[1].data;
      String subsequentDocID = docs[1].id;

      var update1 = CollectionRef.requests.doc(requestItem.parent_request_id);

      var update2 = CollectionRef.requests.doc(requestItem.parent_request_id);

      var delete2 = CollectionRef.requests.doc(subsequentDocID);

      batch.update(update1, subsequentDocMap);
      batch.update(update2, {
        'id': requestItem.parent_request_id,
        'isRecurring': true,
        'autoGenerated': false,
      });
      batch.delete(delete2);
    }
    return batch;
  }

  Future<void> deleteRequest() async {
    await CollectionRef.requests.doc(widget.requestItem.id).delete();

    if (widget.requestItem.projectId != null &&
        widget.requestItem.projectId.isNotEmpty) {
      try {
        CollectionRef.projects.doc(widget.requestItem.projectId).update({
          'pendingRequests': FieldValue.arrayRemove([widget.requestItem.id])
        });
      } on Exception catch (e) {
        logger.e("Couldn't update the pending task for associated event.");
      }
    }
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
                        transaction_matrix_type: "calender_sync",
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
                        transaction_matrix_type: "calender_sync",
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
                        transaction_matrix_type: "calender_sync",
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
                    CustomTextButton(
                        shape: StadiumBorder(),
                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        color: FlavorConfig.values.theme.primaryColor,
                        child: Text(
                          S.of(context).skip_for_now,
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Europa'),
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
              CustomTextButton(
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
          subtitle: Text(
              '${widget.requestItem.cashModel.requestCurrencyType} ${widget.requestItem.cashModel.amountRaised.toStringAsFixed(2)}'),
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
                  "${(currentPercentage * 100).toStringAsFixed(2)}%",
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

  Widget get borrowItemsWidget {
    return Wrap(
      runSpacing: 5.0,
      spacing: 5.0,
      children: widget.requestItem.borrowModel.requiredItems.values
          .toList()
          .map(
            (value) => value == null
                ? Container()
                : CustomChipWithTick(
                    label: value,
                    isSelected: true,
                  ),
          )
          .toList(),
    );
  }

  Widget borrowRequestItemPlaceTag(String requestType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Chip(
          label: Text(
            requestType == LendingType.ITEM.readable
                ? S.of(context).borrow_request_title + ' ' + S.of(context).items
                : S.of(context).borrow_request_title +
                    ' ' +
                    S.of(context).place_text,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.grey[200],
        ),
      ],
    );
  }
}
