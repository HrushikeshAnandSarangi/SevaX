import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/timebanks/admin_personal_requests_view.dart';
import 'package:sevaexchange/views/timebanks/timebank_existing_requests.dart';

class AdminOfferRequestsTab extends StatefulWidget {
  final String timebankid;

  final BuildContext parentContext;
  final UserModel userModel;

  AdminOfferRequestsTab(
      {required this.timebankid,
      required this.parentContext,
      required this.userModel});

  @override
  _AdminOfferRequestsTabState createState() => _AdminOfferRequestsTabState();
}

class _AdminOfferRequestsTabState extends State<AdminOfferRequestsTab> {
  TimebankModel timebankModel = TimebankModel({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirestoreManager.getTimeBankForId(timebankId: widget.timebankid)
        .then((onValue) {
      timebankModel = onValue!;
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
            S.of(context).existing_requests,
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
                  text: S.of(context).seva_community_requests,
                ),
                Tab(text: S.of(context).personal_request(0)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  TimeBankExistingRequests(
                    timebankId: widget.timebankid,
                    isAdmin: true,
                    userModel: widget.userModel,
                  ),
                  AdminPersonalRequests(
                    timebankId: widget.timebankid,
                    isTimebankRequest: true,
                    userModel: widget.userModel,
                    showAppBar: false,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
