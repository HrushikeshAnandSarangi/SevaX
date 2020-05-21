import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/views/requests/request_accepted_spending_view.dart';
import 'package:sevaexchange/views/requests/request_participants_view.dart';

class RequestAcceptedTabsViewHolder extends StatelessWidget {
  final RequestModel requestItem;

  RequestAcceptedTabsViewHolder.of({
    @required this.requestItem,
  });
  //TimebankTabsViewHolder.of(this.loggedInUser, {this.timebankId, this.timebankModel});

  @override
  Widget build(BuildContext context) {
    return TabarView(
      // loggedInUser: loggedInUser,
      requestItem: requestItem,
    );
  }
}

class TabarView extends StatelessWidget {
  final RequestModel requestItem;

  TabarView({this.requestItem});

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
                  AppLocalizations.of(context).translate('requests','participants'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  AppLocalizations.of(context).translate('requests','completed'),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
