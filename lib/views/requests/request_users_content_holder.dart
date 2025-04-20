import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/views/requests/find_volunteers_view.dart';
import 'package:sevaexchange/views/requests/past_hired_users_view.dart';
import '../core.dart';
import 'favorite_users_view.dart';
import 'invited_users_view.dart';

class RequestUsersTabsViewHolder extends StatefulWidget {
  final RequestModel? requestItem;

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
      requestItem: widget.requestItem!,
    );
  }
}

class TabarView extends StatelessWidget {
  late String sevaUserId;
  final RequestModel requestItem;
  TabarView({required this.requestItem});

  @override
  Widget build(BuildContext context) {
    sevaUserId = SevaCore.of(context).loggedInUser.sevaUserID!;
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
                  S.of(context).find_volunteers,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  S.of(context).invited,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  S.of(context).favourites,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  S.of(context).past_hired,
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
                timebankId: requestItem.timebankId!,
                requestModel: requestItem,
                sevaUserId: sevaUserId,
              ),
              FavoriteUsers(
                timebankId: requestItem.timebankId!,
                requestModelId: requestItem.id,
                sevaUserId: sevaUserId,
              ),
              PastHiredUsersView(
                timebankId: requestItem.timebankId!,
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
