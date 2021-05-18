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
import 'package:sevaexchange/new_baseline/services/firestore_service/firestore_service.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_community_details_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page_view_holder.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/members_avatar_list_with_count.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/timebank/widgets/community_about_widget.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/user_profile_bloc.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/invitation/OnboardWithTimebankCode.dart';
import 'package:sevaexchange/views/login/login_page.dart';
import 'package:sevaexchange/views/requests/project_request.dart';
import 'package:sevaexchange/views/switch_timebank.dart';
import 'package:sevaexchange/views/timebank_content_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class ExploreCommunityDetails extends StatefulWidget {
  final String communityId;
  final bool isSignedUser;

  const ExploreCommunityDetails(
      {Key key, this.communityId, @required this.isSignedUser})
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
  List<String> templist;
  UserProfileBloc _profileBloc;
  CommunityModel community;

  @override
  void initState() {
    _profileBloc = UserProfileBloc();

    _bloc.init(widget.communityId, widget.isSignedUser);
    setState(() {});
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
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Text(S.of(context).general_stream_error),
            );
          }
          community = snapshot.data[0];
          timebankModel = _bloc.primaryTimebankModel();
          templist = [
            ...timebankModel.members,
            ...timebankModel.admins,
            ...timebankModel.organizers
          ];
          isUserJoined = Provider.of<UserModel>(context) != null &&
                  templist
                      .contains(SevaCore.of(context).loggedInUser.sevaUserID)
              ? true
              : false;
          return FutureBuilder<UserModel>(
              future: widget.isSignedUser
                  ? FirestoreManager.getUserForId(
                      sevaUserId: community.created_by)
                  : Searches.getUserElastic(userId: community.created_by),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return Center(
                    child: Text(S.of(context).general_stream_error),
                  );
                }
                UserModel userModel = snapshot.data;
                return ExplorePageViewHolder(
                  hideHeader: widget.isSignedUser,
                  hideFooter: true,
                  hideSearchBar: true,
                  appBarTitle: community.name,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: AspectRatio(
                          aspectRatio: 4 / 2,
                          child: Image.network(
                            community.logo_url,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Part of SevaX Global Network of Communities',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            community.name,
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
                                      userModel.fullname,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    SizedBox(height: 8),
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
                                // FlatButton(
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
                                FlatButton(
                                  color: Colors.grey[300],
                                  textColor: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Text(isUserJoined
                                        ? S.of(context).joined
                                        : 'Request to join'),
                                  ),
                                  onPressed: () {
                                    if (Provider.of<UserModel>(context,
                                                listen: false) !=
                                            null &&
                                        !isUserJoined) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OnBoardWithTimebank(
                                            user: SevaCore.of(context)
                                                .loggedInUser,
                                            communityModel: community,
                                            isFromExplore: true,
                                            sevauserId: SevaCore.of(context)
                                                .loggedInUser
                                                .sevaUserID,
                                          ),
                                        ),
                                      );
                                    } else {
                                      showSignInAlertMessage(
                                        context: context,
                                        message:
                                            'Please Sign In/Sign up to access ${community.name}',
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
                            child: Text(community.billing_address.city ?? ''),
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
                              community.about,
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: MemberAvatarListWithCount(
                          userIds: community.members,
                          radius: 22,
                        ),
                      ),
                      FutureBuilder<List<ProjectModel>>(
                        future: FirestoreManager.getAllPublicProjects(
                            timebankid: timebankModel.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError ||
                              snapshot.data == null ||
                              snapshot.data.isEmpty) {
                            return Container();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  "Upcoming Events",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  itemCount: snapshot.data.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    var event = snapshot.data[index];
                                    return InkWell(
                                      onTap: () {
                                        if (Provider.of<UserModel>(context,
                                                listen: false) !=
                                            null) {
                                          showSignInAlertMessage(
                                              context: context,
                                              message:
                                                  'Please Sign In/Sign up to access ${event.name}');
                                        } else if (Provider.of<UserModel>(
                                                    context,
                                                    listen: false) !=
                                                null &&
                                            isUserJoined &&
                                            community.id ==
                                                SevaCore.of(context)
                                                    .loggedInUser
                                                    .currentCommunity) {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ProjectRequests(
                                              ComingFrom.Projects,
                                              timebankId: event.timebankId,
                                              projectModel: event,
                                              timebankModel: timebankModel,
                                            );
                                          }));
                                        } else if (Provider.of<UserModel>(
                                                    context,
                                                    listen: false) !=
                                                null &&
                                            isUserJoined) {
                                          switchCommunity(
                                            message: 'Event',
                                          );
                                        } else if (Provider.of<UserModel>(
                                                    context,
                                                    listen: false) !=
                                                null &&
                                            !isUserJoined) {
                                          showAlertMessage(message: event.name);
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
                                                event.description,
                                              ),
                                              SizedBox(height: 4),
                                              MemberAvatarListWithCount(
                                                userIds: event
                                                    .associatedmembers.keys
                                                    .toList(),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                DateFormat('EEEE, d MMM h:mm a')
                                                    .format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                    event.startTime,
                                                  ),
                                                ),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .accentColor,
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
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError ||
                              snapshot.data == null ||
                              snapshot.data.isEmpty) {
                            return Container();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  "Latest Requests",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  itemCount: snapshot.data.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    var request = snapshot.data[index];
                                    return InkWell(
                                      onTap: () {
                                        if (Provider.of<UserModel>(context,
                                                listen: false) !=
                                            null) {
                                          showSignInAlertMessage(
                                              context: context,
                                              message:
                                                  'Please Sign In/Sign up to access ${request.title}');
                                        } else if (Provider.of<UserModel>(
                                                    context,
                                                    listen: false) !=
                                                null &&
                                            isUserJoined &&
                                            community.id ==
                                                SevaCore.of(context)
                                                    .loggedInUser
                                                    .currentCommunity) {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return RequestDetailsAboutPage(
                                              requestItem: request,
                                              timebankModel: timebankModel,
                                              isAdmin: false,
                                              //communityModel: BlocProvider.of<HomeDashBoardBloc>(context).selectedCommunityModel,
                                            );
                                          }));
                                        } else if (Provider.of<UserModel>(
                                                    context,
                                                    listen: false) !=
                                                null &&
                                            isUserJoined) {
                                          switchCommunity(
                                            message: S.of(context).request,
                                          );
                                        } else if (Provider.of<UserModel>(
                                                    context,
                                                    listen: false) !=
                                                null &&
                                            !isUserJoined) {
                                          showAlertMessage(
                                              message: request.title);
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
                                              Text(request.title),
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
                                                    request.requestStart,
                                                  ),
                                                ),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .accentColor,
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
            log(snapshot.error);
            return Text(S.of(context).general_stream_error);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (snapshot.data == null) {
            return Container();
          }
          List<TimebankModel> timabanksList = filterGroupsOfUser(snapshot.data);
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
                      if (!widget.isSignedUser) {
                        showSignInAlertMessage(
                            context: context,
                            message:
                                'Please Sign In/Sign up to access ${timabanksList[index].name}');
                      } else if (widget.isSignedUser &&
                          isUserJoined &&
                          community.id ==
                              SevaCore.of(context)
                                  .loggedInUser
                                  .currentCommunity) {
                        try {
                          Provider.of<HomePageBloc>(context, listen: false)
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
                            Provider.of<HomePageBloc>(context, listen: false)
                                .switchToPreviousTimebank();
                          } on Exception catch (e) {
                            log(e.toString());
                          }
                        });
                      } else if (SevaCore.of(context).loggedInUser != null &&
                          isUserJoined) {
                        switchCommunity(message: 'Event');
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

  void showAlertMessage({String message}) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            content: Text(
                'This action is available only to the members of this community. You need to request to join the Seva Community to view this ' +
                    message +
                    '.'),
            actions: [
              RaisedButton(
                color: Colors.red,
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

  void switchCommunity({String message}) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            content: Text('Switch Community to view this ' + message + '.'),
            actions: [
              RaisedButton(
                color: Colors.orange,
                onPressed: () {
                  _profileBloc.setDefaultCommunity(
                      SevaCore.of(context).loggedInUser.email,
                      community,
                      context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SwitchTimebank(),
                    ),
                  );
                },
                child: Text(S.of(context).switch_timebank),
              )
            ],
          );
        });
  }
}

void showSignInAlertMessage({BuildContext context, String message}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('Access not available'),
        content: Text(message),
        actions: [
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Colors.deepOrange),
              )),
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Text(
                'Continue to Sign in',
                style: TextStyle(color: FlavorConfig.values.theme.primaryColor),
              )),
        ],
      );
    },
  );
}
