import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/elastic_search.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_page_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page_view_holder.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_search_cards.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/members_avatar_list_with_count.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class RequestsByCategoryView extends StatefulWidget {
  final CategoryModel model;

  const RequestsByCategoryView({
    Key key,
    @required this.model,
  }) : super(key: key);
  @override
  _RequestsByCategoryViewState createState() => _RequestsByCategoryViewState();
}

class _RequestsByCategoryViewState extends State<RequestsByCategoryView> {
  Future<List<RequestModel>> requests;

  @override
  void initState() {
    requests = ElasticSearchApi.getRequestsByCategory(widget.model.typeId);
    log('type id: ' + widget.model.typeId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExplorePageViewHolder(
      hideSearchBar: true,
      hideHeader: Provider.of<UserModel>(context, listen: false) != null,
      hideFooter: Provider.of<UserModel>(context, listen: false) != null,
      appBarTitle: 'Title Test', //widget.model.getCategoryName(context),
      child: FutureBuilder(
        future: requests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 4 - 20),
                child: LoadingIndicator(),
              ),
            );
          }
          if (snapshot.data == null || snapshot.data.isEmpty) {
            return Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 4 - 20),
                child: Text('No result found'),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              var request = snapshot.data[index];
              var date =
                  DateTime.fromMillisecondsSinceEpoch(request.requestStart);
              return ExploreEventCard(
                photoUrl: request.photoUrl ?? defaultProjectImageURL,
                title: request.title,
                description: request.description,
                location: request.address,
                communityName: "request.communityName ?? ''",
                date: DateFormat('d MMMM, y').format(date),
                time: DateFormat.jm().format(date),
                memberList: MemberAvatarListWithCount(
                  userIds: request.approvedUsers,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
