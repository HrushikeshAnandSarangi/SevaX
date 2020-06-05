import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/views/requests/request_accepted_content_holder.dart';
import 'package:sevaexchange/views/requests/request_users_content_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';

class RequestTabHolder extends StatelessWidget {
  bool isAdmin;
  RequestTabHolder({this.isAdmin});
  List<String> titles;
  @override
  Widget build(BuildContext context) {
    titles = [AppLocalizations.of(context).translate('requests','about'), AppLocalizations.of(context).translate('requests','search'), AppLocalizations.of(context).translate('requests','accepted')];
    return StreamBuilder(
        stream: timeBankBloc.timebankController,
        builder: (context, AsyncSnapshot<TimebankController> snapshot) {
          if (snapshot.data != null && snapshot.data.selectedrequest != null) {

            var requestModel = snapshot.data.selectedrequest;
            TimebankModel timebank = snapshot.data.selectedtimebank;
            return DefaultTabController(
              length: 3,
              child: Scaffold(
                body: SafeArea(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              color: Colors.grey,
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: TabBar(
                                tabs: List.generate(
                                  3,
                                  (index) => Tab(
                                    child: Text(
                                      titles[index],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: <Widget>[
                            Container(
                              child: RequestDetailsAboutPage(
                                requestItem: requestModel,
                                timebankModel: timebank,
                                isAdmin: true,
                                applied: false,
                              ),
                            ),
                            Container(
                              child: RequestUsersTabsViewHolder.of(
                                requestItem: requestModel,
                              ),
                            ),
                            Container(
                              child: RequestAcceptedTabsViewHolder.of(
                                requestItem: requestModel,
                                timebankModel: timebank,
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
          } else {
            return Text("");
          }
        });
  }
}
