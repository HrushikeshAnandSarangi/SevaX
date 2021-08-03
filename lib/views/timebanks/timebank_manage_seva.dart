import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/invoice/pages/months_list.dart';
import 'package:sevaexchange/ui/screens/members/pages/member_permissions.dart';
import 'package:sevaexchange/ui/screens/reported_members/pages/reported_member_page.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_listing_page.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/views/community/communitycreate.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/notification_switch.dart';

class ManageTimebankSeva extends StatefulWidget {
  final TimebankModel timebankModel;

  ManageTimebankSeva.of({this.timebankModel});
  @override
  State<StatefulWidget> createState() {
    return _ManageTimebankSeva();
  }
}

class _ManageTimebankSeva extends State<ManageTimebankSeva> {
  String planId = "";
  CommunityModel communityModel = CommunityModel({});
  bool isSuperAdmin = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration.zero, () {
      FirestoreManager.getCommunityDetailsByCommunityId(
              communityId: widget.timebankModel.communityId)
          .then((onValue) {
        communityModel = onValue;
        if (SevaCore.of(context).loggedInUser.sevaUserID ==
                communityModel.created_by ||
            widget.timebankModel.organizers
                .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
          isSuperAdmin = true;
        }
        setState(() {});
      });
    });
    Future.delayed(Duration.zero, () {
      FirestoreManager.getplanForCurrentCommunity(
              widget.timebankModel.communityId)
          .then((onvalue) {
        planId = onvalue;
      });
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // if (isSuperAdmin) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: <Widget>[
          TabBar(
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            isScrollable: true,
            tabs: <Widget>[
              Tab(text: S.of(context).edit_timebank),
              // Tab(text: "Upgrade"),
              // Tab(text: S.of(context).billing),
              Tab(
                text: S.of(context).settings,
              ),
              Tab(
                text: S.of(context).bottom_nav_notifications,
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                CreateEditCommunityView(
                  isCreateTimebank: false,
                  isFromFind: false,
                  timebankId: widget.timebankModel.id,
                ),
                // TimeBankBillingAdminView(),
                Settings,
                NotificationManagerForAmins(
                  widget.timebankModel.id,
                  SevaCore.of(context).loggedInUser.sevaUserID,
                  widget.timebankModel.parentTimebankId ==
                      FlavorConfig.values.timebankId,
                )
              ],
            ),
          ),
        ],
      ),
    );
//     } else {
//       return DefaultTabController(
//         length: 3,
//         child: Column(
//           children: <Widget>[
//             TabBar(
//               indicatorColor: Colors.black,
//               labelColor: Colors.black,
//               isScrollable: false,
//               tabs: <Widget>[
//                 Tab(text: S.of(context).edit_timebank),
//                 Tab(
//                   text: S.of(context).settings,
//                 ),
//                 Tab(
//                   text: S.of(context).bottom_nav_notifications,
//                 ),
//               ],
// //                onTap: (index) {
// //                  if (_indextab != index) {
// //                    _indextab = index;
// //                    setState(() {});
// //                  }
// //                },
//             ),
//             Expanded(
//               child: TabBarView(
//                 children: [
//                   CreateEditCommunityView(
//                     isCreateTimebank: false,
//                     isFromFind: false,
//                     timebankId: widget.timebankModel.id,
//                   ),
//                   Settings,
//                   NotificationManagerForAmins(
//                     widget.timebankModel.id,
//                     SevaCore.of(context).loggedInUser.sevaUserID,
//                     widget.timebankModel.parentTimebankId ==
//                         FlavorConfig.values.timebankId,
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
  }

//  Widget get normalAdminWidget {
//    return IndexedStack(
//      index: _indextab,
//      children: <Widget>[
//        CreateEditCommunityView(
//          isCreateTimebank: false,
//          isFromFind: false,
//          timebankId: widget.timebankModel.id,
//        ),
//        Settings,
//      ],
//    );
//  }

//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      backgroundColor: Colors.white,
//      body: Container(
//        margin: EdgeInsets.all(10),
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.start,
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            getTitle,
//            // SizedBox(
//            //   height: 30,
//            // ),
//            // viewRequests(context: context),
//            viewAcceptedOffers(context: context),
//
//            manageTimebankCodes(context: context),
//            vieweditPage(context: context),
//            viewBillingPage(context: context),
//            billingView(context: context),
//          ],
//        ),
//      ),
//    );
//  }
//

  Widget get deleteTimebank {
    return GestureDetector(
      onTap: () {
        showAdvisoryBeforeDeletion(
          context: context,
          associatedId: widget.timebankModel.id,
          softDeleteType: SoftDelete.REQUEST_DELETE_TIMEBANK,
          associatedContentTitle: widget.timebankModel.name,
          email: SevaCore.of(context).loggedInUser.email,
          isAccedentalDeleteEnabled:
              widget.timebankModel.preventAccedentalDelete,
        );
      },
      child: Text(
        S.of(context).delete_timebank,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  // Widget get changeOwnerShip {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => ChangeOwnerShipView(
  //             timebankId: widget.timebankModel.id,
  //           ),
  //         ),
  //       );
  //     },
  //     child: Text(
  //       S.of(context).change_ownership,
  //       textAlign: TextAlign.left,
  //       style: TextStyle(
  //         fontWeight: FontWeight.bold,
  //         color: Colors.blue,
  //       ),
  //     ),
  //   );
  // }

  Widget viewRequests({BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestListingPage(
              // timebankId: widget.timebankModel.id,
              timebankModel: widget.timebankModel,
              isFromSettings: true,
            ),
          ),
        );
      },
      child: Text(
        S.of(context).view_requests,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget viewReportedMembers({BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          ReportedMembersPage.route(
            timebankModel: widget.timebankModel,
            communityId: widget.timebankModel.communityId,
            isFromTimebank: true,
          ),
        );
      },
      child: Text(
        S.of(context).reported_members,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget viewMemberConfigurations({BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MemberPermissions(
            timebankModel: widget.timebankModel,
          ),
        ));
      },
      child: Text(
       S.of(context).manage_permissions,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget viewInvoice({BuildContext context}) {
    if (Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS) {
      return Container();
    }
    return TransactionsMatrixCheck(
      comingFrom: ComingFrom.Home,
      upgradeDetails: AppConfig.upgradePlanBannerModel.invoice_generation,
      transaction_matrix_type: "invoice_generation",
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MonthsListing.of(
                  communityId:
                      SevaCore.of(context).loggedInUser.currentCommunity,
                  planId: planId,
                  communityModel: communityModel),
            ),
          );
        },
        child: Column(
          children: [
            Text(
              "${S.of(context).invoice_and_reports}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget get getTitle {
    return Text(
      "${S.of(context).manage} ${widget.timebankModel.name}",
      style: TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget get Settings {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getTitle,
          SizedBox(height: 20),
          // viewRequests(context: context),
          // SizedBox(height: 20),
          // widget.timebankModel.creatorId ==
          //         SevaCore.of(context).loggedInUser.sevaUserID
          //     ? Padding(
          //         padding: const EdgeInsets.only(bottom: 20),
          //         child: changeOwnerShip,
          //       )
          //     : Container(),
          viewInvoice(context: context),
          viewReportedMembers(context: context),
          SizedBox(height: 20),

          widget.timebankModel.creatorId ==
                  SevaCore.of(context).loggedInUser.sevaUserID
              ? TransactionsMatrixCheck(
                  comingFrom: ComingFrom.Settings,
                  upgradeDetails:
                      AppConfig.upgradePlanBannerModel.admin_role_customization,
                  transaction_matrix_type: 'admin_role_customization',
                  child: viewMemberConfigurations(context: context))
              : Container(),

          SizedBox(height: 20),
          widget.timebankModel.creatorId ==
                  SevaCore.of(context).loggedInUser.sevaUserID
              ? deleteTimebank
              : Container(),
        ],
      ),
    );
  }
}

class NotificationSetting {
  bool joinRequest = true;
  bool acceptedRequest = true;
  bool requestCompleted = true;
  bool creditNotificationForOffer = true;
  bool debitNotificationForOffer = true;
  bool softDeleteRequest = true;
  bool memberExit = true;

  Map<String, bool> toMap() {
    Map<String, bool> object = HashMap();
    object['JoinRequest'] = joinRequest;
    object['RequestAccept'] = acceptedRequest;
    object['RequestCompleted'] = requestCompleted;
    object['TYPE_CREDIT_NOTIFICATION_FROM_TIMEBANK'] =
        creditNotificationForOffer;
    object['TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK'] = debitNotificationForOffer;
    object['TYPE_DELETION_REQUEST_OUTPUT'] = softDeleteRequest;
    object['TypeMemberExit'] = memberExit;

    return object;
  }

  NotificationSetting() {}

  NotificationSetting.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('JoinRequest')) {
      joinRequest = map['JoinRequest'];
    }

    if (map.containsKey('RequestAccept')) {
      acceptedRequest = map['RequestAccept'];
    }

    if (map.containsKey('RequestCompleted')) {
      requestCompleted = map['RequestCompleted'];
    }

    if (map.containsKey('TYPE_CREDIT_NOTIFICATION_FROM_TIMEBANK')) {
      creditNotificationForOffer =
          map['TYPE_CREDIT_NOTIFICATION_FROM_TIMEBANK'];
    }

    if (map.containsKey('TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK')) {
      debitNotificationForOffer = map['TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK'];
    }

    if (map.containsKey('TYPE_DELETION_REQUEST_OUTPUT')) {
      softDeleteRequest = map['TYPE_DELETION_REQUEST_OUTPUT'];
    }

    if (map.containsKey('TypeMemberExit')) {
      memberExit = map['TypeMemberExit'];
    }
  }
}

class NotificationManagerForAmins extends StatefulWidget {
  final String timebankId;
  final String adminSevaUserId;
  final bool isPrimaryTimebank;

  NotificationManagerForAmins(
    this.timebankId,
    this.adminSevaUserId,
    this.isPrimaryTimebank,
  );

  @override
  State<StatefulWidget> createState() {
    return _NotificationManagerForAminsState();
  }
}

class _NotificationManagerForAminsState
    extends State<NotificationManagerForAmins> {
  Stream settingsStreamer;
  @override
  void initState() {
    super.initState();
    settingsStreamer = FirestoreManager.getTimebankModelStream(
      timebankId: widget.timebankId,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<TimebankModel>(
            stream: settingsStreamer,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              NotificationSetting notificationSetting = snapshot
                      .data.notificationSetting
                      .containsKey(widget.adminSevaUserId)
                  ? snapshot.data.notificationSetting[widget.adminSevaUserId]
                  : NotificationSetting();

              return SingleChildScrollView(
                child: Column(
                  children: [
                    lineDivider,
                    NotificationWidgetSwitch(
                      isTurnedOn: notificationSetting.acceptedRequest,
                      title: S.of(context).request_accepted,
                      onPressed: (bool status) {
                        NotificationWidgetSwitch.updateNotificationFormAdmin(
                          adminSevaUserId: widget.adminSevaUserId,
                          notificationType: 'RequestAccept',
                          status: status,
                          timebankId: widget.timebankId,
                        );
                      },
                    ),
                    lineDivider,
                    NotificationWidgetSwitch(
                      isTurnedOn: notificationSetting.requestCompleted,
                      title: S.of(context).request_completed,
                      onPressed: (bool status) {
                        NotificationWidgetSwitch.updateNotificationFormAdmin(
                          adminSevaUserId: widget.adminSevaUserId,
                          notificationType: 'RequestCompleted',
                          status: status,
                          timebankId: widget.timebankId,
                        );
                      },
                    ),
                    lineDivider,
                    NotificationWidgetSwitch(
                      isTurnedOn: notificationSetting.joinRequest,
                      title: S.of(context).join_request_message +
                          ' ' +
                          '${widget.isPrimaryTimebank ? S.of(context).timebank : S.of(context).group}',
                      onPressed: (bool status) {
                        NotificationWidgetSwitch.updateNotificationFormAdmin(
                          adminSevaUserId: widget.adminSevaUserId,
                          notificationType: 'JoinRequest',
                          status: status,
                          timebankId: widget.timebankId,
                        );
                      },
                    ),
                    lineDivider,
                    NotificationWidgetSwitch(
                      isTurnedOn: notificationSetting.debitNotificationForOffer,
                      title: S.of(context).offer_debit,
                      onPressed: (bool status) {
                        NotificationWidgetSwitch.updateNotificationFormAdmin(
                          adminSevaUserId: widget.adminSevaUserId,
                          notificationType:
                              'TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK',
                          status: status,
                          timebankId: widget.timebankId,
                        );
                      },
                    ),
                    lineDivider,
                    NotificationWidgetSwitch(
                      isTurnedOn: notificationSetting.memberExit,
                      title: S.of(context).member_exits +
                          ' ' +
                          '${widget.isPrimaryTimebank ? S.of(context).timebank : S.of(context).group}',
                      onPressed: (bool status) {
                        NotificationWidgetSwitch.updateNotificationFormAdmin(
                          adminSevaUserId: widget.adminSevaUserId,
                          notificationType: 'TypeMemberExit',
                          status: status,
                          timebankId: widget.timebankId,
                        );
                      },
                    ),
                    lineDivider,
                    NotificationWidgetSwitch(
                      isTurnedOn: notificationSetting.softDeleteRequest,
                      title: S.of(context).deletion_request_message,
                      onPressed: (bool status) {
                        NotificationWidgetSwitch.updateNotificationFormAdmin(
                          adminSevaUserId: widget.adminSevaUserId,
                          notificationType: 'TYPE_DELETION_REQUEST_OUTPUT',
                          status: status,
                          timebankId: widget.timebankId,
                        );
                      },
                    ),
                    lineDivider,
                    NotificationWidgetSwitch(
                      isTurnedOn:
                          notificationSetting.creditNotificationForOffer,
                      title: S.of(context).recieved_credits_one_to_many,
                      onPressed: (bool status) {
                        NotificationWidgetSwitch.updateNotificationFormAdmin(
                          adminSevaUserId: widget.adminSevaUserId,
                          notificationType:
                              'TYPE_CREDIT_NOTIFICATION_FROM_TIMEBANK',
                          status: status,
                          timebankId: widget.timebankId,
                        );
                      },
                    ),
                    lineDivider
                  ],
                ),
              );
            }));
  }

  Widget get lineDivider {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15),
      height: 1,
      color: Color.fromARGB(100, 233, 233, 233),
    );
  }
}
