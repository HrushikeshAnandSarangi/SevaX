import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/timebanks/admin_personal_requests_view.dart';
import 'package:sevaexchange/views/timebanks/timebank_existing_requests.dart';

class AdminOfferRequestsTab extends StatefulWidget {
  final String timebankid;

  final BuildContext parentContext;
  final UserModel userModel;

  AdminOfferRequestsTab({this.timebankid, this.parentContext, this.userModel});

  @override
  _AdminOfferRequestsTabState createState() => _AdminOfferRequestsTabState();
}

class _AdminOfferRequestsTabState extends State<AdminOfferRequestsTab> {
  TimebankModel timebankModel = TimebankModel({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print("user data---------> ${widget.userModel.sevaUserID}");
    FirestoreManager.getTimeBankForId(timebankId: widget.timebankid)
        .then((onValue) {
      timebankModel = onValue;
    });

    //   timeBankBloc.getRequestsStreamFromTimebankId(widget.timebankid);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Existing Requests",
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: Column(
          children: <Widget>[
            TabBar(
              labelColor: Theme.of(context).primaryColor,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorSize: TabBarIndicatorSize.label,
              unselectedLabelColor: Colors.black,
              isScrollable: true,
              tabs: [
                Tab(
                  text: "Timebank Requests",
                ),
                Tab(
                  text: "Personal Requests",
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  TimeBankExistingRequests(
                    timebankId: widget.timebankid,
                    isAdmin: true,
                    parentContext: context,
                    userModel: widget.userModel,
                  ),
                  AdminPersonalRequests(
                      timebankId: widget.timebankid,
                      isTimebankRequest: true,
                      parentContext: context,
                      userModel: widget.userModel,
                      showAppBar: false),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
