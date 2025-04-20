import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_community_details_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page_view_holder.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/members_avatar_list_with_count.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/sponsors/sponsors_widget.dart';
import 'package:sevaexchange/ui/screens/sponsors/widgets/get_user_verified.dart';
import 'package:sevaexchange/ui/screens/timebank/widgets/community_about_widget.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/blocs/user_profile_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/invitation/OnboardWithTimebankCode.dart';
import 'package:sevaexchange/views/login/login_page.dart';
import 'package:sevaexchange/views/requests/project_request.dart';
import 'package:sevaexchange/views/switch_timebank.dart';
import 'package:sevaexchange/views/timebank_content_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_back.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class ExploreCommunityDetails extends StatefulWidget {
  final String? communityId;
  final bool? isSignedUser;

  const ExploreCommunityDetails(
      {Key? key, this.communityId, required this.isSignedUser})
      : super(key: key);

  @override
  _ExploreCommunityDetailsState createState() =>
      _ExploreCommunityDetailsState();
}

class _ExploreCommunityDetailsState extends State<ExploreCommunityDetails> {
  ExploreCommunityDetailsBloc _bloc = ExploreCommunityDetailsBloc();
  final pageController = PageController(initialPage: 0);
  String reasonText = "";
  final TextEditingController reasonTextController = TextEditingController();
  TimebankModel timebankModel = TimebankModel({});
  bool isUserJoined = false;
  List<String>? templist;
  UserProfileBloc? _profileBloc;
  CommunityModel? community;

  @override
  void initState() {
    _profileBloc = UserProfileBloc();

    _bloc.init(widget.communityId!, widget.isSignedUser ?? false);
    // setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List>(
        stream: CombineLatestStream.combine2(
            _bloc.community, _bloc.groups, (a, b) => [a, b]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingIndicator(),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text(S.of(context).general_stream_error),
            );
          }
          community = snapshot.data![0];

          timebankModel = snapshot.data![1].firstWhere(
            (model) =>
                isPrimaryTimebank(parentTimebankId: model.parentTimebankId),
            orElse: () => TimebankModel({}),
          );
          templist = [
            ...timebankModel.members,
            ...timebankModel.admins,
            ...timebankModel.organizers
          ];
          isUserJoined = widget.isSignedUser! &&
                  templist!
                      .contains(SevaCore.of(context).loggedInUser.sevaUserID)
              ? true
              : false;
          return FutureBuilder<UserModel>(
              future: widget.isSignedUser!
                  ? FirestoreManager.getUserForId(
                      sevaUserId: community!.created_by)
                  : Searches.getUserElastic(userId: community!.created_by!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingIndicator(),
                  );
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return Center(
                    child: Text(S.of(context).general_stream_error),
                  );
                }
                UserModel userModel = snapshot.data!;
                return ExplorePageViewHolder(
                  hideHeader: widget.isSignedUser!,
                  hideFooter: true,
                  hideSearchBar: true,
                  appBarTitle: community!.name,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.isSignedUser!)
                        CustomBackButton(
                          onBackPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: AspectRatio(
                          aspectRatio: 4 / 2,
                          child: Image.network(
                            community!.logo_url,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).part_of_sevax,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            community!.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 30),
                          SizedBox(
                            height: 50,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    "https://www.adobe.com/content/dam/cc/us/en/creative-cloud/photography/discover/landscape-photography/CODERED_B1_landscape_P2d_714x348.jpg.img.jpg",
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      userModel.fullname!,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      S.of(context).organizer,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                // CustomTextButton(
                                //   color: Colors.grey[300],
                                //   shape: RoundedRectangleBorder(
                                //     borderRadius: BorderRadius.circular(8),
                                //   ),
                                //   child: Padding(
                                //     padding: const EdgeInsets.all(12.0),
                                //     child: Text('Message'),
                                //   ),
                                //   onPressed: () {},
                                // ),
                                CustomTextButton(
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  shape: StadiumBorder(),
                                  child: Text(isUserJoined
                                      ? S.of(context).joined
                                      : S.of(context).request_to_join),
                                  onPressed: () {
                                    if (widget.isSignedUser! && !isUserJoined) {
                                      createEditCommunityBloc
                                          .selectCommunity(community!);
                                      createEditCommunityBloc.updateUserDetails(
                                          SevaCore.of(context).loggedInUser);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_context) => SevaCore(
                                            loggedInUser: SevaCore.of(context)
                                                .loggedInUser,
                                            child: OnBoardWithTimebank(
                                              user: SevaCore.of(context)
                                                  .loggedInUser,
                                              communityModel: community,
                                              isFromExplore: true,
                                              sevauserId: SevaCore.of(context)
                                                  .loggedInUser
                                                  .sevaUserID,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else if (!widget.isSignedUser!) {
                                      showSignInAlertMessage(
                                        context: context,
                                        message: S.of(context).sign_in_alert,
                                        //'Please Sign In/Sign up to access ${community.name}',
                                      );
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              S.of(context).location,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(community!.billing_address.city ?? ''),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              S.of(context).help_about_us,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              community!.about!,
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                      HideWidget(
                        hide: !widget.isSignedUser!,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: SponsorsWidget(
                            textColor: Theme.of(context).primaryColor,
                            sponsorsMode: SponsorsMode.ABOUT,
                            sponsors: timebankModel.sponsors,
                            isAdminVerified: GetUserVerified.verify(
                              userId: widget.isSignedUser!
                                  ? SevaCore.of(context)
                                      .loggedInUser
                                      .sevaUserID!
                                  : '',
                              creatorId: timebankModel.creatorId,
                              admins: timebankModel.admins,
                              organizers: timebankModel.organizers,
                            ),
                          ),
                        ),
                        secondChild: SizedBox.shrink(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: MemberAvatarListWithCount(
                          userIds: community!.members,
                          radius: 22,
                        ),
                      ),
                      StreamBuilder<List<ProjectModel>>(
                        stream: _bloc.events,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: LoadingIndicator(),
                            );
                          }

                          if (snapshot.hasError ||
                              snapshot.data == null ||
                              snapshot.data!.isEmpty) {
                            return Container();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  S.of(context).upcoming_events,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 330,
                                child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    var event = snapshot.data![index];
                                    return InkWell(
                                      onTap: () {
                                        if (!widget.isSignedUser!) {
                                          showSignInAlertMessage(
                                            context: context,
                                            message:
                                                S.of(context).sign_in_alert,
                                            // 'Please Sign In/Sign up to access ${event.name}'
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return ProjectRequests(
                                                  ComingFrom.Projects,
                                                  timebankId: event.timebankId!,
                                                  projectModel: event,
                                                  timebankModel: timebankModel,
                                                );
                                              },
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 250,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.network(
                                                event.photoUrl ??
                                                    defaultProjectImageURL,
                                                fit: BoxFit.cover,
                                                width: 250,
                                                height: 180,
                                              ),
                                              Text(
                                                event.address ?? '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                event.description!,
                                                maxLines: 2,
                                              ),
                                              SizedBox(height: 4),
                                              MemberAvatarListWithCount(
                                                userIds: event
                                                    .associatedmembers!.keys
                                                    .toList(),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                DateFormat('EEEE, d MMM h:mm a')
                                                    .format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                    event.startTime!,
                                                  ),
                                                ),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                      allGroupsUnderCommunity,
                      StreamBuilder<List<RequestModel>>(
                        stream: _bloc.requests,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: LoadingIndicator(),
                            );
                          }

                          if (snapshot.hasError ||
                              snapshot.data == null ||
                              snapshot.data!.isEmpty) {
                            return Container();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  S.of(context).latest_requests,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    var request = snapshot.data![index];
                                    return InkWell(
                                      onTap: () {
                                        if (!widget.isSignedUser!) {
                                          showSignInAlertMessage(
                                            context: context,
                                            message:
                                                S.of(context).sign_in_alert,
                                            // 'Please Sign In/Sign up to access ${request.title}'
                                          );
                                        } else if (widget.isSignedUser!) {
                                          //

                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return RequestDetailsAboutPage(
                                              requestItem: request,
                                              timebankModel: timebankModel,
                                              isAdmin: false,
                                              // communityModel: community,
                                            );
                                          }));
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 250,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.network(
                                                "https://www.adobe.com/content/dam/cc/us/en/creative-cloud/photography/discover/landscape-photography/CODERED_B1_landscape_P2d_714x348.jpg.img.jpg",
                                                fit: BoxFit.cover,
                                                width: 250,
                                                height: 180,
                                              ),
                                              Text(
                                                request.address ?? '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Text(request.title!),
                                              SizedBox(height: 4),
                                              MemberAvatarListWithCount(
                                                userIds: request.approvedUsers,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                DateFormat('EEEE, d MMM h:mm a')
                                                    .format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                    request!.requestStart!,
                                                  ),
                                                ),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              });
        },
      ),
    );
  }

  Widget get allGroupsUnderCommunity {
    return StreamBuilder<List<TimebankModel>>(
        stream: _bloc.groups,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error!.toString());
            return Text(S.of(context).general_stream_error);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (snapshot.data == null) {
            return Container();
          }
          List<TimebankModel> timabanksList =
              filterGroupsOfUser(snapshot.data!);
          if (timabanksList.isEmpty) {
            return Container();
            // Text(S.of(context).no_groups_found);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  S.of(context).groups,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: timabanksList.length,
                  itemBuilder: (context, index) => ShortGroupCard(
                    isSelected: false,
                    imageUrl: timabanksList[index].photoUrl ??
                        'https://img.freepik.com/free-vector/group-young-people-posing-photo_52683-18823.jpg?size=338&ext=jpg',
                    title: timabanksList[index].name,
                    membersCount: timabanksList[index].members.length ?? 0,
                    subtitle: '',
                    onTap: () {
                      if (!widget.isSignedUser!) {
                        showSignInAlertMessage(
                            context: context,
                            message: S.of(context).sign_in_alert);
                        // 'Please Sign In/Sign up to access ${timabanksList[index].name}');
                      } else if (widget.isSignedUser! &&
                          isUserJoined &&
                          community!.id ==
                              SevaCore.of(context)
                                  .loggedInUser
                                  .currentCommunity) {
                        try {
                          Provider.of<HomePageBaseBloc>(context, listen: false)
                              .changeTimebank(timabanksList[index]);
                        } on Exception catch (e) {
                          log(e.toString());
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider<UserDataBloc>(
                              bloc: BlocProvider.of<UserDataBloc>(context),
                              child: TabarView(
                                userModel: SevaCore.of(context).loggedInUser,
                                timebankModel: timabanksList[index],
                              ),
                            ),
                          ),
                        ).then((_) {
                          try {
                            Provider.of<HomePageBaseBloc>(context,
                                    listen: false)
                                .switchToPreviousTimebank();
                          } on Exception catch (e) {
                            log(e.toString());
                          }
                        });
                      } else if (SevaCore.of(context).loggedInUser != null &&
                          isUserJoined) {
                        switchCommunity(message: S.of(context).event);
                      } else if (SevaCore.of(context).loggedInUser != null &&
                          !isUserJoined) {
                        showAlertMessage(message: timabanksList[index].name);
                      }
                    },
                    sponsoredWidget: timabanksList[index].sponsored
                        ? Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3, right: 3),
                              child: Image.asset(
                                'images/icons/verified.png',
                                color: Colors.orange,
                                height: 12,
                                width: 12,
                              ),
                            ))
                        : Offstage(),
                  ),
                ),
              ),
            ],
          );
        });
  }

  void showAlertMessage({String? message}) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            content: Text(S
                .of(context)
                .join_community_alert
                .replaceAll(" **CommunityName", '')),
            actions: [
              CustomTextButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(S.of(context).ok),
              )
            ],
          );
        });
  }

  List<TimebankModel> filterGroupsOfUser(
    List<TimebankModel> timebanks,
  ) {
    return List<TimebankModel>.from(timebanks.where(
      (element) => element.parentTimebankId != FlavorConfig.values.timebankId,
    ));
  }

  void switchCommunity({String? message}) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            content: Text(S.of(context).switch_community),
            actions: [
              CustomElevatedButton(
                color: Colors.orange,
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: 2.0,
                textColor: Colors.white,
                onPressed: () {
                  _profileBloc?.setDefaultCommunity(
                    SevaCore.of(context).loggedInUser.email!,
                    community!,
                    context,
                  );
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop();
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SwitchTimebank(content: ''),
                    ),
                  );
                },
                child: Text(
                  S.of(context).switch_timebank,
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        });
  }
}

void showSignInAlertMessage({BuildContext? context, String? message}) {
  showDialog(
    context: context!,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(S.of(context).access_not_available),
        content: Text(message!),
        actions: [
          CustomTextButton(
            shape: StadiumBorder(),
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              S.of(context).cancel,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Europa',
              ),
            ),
          ),
          CustomTextButton(
            shape: StadiumBorder(),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            child: Text(
              S.of(context).continue_to_signin,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Europa',
              ),
            ),
          ),
        ],
      );
    },
  );
}
