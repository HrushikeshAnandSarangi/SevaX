import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/members/pages/member_permissions.dart';
import 'package:sevaexchange/ui/screens/reported_members/pages/reported_member_page.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_listing_page.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/views/community/communitycreate.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/edit_group.dart';
import 'package:sevaexchange/views/timebanks/timebank_manage_seva.dart';

import '../../flavor_config.dart';

class ManageGroupView extends StatefulWidget {
  final TimebankModel timebankModel;

  ManageGroupView.of({this.timebankModel});
  @override
  State<StatefulWidget> createState() {
    return _ManageGroupView();
  }
}

class _ManageGroupView extends State<ManageGroupView> {
  var _indextab = 0;

  CommunityModel communityModel = CommunityModel({});
  bool isSuperAdmin = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      FirestoreManager.getCommunityDetailsByCommunityId(
              communityId: widget.timebankModel.communityId)
          .then((onValue) {
        communityModel = onValue;
        if (SevaCore.of(context).loggedInUser.sevaUserID ==
                communityModel.created_by ||
            communityModel.organizers
                .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
          isSuperAdmin = true;
          setState(() {});
        }
      });
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //   print("seva id ${SevaCore.of(context).loggedInUser.sevaUserID}");

    if (isSuperAdmin) {
      return DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              isScrollable: false,
              tabs: <Widget>[
                Tab(text: S.of(context).edit_group),
                Tab(text: S.of(context).settings),
                Tab(
                  text: S.of(context).bottom_nav_notifications,
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  EditGroupView(
                    timebankModel: widget.timebankModel,
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
                Tab(text: S.of(context).edit_group),
                Tab(text: S.of(context).settings),
                Tab(
                  text: S.of(context).bottom_nav_notifications,
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  EditGroupView(
                    timebankModel: widget.timebankModel,
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

  Widget superAdminView() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              isScrollable: false,
              tabs: <Widget>[
                Tab(text: S.of(context).about),
                Tab(text: S.of(context).settings),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get normalAdminWidget {
    return IndexedStack(
      index: _indextab,
      children: <Widget>[
        CreateEditCommunityView(
          isCreateTimebank: false,
          isFromFind: false,
          timebankId: widget.timebankModel.id,
        ),
        Settings,
      ],
    );
  }

  // Widget viewRequests({BuildContext context}) {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => RequestListingPage(
  //             // timebankId: widget.timebankModel.id,
  //             timebankModel: widget.timebankModel,
  //             isFromSettings: true,
  //           ),
  //         ),
  //       );
  //     },
  //     child: Text(
  //       S.of(context).view_requests,
  //       style: TextStyle(
  //         fontSize: 14,
  //         fontWeight: FontWeight.bold,
  //         color: Colors.blue,
  //       ),
  //     ),
  //   );
  // }

  Widget viewReportedMembers({BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          ReportedMembersPage.route(
            timebankModel: widget.timebankModel,
            communityId: widget.timebankModel.communityId,
            isFromTimebank: false,
          ),
        );
      },
      child: Text(
        S.of(context).reported_members,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget get deleteGroup {
    return GestureDetector(
      onTap: () {
        showAdvisoryBeforeDeletion(
          context: context,
          associatedId: widget.timebankModel.id,
          softDeleteType: SoftDelete.REQUEST_DELETE_GROUP,
          associatedContentTitle: widget.timebankModel.name,
          email: SevaCore.of(context).loggedInUser.email,
          isAccedentalDeleteEnabled:
              widget.timebankModel.preventAccedentalDelete,
        );
      },
      child: Text(
        S.of(context).delete_group,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
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

  Widget get bodyWidget {
    return IndexedStack(
      index: _indextab,
      children: <Widget>[
        CreateEditCommunityView(
          isCreateTimebank: false,
          isFromFind: false,
          timebankId: widget.timebankModel.id,
        ),
        // TimeBankBillingAdminView(),
        Settings,
      ],
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
          SizedBox(
            height: 30,
          ),
          // viewRequests(context: context),
          // SizedBox(
          //   height: 30,
          // ),
          viewReportedMembers(context: context),
          SizedBox(
            height: 30,
          ),
          viewMemberConfigurations(context: context),
          SizedBox(
            height: 30,
          ),
          deleteGroup,
        ],
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

  Widget getTile({String address, String title, String subtitle}) {
    return ListTile(
      leading: SvgPicture.asset(
        address,
        height: 24,
        width: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }
}
