import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/request/pages/donation_accepted_page.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/views/requests/request_accepted_content_holder.dart';
import 'package:sevaexchange/views/requests/request_users_content_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';

class RequestTabHolder extends StatelessWidget {
  final bool isAdmin;
  final CommunityModel communityModel;

  RequestTabHolder({this.isAdmin, this.communityModel});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: timeBankBloc.timebankController,
      builder: (context, AsyncSnapshot<TimebankController> snapshot) {
        if (snapshot.data != null && snapshot.data.selectedrequest != null) {
          var requestModel = snapshot.data.selectedrequest;
          TimebankModel timebank = snapshot.data.selectedtimebank;
          List<String> titles = [
            S.of(context).about,
            S.of(context).search,
            requestModel.requestType == RequestType.BORROW
                ? S.of(context).responses_text
                : S.of(context).accepted
          ];
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                              communityModel: communityModel,
                            ),
                          ),
                          Container(
                            child: RequestUsersTabsViewHolder.of(
                              requestItem: requestModel,
                            ),
                          ),
                          ...(requestModel.requestType == RequestType.TIME ||
                                  requestModel.requestType ==
                                      RequestType.BORROW ||
                                  requestModel.requestType ==
                                      RequestType.ONE_TO_MANY_REQUEST)
                              ? <Widget>[
                                  Container(
                                    child: RequestAcceptedTabsViewHolder.of(
                                      requestItem: requestModel,
                                      timebankModel: timebank,
                                    ),
                                  ),
                                ]
                              : <Widget>[
                                  Container(
                                    child: DonationAcceptedPage(
                                      model: requestModel,
                                    ),
                                  ),
                                ],
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
      },
    );
  }
}
