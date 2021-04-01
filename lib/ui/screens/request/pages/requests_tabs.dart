import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/request/pages/virtual_requests.dart';
import 'package:sevaexchange/views/timebank_modules/timebank_requests.dart';

class RequestTabs extends StatelessWidget {
  final String timebankId;
  final TimebankModel timebankModel;
  final bool isFromSettings;
  RequestTabs(
      {Key key, this.timebankId, this.isFromSettings, this.timebankModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              TabBar(
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.black,
                tabs: <Widget>[
                  Tab(
                    child: Text(
                      S.of(context).requests,
                    ),
                  ),
                  Tab(
                    child: Text('Virtual requests'),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    RequestsModule.of(
                      timebankId: timebankId,
                      isFromSettings: false,
                      timebankModel: timebankModel,
                    ),
                    VirtualRequests(
                      timebankId: timebankId,
                      timebankModel: timebankModel,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
