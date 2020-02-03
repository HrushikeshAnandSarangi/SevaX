import 'package:flutter/material.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/models/timebank_model.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/favorite_users_view.dart';
import 'package:sevaexchange/views/requests/find_volunteers_view.dart';
import 'package:sevaexchange/views/requests/invited_users_view.dart';
import 'package:sevaexchange/views/requests/past_hired_users_view.dart';

class RequestUsersTabsViewHolder extends StatefulWidget {
  final RequestModel requestItem;

  RequestUsersTabsViewHolder.of({
    this.requestItem,
  });

  @override
  _RequestUsersTabsViewHolderState createState() =>
      _RequestUsersTabsViewHolderState();
}

class _RequestUsersTabsViewHolderState
    extends State<RequestUsersTabsViewHolder> {

  @override
  void initState() {

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return TabarView(
      // loggedInUser: loggedInUser,
      requestItem: widget.requestItem,
    );
  }
}

class TabarView extends StatelessWidget {
  final Function set;
  String sevaUserId;
  final RequestModel requestItem;
  TabarView({this.requestItem, this.set});

  @override
  Widget build(BuildContext context) {

    sevaUserId=SevaCore
        .of(context)
        .loggedInUser.sevaUserID;
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
                child: Text(
                  'Find Volunteers',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Invited',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Favourites',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Past Hired',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          body: TabBarView(
            children: [
              FindVolunteersView(
                timebankId: requestItem.timebankId,
                requestModel: requestItem,
                sevaUserId: sevaUserId,
              ),
              InvitedUsersView(
                timebankId: requestItem.timebankId,
                requestModel: requestItem,
                sevaUserId: sevaUserId,
              ),
              FavoriteUsers(
                timebankId: requestItem.timebankId,
                requestModelId: requestItem.id,
                sevaUserId: sevaUserId,
              ),
              PastHiredUsersView(
                timebankId: requestItem.timebankId,
                requestModel: requestItem,
                sevaUserId: sevaUserId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
