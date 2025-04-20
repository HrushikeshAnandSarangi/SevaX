import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';

import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/communities/widgets/communities_categories.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_search_page_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_community_details.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_search_cards.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/members_avatar_list_with_count.dart';
import 'package:sevaexchange/ui/utils/tag_builder.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/requests/project_request.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

import '../../../../l10n/l10n.dart';

class EventsSearchView extends StatelessWidget {
  final bool? isUserSignedIn;

  const EventsSearchView({Key? key, this.isUserSignedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _bloc = Provider.of<ExploreSearchPageBloc>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<ProjectModel>>(
          stream: _bloc.events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Text(S.of(context).no_search_result_found);
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var event = snapshot.data![index];
                // var date = DateTime.fromMillisecondsSinceEpoch(event.startTime);
                return isUserSignedIn!
                    ? FutureBuilder<TimebankModel?>(
                        future: getTimeBankForId(
                            timebankId: event.timebankId ?? ''),
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
                                if (isUserSignedIn != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ProjectRequests(
                                          ComingFrom.Projects,
                                          timebankId: event.timebankId!,
                                          projectModel: event,
                                          timebankModel: snapshot.data!,
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  showSignInAlertMessage(
                                    context: context,
                                    message: S.of(context).sign_in_alert,
                                  );
                                }
                              },
                              photoUrl:
                                  event.photoUrl ?? defaultProjectImageURL,
                              title: event.name,
                              description: event.description,
                              location: event.address,
                              communityName: event.communityName ?? '',
                              date: DateFormat('d MMMM, y').format(
                                  context.getDateTime(event.startTime!)),
                              time: DateFormat.jm().format(
                                  context.getDateTime(event.startTime!)),
                              memberList: MemberAvatarListWithCount(
                                userIds: event.associatedmembers!.keys.toList(),
                              ),
                              tagsToShow: TagBuilder(
                                isPublic: event.public!,
                                isVirtual: event.virtualProject!,
                              ).getTags(context));
                        })
                    : ExploreEventCard(
                        onTap: () {
                          showSignInAlertMessage(
                              context: context,
                              message: S.of(context).sign_in_alert);
                        },
                        photoUrl: event.photoUrl ?? defaultProjectImageURL,
                        title: event.name,
                        description: event.description,
                        location: event.address,
                        communityName: event.communityName ?? '',
                        date: DateFormat('d MMMM, y')
                            .format(context.getDateTime(event.startTime!)),
                        time: DateFormat.jm()
                            .format(context.getDateTime(event.startTime!)),
                        memberList: MemberAvatarListWithCount(
                          userIds: event.associatedmembers!.keys.toList(),
                        ),
                        tagsToShow: TagBuilder(
                          isPublic: event.public!,
                          isVirtual: event.virtualProject!,
                        ).getTags(context),
                      );
              },
            );
          },
        ),
        SizedBox(height: 22),
        Text(
          S.of(context).browse_by_category,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        CommunitiesCategory(
          stream: _bloc.communityCategory,
          onTap: (value) {
            _bloc.onCommunityCategoryChanged(value.id);
            Provider.of<ScrollController>(context, listen: false)?.animateTo(
              0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
        ),
      ],
    );
  }
}
