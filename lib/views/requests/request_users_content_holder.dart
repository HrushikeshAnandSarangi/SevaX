import 'package:flutter/material.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/views/requests/bookmarked_users_view.dart';
import 'package:sevaexchange/views/requests/find_volunteers_view.dart';
import 'package:sevaexchange/views/requests/invited_users_view.dart';
import 'package:sevaexchange/views/requests/past_hired_users_view.dart';

class RequestUsersTabsViewHolder extends StatelessWidget {
  //final String timebankId;
 // final TimebankModel timebankModel;
  //final UserModel loggedInUser;

  final RequestModel requestItem;




  RequestUsersTabsViewHolder.of({this.requestItem,});
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


  //final UserModel loggedInUser;
  //TabarView({this.loggedInUser, this.timebankId, this.timebankModel});
  TabarView({this.requestItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: Scaffold(

          appBar: TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.label,
              isScrollable: true,
              tabs: [
                Tab(
                  child: Text('Find Volunteers',style: TextStyle(fontWeight: FontWeight.bold),),

                ),
                Tab(
                  child: Text('Invited',style: TextStyle(fontWeight: FontWeight.bold),),

                ),
                Tab(
                  child: Text('Favourites',style: TextStyle(fontWeight: FontWeight.bold),),

                ),
                Tab(
                  child: Text('Past Hired',style: TextStyle(fontWeight: FontWeight.bold),),

                ),

              ],
            ),

          body: TabBarView(
            children: [
              FindVolunteersView(timebankId: requestItem.timebankId),
              InvitedUsersView(timebankId: requestItem.timebankId),
              BookmarkedUsers(),
              PastHiredUsersView(timebankId: requestItem.timebankId),
            ],
          ),
        ),
      ),
    );
  }

}