import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_search_page_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_community_details.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_search_cards.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/members_avatar_list_with_count.dart';
import 'package:sevaexchange/ui/screens/request/widgets/request_categories.dart';
import 'package:sevaexchange/ui/utils/tag_builder.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

import '../../../../l10n/l10n.dart';

class RequestsSearchView extends StatelessWidget {
  final bool? isUserSignedIn;

  const RequestsSearchView({Key? key, this.isUserSignedIn}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var _bloc = Provider.of<ExploreSearchPageBloc>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<RequestModel>>(
          stream: _bloc.requests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Text(S.of(context).no_result_found);
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var request = snapshot.data![index];
                // var date =
                //     DateTime.fromMillisecondsSinceEpoch(request.requestStart);

                return isUserSignedIn!
                    ? FutureBuilder<TimebankModel?>(
                        future:
                            getTimeBankForId(timebankId: request.timebankId!),
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
                              bool isAdmin = snapshot.data?.admins.contains(
                                    SevaCore.of(context)
                                        .loggedInUser
                                        .sevaUserID,
                                  ) ??
                                  false;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return RequestDetailsAboutPage(
                                      isAdmin: isAdmin,
                                      timebankModel: snapshot.data,
                                      requestItem: request,
                                    );
                                  },
                                ),
                              );
                            },
                            photoUrl:
                                request.photoUrl ?? defaultProjectImageURL,
                            title: request.title,
                            description: request.description,
                            location: request.address,
                            communityName: request.communityName ?? ' ',
                            date: DateFormat('d MMMM, y').format(
                                context.getDateTime(request.requestStart!)),
                            time: DateFormat.jm().format(
                                context.getDateTime(request.requestStart!)),
                            memberList: MemberAvatarListWithCount(
                              userIds: request.approvedUsers,
                            ),
                            tagsToShow: TagBuilder(
                              isPublic: request.public!,
                              isVirtual: request.virtualRequest!,
                              isMoneyRequest:
                                  request.requestType == RequestType.CASH,
                              isGoodsRequest:
                                  request.requestType == RequestType.GOODS,
                              isTimeRequest:
                                  request.requestType == RequestType.TIME,
                              isOneToManyRequest: request.requestType ==
                                  RequestType.ONE_TO_MANY_REQUEST,
                              isBorrowRequest:
                                  request.requestType == RequestType.BORROW,
                            ).getTags(context),
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
                        communityName: request.communityName ?? ' ',
                        date: DateFormat('d MMMM, y')
                            .format(context.getDateTime(request.requestStart!)),
                        time: DateFormat.jm()
                            .format(context.getDateTime(request.requestStart!)),
                        memberList: MemberAvatarListWithCount(
                          userIds: request.approvedUsers,
                        ),
                        tagsToShow: TagBuilder(
                          isPublic: request.public!,
                          isVirtual: request.virtualRequest!,
                          isMoneyRequest:
                              request.requestType == RequestType.CASH,
                          isGoodsRequest:
                              request.requestType == RequestType.GOODS,
                          isTimeRequest:
                              request.requestType == RequestType.TIME,
                          isOneToManyRequest: request.requestType ==
                              RequestType.ONE_TO_MANY_REQUEST,
                          isBorrowRequest:
                              request.requestType == RequestType.BORROW,
                        ).getTags(context));
              },
            );
          },
        ),
        Text(S.of(context).browse_requests_by_category,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        RequestCategories(
          onTap: (value) {
            _bloc.onRequestCategoryChanged(value.typeId!);
            Provider.of<ScrollController>(context, listen: false)?.animateTo(
              0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          stream: _bloc.requestCategory,
        ),
      ],
    );
  }
}
