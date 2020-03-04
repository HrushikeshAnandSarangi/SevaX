import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/views/community/communitycreate.dart';
import 'package:sevaexchange/views/invitation/InviteMembers.dart';
import 'package:sevaexchange/views/manage/timebank_billing_admin_view.dart';
import 'package:sevaexchange/views/timebank_modules/timebank_requests.dart';
import 'package:sevaexchange/views/workshop/acceptedOffers.dart';

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
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            bottom: TabBar(
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              isScrollable: false,
              tabs: <Widget>[
                Tab(text: "About"),
                // Tab(text: "Upgrade"),
                Tab(text: "Billings"),
                Tab(text: "Settings"),
              ],
              onTap: (index) {
                if (_indextab != index) {
                  _indextab = index;
                  setState(() {});
                }
              },
            ),
          ),
        ),
        body: bodyWidget,
      ),
    );
  }

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
        'View requests',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget viewAcceptedOffers({BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AcceptedOffers(
              timebankId: widget.timebankModel.id,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 20),
        child: Text(
          'View accepted offers',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget vieweditPage({BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateEditCommunityView(
              timebankId: widget.timebankModel.id,
              isFromFind: false,
              isCreateTimebank: false,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 20),
        child: Text(
          'Edit Timebank',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget manageTimebankCodes({BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InviteMembers(
              widget.timebankModel.id,
              widget.timebankModel.communityId,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 20),
        child: Text(
          'Invite members via code',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

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
      "Manage ${widget.timebankModel.name}",
      style: TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  viewBillingPage({BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TimeBankBillingAdminView(),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 20),
        child: Text(
          'Admin Billing',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
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
        // SingleChildScrollView(
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: <Widget>[
        //       Padding(
        //         padding: EdgeInsets.all(40),
        //         child: Image.asset(
        //           'lib/assets/images/startup.png',
        //           height: 150,
        //         ),
        //       ),
        //       getTile(
        //         address: 'lib/assets/images/drawing-tablet.svg',
        //         title: 'Unlimited groups',
        //         subtitle: 'No limit on groups your team can create',
        //       ),
        //       getTile(
        //         address: 'lib/assets/images/add-user.svg',
        //         title: 'Unlimited users',
        //         subtitle: 'No limit on users for your timebank',
        //       ),
        //       getTile(
        //         address: 'lib/assets/images/bars.svg',
        //         title: 'Pay as you go',
        //         subtitle: 'Pay as per total members in your team',
        //       ),
        //       getTile(
        //         address: 'lib/assets/images/megaphone.svg',
        //         title: 'Absolute control on public post',
        //         subtitle: 'Control on data your team public posts',
        //       ),
        //       getTile(
        //         address: 'lib/assets/images/lightbulb.svg',
        //         title: 'Organize your spendings',
        //         subtitle: 'Have a holistic view on your spending',
        //       ),
        //       getTile(
        //         address: 'lib/assets/images/levels.svg',
        //         title: 'Settings',
        //         subtitle: 'Manage your child timebanks',
        //       ),
        //       getTile(
        //         address: 'lib/assets/images/color-palette.svg',
        //         title: 'Themes',
        //         subtitle: 'Customize your own look',
        //       ),
        //       Padding(
        //         padding: EdgeInsets.only(top: 50, bottom: 50),
        //         child: Column(
        //           children: <Widget>[
        //             Text(
        //               '5\$ \/ user \/ month',
        //             ),
        //             RaisedButton(
        //               color: Colors.red,
        //               child: Text(
        //                 'Upgrade',
        //                 style: TextStyle(color: Colors.white),
        //               ),
        //               onPressed: () async {},
        //             ),
        //           ],
        //         ),
        //       )
        //     ],
        //   ),
        // ),
        TimeBankBillingAdminView(),
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
          viewRequests(context: context),
          viewAcceptedOffers(context: context),
          manageTimebankCodes(context: context),
//          billingView(context: context),
        ],
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
