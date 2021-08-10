import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/requests/request_accepted_spending_view.dart';
import 'package:sevaexchange/views/requests/request_participants_view.dart';
import 'package:sevaexchange/views/requests/request_accepted_view_one_to_many.dart';

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
      context: context,
    );
  }
}

class TabarView extends StatelessWidget {
  final RequestModel requestItem;
  final TimebankModel timebankModel;
  final BuildContext context;

  TabarView({this.requestItem, this.timebankModel, this.context});

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
                  requestItem.requestType == RequestType.BORROW
                      ? L.of(context).responses
                      : S.of(context).participants,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  S.of(context).completed,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          body: TabBarView(
            children: [
              RequestParticipantsView(
                requestModel: requestItem,
                timebankModel: timebankModel,
              ),
              requestItem.requestType == RequestType.BORROW
                  ?
                  //Different UI TO BE MADE FOR BORROW REQUEST ?
                  RequestAcceptedSpendingView(
                      requestModel: requestItem,
                      timebankModel: timebankModel,
                    )
                  : requestItem.requestType == RequestType.ONE_TO_MANY_REQUEST
                      ? RequestAcceptedSpendingViewOneToMany(
                          requestModel: requestItem,
                          timebankModel: timebankModel,
                        ) //<--------- 'One to many completed page' ------------>

                      : RequestAcceptedSpendingView(
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
