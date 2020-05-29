import 'package:flutter/material.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/views/requests/request_accepted_spending_view.dart';
import 'package:sevaexchange/views/requests/request_participants_view.dart';

class RequestAcceptedTabsViewHolder extends StatelessWidget {
  final RequestModel requestItem;
  final TimebankModel timebankModel;

  RequestAcceptedTabsViewHolder.of({
    @required this.requestItem,
    this.timebankModel,
  });
  //TimebankTabsViewHolder.of(this.loggedInUser, {this.timebankId, this.timebankModel});

  @override
  Widget build(BuildContext context) {
    return TabarView(
      timebankModel: timebankModel,
      requestItem: requestItem,
    );
  }
}

class TabarView extends StatelessWidget {
  final RequestModel requestItem;
  final TimebankModel timebankModel;

  TabarView({this.requestItem, this.timebankModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(
                child: Text(
                  'Participants',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Completed',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          body: TabBarView(
            children: [
              RequestParticipantsView(
                requestModel: requestItem,
              ),
              RequestAcceptedSpendingView(
                requestModel: requestItem,
                timebankModel: timebankModel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
