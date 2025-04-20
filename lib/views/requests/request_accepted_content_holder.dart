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
  final TimebankModel? timebankModel;

  RequestAcceptedTabsViewHolder.of({
    required this.requestItem,
    this.timebankModel,
  });
  //TimebankTabsViewHolder.of(this.loggedInUser, {this.timebankId, this.timebankModel});

  @override
  Widget build(BuildContext context) {
    return TabarView(
      timebankModel: timebankModel!,
      requestItem: requestItem,
      context: context,
    );
  }
}

class TabarView extends StatelessWidget {
  final RequestModel requestItem;
  final TimebankModel timebankModel;
  final BuildContext context;

  TabarView(
      {required this.requestItem,
      required this.timebankModel,
      required this.context});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: requestItem.requestType == RequestType.BORROW
          ? DefaultTabController(
              length: 1,
              child: RequestParticipantsView(
                requestModel: requestItem,
                timebankModel: timebankModel,
              ),
            )
          : DefaultTabController(
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
                            ? S.of(context).responses_text
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
                    requestItem.requestType == RequestType.ONE_TO_MANY_REQUEST
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
