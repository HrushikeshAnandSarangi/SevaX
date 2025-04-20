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
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';

import '../../../../l10n/l10n.dart';

class RequestsByCategoryView extends StatefulWidget {
  final CategoryModel model;
  final bool isUserSignedIn;

  const RequestsByCategoryView({
    Key? key,
    required this.model,
    required this.isUserSignedIn,
  }) : super(key: key);

  @override
  _RequestsByCategoryViewState createState() => _RequestsByCategoryViewState();
}

class _RequestsByCategoryViewState extends State<RequestsByCategoryView> {
  Future<List<RequestModel>>? requests;

  @override
  void initState() {
    requests =
        ElasticSearchApi.getRequestsByCategory(widget.model.typeId ?? '');
    log('type id: ' + (widget.model.typeId ?? ''));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExplorePageViewHolder(
      hideSearchBar: true,
      hideHeader: widget.isUserSignedIn,
      hideFooter: widget.isUserSignedIn,
      appBarTitle: widget.model.getCategoryName(context),
      //widget.model.getCategoryName(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: requests,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return WidgetWrapper(
                  categoryTitle: widget.model.title_en!,
                  page: 'Request Category',
                  isUserSignedIn: widget.isUserSignedIn,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 4 - 20),
                        child: LoadingIndicator(),
                      ),
                    ),
                  ],
                );
              }
              if (snapshot.data == null || (snapshot.data as List).isEmpty) {
                return WidgetWrapper(
                  categoryTitle: widget.model.title_en!,
                  page: 'Request Category',
                  isUserSignedIn: widget.isUserSignedIn,
                  children: [
                    Container(
                      alignment: Alignment.bottomCenter,
                      height: MediaQuery.of(context).size.height / 2.3,
                      child: Text(S.of(context).no_result_found),
                    ),
                  ],
                );
              }

              return WidgetWrapper(
                categoryTitle: widget.model.title_en!,
                page: 'Request Category',
                isUserSignedIn: widget.isUserSignedIn,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: (snapshot.data as List).length,
                    itemBuilder: (context, index) {
                      var request =
                          (snapshot.data as List<RequestModel>)[index];
                      // var date = DateTime.fromMillisecondsSinceEpoch(
                      //     request.requestStart);
                      return widget.isUserSignedIn
                          ? FutureBuilder<TimebankModel?>(
                              future: getTimeBankForId(
                                  timebankId: request.timebankId ?? ''),
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
                                            snapshot.data!,
                                            SevaCore.of(context)
                                                .loggedInUser
                                                .sevaUserID!)) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_context) => BlocProvider(
                                            bloc: BlocProvider.of<
                                                HomeDashBoardBloc>(context),
                                            child: RequestTabHolder(
                                              communityModel: BlocProvider.of<
                                                          HomeDashBoardBloc>(
                                                      context)!
                                                  .selectedCommunityModel,
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
                                            bloc: BlocProvider.of<
                                                HomeDashBoardBloc>(context),
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
                                  photoUrl: request.photoUrl ??
                                      defaultProjectImageURL,
                                  title: request.title,
                                  description: request.description,
                                  location: request.address,
                                  communityName: request.fullName ?? '',
                                  date: DateFormat('d MMMM, y').format(context
                                      .getDateTime(request.requestStart!)),
                                  time: DateFormat.jm().format(context
                                      .getDateTime(request.requestStart!)),
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
                              photoUrl:
                                  request.photoUrl ?? defaultProjectImageURL,
                              title: request.title,
                              description: request.description,
                              location: request.address,
                              communityName: request.fullName ?? '',
                              date: DateFormat('d MMMM, y').format(
                                  context.getDateTime(request.requestStart!)),
                              time: DateFormat.jm().format(
                                  context.getDateTime(request.requestStart!)),
                              memberList: MemberAvatarListWithCount(
                                userIds: request.approvedUsers,
                              ),
                            );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class WidgetWrapper extends StatelessWidget {
  final List<Widget> children;
  final String page;
  final String categoryTitle;
  final bool? isUserSignedIn;

  const WidgetWrapper(
      {Key? key,
      required this.children,
      required this.page,
      required this.categoryTitle,
      this.isUserSignedIn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HideWidget(
          hide: isUserSignedIn!,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      page,
                      style: TextStyle(
                        color: HexColor('#F5A623'),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: HexColor('#F5A623'),
                    size: 15,
                  ),
                  Text(
                    categoryTitle,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              // child: CustomBackButton(
              //   onBackPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
            ),
          ),
          secondChild: SizedBox.shrink(),
        ),
        ...children
      ],
    );
  }
}
