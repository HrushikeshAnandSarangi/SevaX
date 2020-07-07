import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/pages/reported_member_page.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/views/community/communitycreate.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/manage/timebank_billing_admin_view.dart';
import 'package:sevaexchange/views/timebank_modules/timebank_requests.dart';
import 'package:sevaexchange/views/timebanks/change_ownership_view.dart';
import 'package:sevaexchange/widgets/notification_switch.dart';

class ManageTimebankSeva extends StatefulWidget {
  final TimebankModel timebankModel;

  ManageTimebankSeva.of({this.timebankModel});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ManageTimebankSeva();
  }
}

class _ManageTimebankSeva extends State<ManageTimebankSeva> {
  var _indextab = 0;

  CommunityModel communityModel = CommunityModel({});
  bool isSuperAdmin = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("creator id ${widget.timebankModel.communityId}");
    Future.delayed(Duration.zero, () {
      FirestoreManager.getCommunityDetailsByCommunityId(
              communityId: widget.timebankModel.communityId)
          .then((onValue) {
        communityModel = onValue;
        if (SevaCore.of(context).loggedInUser.sevaUserID ==
            communityModel.created_by) {
          isSuperAdmin = true;
          setState(() {});
        }
        print("creator id -----> ${communityModel.created_by}");
      });
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ///  print("seva id ${SevaCore.of(context).loggedInUser.sevaUserID}");

    if (isSuperAdmin) {
      return DefaultTabController(
        length: 4,
        child: Column(
          children: <Widget>[
            TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              isScrollable: true,
              tabs: <Widget>[
                Tab(
                    text: AppLocalizations.of(context)
                        .translate('manage', 'edit_timebank')),
                // Tab(text: "Upgrade"),
                Tab(
                    text: AppLocalizations.of(context)
                        .translate('manage', 'billing')),
                Tab(
                  text: AppLocalizations.of(context)
                      .translate('manage', 'settings'),
                ),
                Tab(
                  text: AppLocalizations.of(context).translate(
                      'external_notifications', 'notification_title'),
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
                  TimeBankBillingAdminView(),
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
    } else {
      return DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              isScrollable: false,
              tabs: <Widget>[
                Tab(
                    text: AppLocalizations.of(context)
                        .translate('manage', 'edit_timebank')),
                Tab(
                  text: AppLocalizations.of(context)
                      .translate('manage', 'settings'),
                ),
                Tab(
                  text: AppLocalizations.of(context).translate(
                      'external_notifications', 'notification_title'),
                ),
              ],
//                onTap: (index) {
//                  if (_indextab != index) {
//                    _indextab = index;
//                    setState(() {});
//                  }
//                },
            ),
            Expanded(
              child: TabBarView(
                children: [
                  CreateEditCommunityView(
                    isCreateTimebank: false,
                    isFromFind: false,
                    timebankId: widget.timebankModel.id,
                  ),
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
    }
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
        AppLocalizations.of(context).translate('manage', 'delete_timebank'),
        textAlign: TextAlign.left,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget get changeOwnerShip {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeOwnerShipView(
              timebankId: widget.timebankModel.id,
            ),
          ),
        );
      },
      child: Text(
        AppLocalizations.of(context)
            .translate('change_ownership', 'change_ownership_title'),
        textAlign: TextAlign.left,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget viewRequests({BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestsModule.of(
              timebankId: widget.timebankModel.id,
              timebankModel: widget.timebankModel,
              isFromSettings: true,
            ),
          ),
        );
      },
      child: Text(
        AppLocalizations.of(context).translate('manage', 'view_requests'),
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
        AppLocalizations.of(context)
            .translate('reported_members', 'reported_members'),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

//  Widget viewAcceptedOffers({BuildContext context}) {
//    return GestureDetector(
//      onTap: () {
//        Navigator.push(
//          context,
//          MaterialPageRoute(
//            builder: (context) => AcceptedOffers(
//              timebankId: widget.timebankModel.id,
//            ),
//          ),
//        );
//      },
//      child: Container(
//        margin: EdgeInsets.only(top: 20),
//        child: Text(
//          'View accepted offers',
//          style: TextStyle(
//            fontSize: 14,
//            fontWeight: FontWeight.bold,
//            color: Colors.blue,
//          ),
//        ),
//      ),
//    );
//  }
//
//  Widget vieweditPage({BuildContext context}) {
//    return GestureDetector(
//      onTap: () {
//        Navigator.of(context).push(
//          MaterialPageRoute(
//            builder: (context) => CreateEditCommunityView(
//              timebankId: widget.timebankModel.id,
//              isFromFind: false,
//              isCreateTimebank: false,
//            ),
//          ),
//        );
//      },
//      child: Container(
//        margin: EdgeInsets.only(top: 20),
//        child: Text(
//          'About',
//          style: TextStyle(
//            fontSize: 14,
//            fontWeight: FontWeight.bold,
//            color: Colors.blue,
//          ),
//        ),
//      ),
//    );
//  }

//  Widget billingView({BuildContext context}) {
//    return GestureDetector(
//      onTap: () {
//        Navigator.push(
//          context,
//          MaterialPageRoute(
//            builder: (context) => BillingView(
//              widget.timebankModel.id,
//              '',
//              user: SevaCore.of(context).loggedInUser,
//            ),
//          ),
//        );
//      },
//      child: Container(
//        margin: EdgeInsets.only(top: 20),
//        child: Text(
//          'Billing',
//          style: TextStyle(
//            fontSize: 14,
//            fontWeight: FontWeight.bold,
//            color: Colors.blue,
//          ),
//        ),
//      ),
//    );
//  }

  Widget get getTitle {
    return Text(
      "${AppLocalizations.of(context).translate('manage', 'manage')} ${widget.timebankModel.name}",
      style: TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w700,
      ),
    );
  }

//  viewBillingPage({BuildContext context}) {
//    return GestureDetector(
//      onTap: () {
//        Navigator.of(context).push(
//          MaterialPageRoute(
//            builder: (context) => TimeBankBillingAdminView(),
//          ),
//        );
//      },
//      child: Container(
//        margin: EdgeInsets.only(top: 20),
//        child: Text(
//          'Admin Billing',
//          style: TextStyle(
//            fontSize: 14,
//            fontWeight: FontWeight.bold,
//            color: Colors.blue,
//          ),
//        ),
//      ),
//    );
//  }

//  Widget get bodyWidget {
//    return IndexedStack(
//      index: _indextab,
//      children: <Widget>[
//        CreateEditCommunityView(
//          isCreateTimebank: false,
//          isFromFind: false,
//          timebankId: widget.timebankModel.id,
//        ),
//        // SingleChildScrollView(
//        //   child: Column(
//        //     crossAxisAlignment: CrossAxisAlignment.center,
//        //     children: <Widget>[
//        //       Padding(
//        //         padding: EdgeInsets.all(40),
//        //         child: Image.asset(
//        //           'lib/assets/images/startup.png',
//        //           height: 150,
//        //         ),
//        //       ),
//        //       getTile(
//        //         address: 'lib/assets/images/drawing-tablet.svg',
//        //         title: 'Unlimited groups',
//        //         subtitle: 'No limit on groups your team can create',
//        //       ),
//        //       getTile(
//        //         address: 'lib/assets/images/add-user.svg',
//        //         title: 'Unlimited users',
//        //         subtitle: 'No limit on users for your timebank',
//        //       ),
//        //       getTile(
//        //         address: 'lib/assets/images/bars.svg',
//        //         title: 'Pay as you go',
//        //         subtitle: 'Pay as per total members in your team',
//        //       ),
//        //       getTile(
//        //         address: 'lib/assets/images/megaphone.svg',
//        //         title: 'Absolute control on public post',
//        //         subtitle: 'Control on data your team public posts',
//        //       ),
//        //       getTile(
//        //         address: 'lib/assets/images/lightbulb.svg',
//        //         title: 'Organize your spendings',
//        //         subtitle: 'Have a holistic view on your spending',
//        //       ),
//        //       getTile(
//        //         address: 'lib/assets/images/levels.svg',
//        //         title: 'Settings',
//        //         subtitle: 'Manage your child timebanks',
//        //       ),
//        //       getTile(
//        //         address: 'lib/assets/images/color-palette.svg',
//        //         title: 'Themes',
//        //         subtitle: 'Customize your own look',
//        //       ),
//        //       Padding(
//        //         padding: EdgeInsets.only(top: 50, bottom: 50),
//        //         child: Column(
//        //           children: <Widget>[
//        //             Text(
//        //               '5\$ \/ user \/ month',
//        //             ),
//        //             RaisedButton(
//        //               color: Colors.red,
//        //               child: Text(
//        //                 'Upgrade',
//        //                 style: TextStyle(color: Colors.white),
//        //               ),
//        //               onPressed: () async {},
//        //             ),
//        //           ],
//        //         ),
//        //       )
//        //     ],
//        //   ),
//        // ),
//        TimeBankBillingAdminView(),
//        Settings,
//      ],
//    );
//  }

  Widget get Settings {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getTitle,
          SizedBox(
            height: 30,
          ),
          viewRequests(context: context),
          SizedBox(
            height: 20,
          ),
          viewReportedMembers(context: context),
          SizedBox(
            height: 20,
          ),

          widget.timebankModel.creatorId ==
                  SevaCore.of(context).loggedInUser.sevaUserID
              ? deleteTimebank
              : Container(),
          SizedBox(
            height: 20,
          ),
          widget.timebankModel.creatorId ==
                  SevaCore.of(context).loggedInUser.sevaUserID
              ? changeOwnerShip
              : Container(),
          // viewAcceptedOffers(context: context),
          // manageTimebankCodes(context: context),
//          billingView(context: context),
        ],
      ),
    );
  }

//  Widget getTile({String address, String title, String subtitle}) {
//    return ListTile(
//      leading: SvgPicture.asset(
//        address,
//        height: 24,
//        width: 24,
//      ),
//      title: Text(
//        title,
//        style: TextStyle(
//          fontSize: 14,
//        ),
//      ),
//      subtitle: Text(
//        subtitle,
//        style: TextStyle(
//          fontSize: 12,
//        ),
//      ),
//    );
//  }
//}
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
                      title: AppLocalizations.of(context).translate(
                          'external_notifications', 'request_accepted'),
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
                      title: AppLocalizations.of(context).translate(
                          'external_notifications', 'request_completed'),
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
                      title: AppLocalizations.of(context).translate(
                              'external_notifications', 'join_request') +
                          AppLocalizations.of(context).translate(
                              'external_notifications',
                              widget.isPrimaryTimebank ? 'timebank' : 'group'),
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
                      title: AppLocalizations.of(context)
                          .translate('external_notifications', 'offer_debit'),
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
                      title: AppLocalizations.of(context).translate(
                              'external_notifications', 'member_exits') +
                          AppLocalizations.of(context).translate(
                              'external_notifications',
                              widget.isPrimaryTimebank ? 'timebank' : 'group'),
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
                      title: AppLocalizations.of(context).translate(
                          'external_notifications', 'deletion_request'),
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
                      title: AppLocalizations.of(context).translate(
                          'external_notifications', 'credit_request'),
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
