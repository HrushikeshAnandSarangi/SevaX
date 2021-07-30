import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/elastic_search.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_community_details.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page_view_holder.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_search_cards.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/members_avatar_list_with_count.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/request_tab_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_back.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

import '../../../../l10n/l10n.dart';

class RequestsByCategoryView extends StatefulWidget {
  final CategoryModel model;
  final bool isUserSignedIn;

  const RequestsByCategoryView({
    Key key,
    @required this.model,
    @required this.isUserSignedIn,
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
      hideHeader: widget.isUserSignedIn,
      hideFooter: widget.isUserSignedIn,
      appBarTitle: widget.model.title_en != null
          ? widget.model.title_en
          : '', //widget.model.getCategoryName(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HideWidget(
            hide: widget.isUserSignedIn,
            child: CustomBackButton(
              onBackPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => ExplorePage(
                        isUserSignedIn: false,
                      ),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ),
          FutureBuilder(
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
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height / 2,
                  child: Text(S.of(context).no_result_found),
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
                  return widget.isUserSignedIn
                      ? FutureBuilder<TimebankModel>(
                          future:
                              getTimeBankForId(timebankId: request.timebankId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LoadingIndicator();
                            }
                            if (snapshot.hasError) {
                              return Container();
                            }
                            if (snapshot.data == null) {
                              return Container();
                            }
                            return ExploreEventCard(
                              onTap: () {
                                if (request.sevaUserId ==
                                        SevaCore.of(context)
                                            .loggedInUser
                                            .sevaUserID ||
                                    isAccessAvailable(
                                        snapshot.data,
                                        SevaCore.of(context)
                                            .loggedInUser
                                            .sevaUserID)) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_context) => BlocProvider(
                                        bloc:
                                            BlocProvider.of<HomeDashBoardBloc>(
                                                context),
                                        child: RequestTabHolder(
                                          //communityModel: BlocProvider.of<HomeDashBoardBloc>(context).selectedCommunityModel,
                                          isAdmin: true,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_context) => BlocProvider(
                                        bloc:
                                            BlocProvider.of<HomeDashBoardBloc>(
                                                context),
                                        child: RequestDetailsAboutPage(
                                          requestItem: request,
                                          timebankModel: snapshot.data,
                                          isAdmin: false,
                                          //communityModel: BlocProvider.of<HomeDashBoardBloc>(context).selectedCommunityModel,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              photoUrl:
                                  request.photoUrl ?? defaultProjectImageURL,
                              title: request.title,
                              description: request.description,
                              location: request.address,
                              communityName: request.fullName ?? '',
                              date: DateFormat('d MMMM, y').format(date),
                              time: DateFormat.jm().format(date),
                              memberList: MemberAvatarListWithCount(
                                userIds: request.approvedUsers,
                              ),
                            );
                          })
                      : ExploreEventCard(
                          onTap: () {
                            showSignInAlertMessage(
                                context: context,
                                message: S.of(context).sign_in_alert);
                          },
                          photoUrl: request.photoUrl ?? defaultProjectImageURL,
                          title: request.title,
                          description: request.description,
                          location: request.address,
                          communityName: request.fullName ?? '',
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
        ],
      ),
    );
  }
}
