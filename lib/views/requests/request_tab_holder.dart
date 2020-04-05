import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/views/requests/request_accepted_content_holder.dart';
import 'package:sevaexchange/views/requests/request_users_content_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';

class RequestTabHolder extends StatelessWidget {
  bool isAdmin;
  RequestTabHolder({this.isAdmin});
  final List<String> titles = ['About', 'Search', 'Accepted'];
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: timeBankBloc.timebankController,
        builder: (context, AsyncSnapshot<TimebankController> snapshot) {
          if (snapshot.data != null && snapshot.data.selectedrequest != null) {
            print("inside_if---" + snapshot.data.selectedrequest.toString());

            var requestModel = snapshot.data.selectedrequest;
            var timebank = snapshot.data.selectedtimebank;
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
                                project_id: '',
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
            print("inside_else");
            return Text("");
          }
        });
  }
}
