import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/views/requests/request_accepted_content_holder.dart';
import 'package:sevaexchange/views/requests/request_users_content_holder.dart';
import 'package:sevaexchange/views/timebank_modules/timebank_request_details.dart';

class RequestTabHolder extends StatelessWidget {
  final RequestModel requestModel;

  RequestTabHolder({@required this.requestModel});
  var titles = ['About', 'Search', 'Accepted'];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              TabBar(
                tabs: List.generate(
                    3,
                    (index) => Tab(
                          child: Text(
                            titles[index],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    Container(
                      child: TimeBankRequestDetails(requestItem: requestModel),
                    ),
                    Container(
                        child: RequestUsersTabsViewHolder.of(
                      requestItem: requestModel,
                    )),
                    Container(
                      child: RequestAcceptedTabsViewHolder.of(
                        requestItem: requestModel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
