import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/search/widgets/project_card.dart';
import 'package:sevaexchange/utils/data_managers/blocs/user_profile_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/invitation/OnboardWithTimebankCode.dart';
import 'package:sevaexchange/views/onboarding/findcommunitiesview.dart';
import 'package:sevaexchange/views/switch_timebank.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../../../../flavor_config.dart';

class CommunityAbout extends StatefulWidget {
  final CommunityModel communityModel;
  final UserModel userModel;
  final CompareUserStatus joinStatus;

  CommunityAbout({
    required this.communityModel,
    required this.userModel,
    required this.joinStatus,
  });

  @override
  _CommunityAboutState createState() => _CommunityAboutState();
}

class _CommunityAboutState extends State<CommunityAbout>
    with SingleTickerProviderStateMixin {
  ScrollController? _scrollController;
  TabController? controller;
  bool isTitleVisible = false;
  bool dataLoaded = false;
  List<String> _tabsNames = [];
  TimebankModel? timebankModel;
  List<String> iconPath = [
    'images/icons/about.png',
    'images/icons/projects.png',
    'images/icons/members.png'
  ];
  UserProfileBloc? _profileBloc;

  @override
  void initState() {
    _profileBloc = UserProfileBloc();

    var templist = [
      ...widget.communityModel.members,
      ...widget.communityModel.organizers,
      ...widget.communityModel.admins,
    ];
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => getData());
    }

    controller = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController!.addListener(() {
      if (_scrollController!.offset > 260 && !isTitleVisible) {
        isTitleVisible = true;
        setState(() {});
      }
      if (_scrollController!.offset < 250 && isTitleVisible) {
        isTitleVisible = false;
        setState(() {});
      }
    });
    super.initState();
  }

  void getData() async {
    await FirestoreManager.getTimeBankForId(
            timebankId: widget.communityModel.primary_timebank)
        .then((onValue) {
      timebankModel = onValue;
      if (this.mounted)
        setState(() {
          dataLoaded = true;
        });
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tabsNames = [
      S.of(context).about,
      S.of(context).projects,
      S.of(context).groups,
    ];

    return Scaffold(
      body: !dataLoaded
          ? LoadingIndicator()
          : Column(
              children: [
                Expanded(
                  child: NestedScrollView(
                    controller: _scrollController,
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverOverlapAbsorber(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context),
                          sliver: SliverAppBar(
                            title: Container(),
                            titleSpacing: 10,
                            leading: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black),
                              ),
                              // width: 30,
                              child: IconButton(
                                color: Colors.black,
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 20,
                                ),
                              ),
                            ),
                            leadingWidth: 37,
                            backgroundColor: Colors.white,
                            pinned: true,
                            expandedHeight: timebankModel!.sponsors != null &&
                                    timebankModel!.sponsors.length > 0
                                ? 250 + timebankModel!.sponsors.length * 100.0
                                : 270,
                            flexibleSpace: FlexibleSpaceBar(
                              collapseMode: CollapseMode.pin,
                              background: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: CachedNetworkImage(
                                      imageUrl: timebankModel!.photoUrl ?? ' ',
                                      fit: BoxFit.cover,
                                      height: 200,
                                      errorWidget: (context, url, error) =>
                                          Container(
                                              height: 80,
                                              child: Center(
                                                child: Text(
                                                  S
                                                      .of(context)
                                                      .no_image_available,
                                                  textAlign: TextAlign.center,
                                                ),
                                              )),
                                      placeholder: (context, url) {
                                        return LoadingIndicator();
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, top: 5),
                                    child: Text(
                                      timebankModel!.name ?? " ",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Europa',
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  // Offstage(
                                  //   offstage: !isPrimaryTimebank(
                                  //       parentTimebankId:
                                  //           timebankModel.parentTimebankId),
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.only(left: 10),
                                  //     child: SponsorsWidget(
                                  //       timebankModel: timebankModel,
                                  //       sponsorsMode: SponsorsMode.ABOUT,
                                  //       //  textColor: Colors.black,
                                  //       //textSize: 22,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            forceElevated: false,
                            bottom: TabBar(
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelStyle:
                                  TextStyle(color: Colors.grey),
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              indicatorColor: Theme.of(context).primaryColor,
                              tabs: List.generate(
                                _tabsNames.length,
                                (index) => Tab(
                                  child: Row(
                                    children: [
                                      Image.asset(iconPath[index]),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(_tabsNames[index])
                                    ],
                                  ),
                                ),
                              ),
                              controller: controller,
                              isScrollable: false,
                              unselectedLabelColor: Colors.black,
                            ),
                          ),
                        ),
                      ];
                    },
                    body: SafeArea(
                      minimum: EdgeInsets.only(top: 114),
                      child: TabBarView(
                        controller: controller,
                        children: <Widget>[
                          AboutUs,
                          allProjectsUnderCommunity,
                          allGroupsUnderCommunity,
                        ],
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (contexts) => OnBoardWithTimebank(
                          communityModel: widget.communityModel,
                          sevauserId: widget.userModel.sevaUserID,
                          user: widget.userModel,
                        ),
                      ),
                    );
                  },
                  child: Container(
                      height: 50,
                      width: double.infinity,
                      color: Theme.of(context).primaryColor,
                      child: Center(
                          child: Text(
                        S.of(context).join_seva_community,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ))),
                )
              ],
            ),
    );
  }

  Widget get VolunteersWidget {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).members,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor)),
        SizedBox(
          height: 7,
        ),
        Text(
          '${timebankModel!.members.length} ${S.of(context).members}',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Europa',
          ),
        ),
      ],
    );
  }

  Widget get organizerWidget {
    return FutureBuilder<UserModel>(
        future: getUserForId(
          sevaUserId: widget.communityModel.created_by,
        ),
        builder: (context, snapshot) {
          log("........>>>>" + timebankModel!.emailId ??
              widget.communityModel.primary_email + "<<<<<<<<<<<");

          if (snapshot.hasError) {
            log("........>>>>" + timebankModel!.emailId ??
                widget.communityModel.primary_email);
            return Container();
          }

          if (!snapshot.hasData) {
            return LoadingIndicator();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.of(context).owner,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor)),
              SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 75,
                      height: 70,
                      child: FadeInImage.assetNetwork(
                        fit: BoxFit.fill,
                        placeholder: defaultUserImageURL,
                        image: snapshot.data!.photoURL ?? defaultUserImageURL,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(snapshot.data!.fullname ?? "",
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Europa',
                              color: Colors.black87)),
                      SizedBox(
                        height: 7,
                      ),
//                    InkWell(
//                      onTap:

//                          () {}, //TODO navigate to messaing view on tapping of this text
//                      child: Text(
//                        'Message',
//                        style: TextStyle(
//                            fontSize: 16,
//                            fontFamily: 'Europa',
//                            fontWeight: FontWeight.w500,
//                            color: Theme.of(context).primaryColor),
//                      ),
//                    ),
                    ],
                  )
                ],
              ),
            ],
          );
        });
  }

  Widget get AboutUs {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
          ),
          Text(S.of(context).help_about_us,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor)),
          SizedBox(height: 15),
          RichText(
            text: TextSpan(
              style: TextStyle(color: HexColor("#4A4A4A")),
              children: [
                TextSpan(
                  text: widget.communityModel.about,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Europa',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Offstage(
              offstage: timebankModel!.address == null ||
                  timebankModel!.address.isEmpty,
              child: LocationWidget),
          SizedBox(
            height: 10,
          ),
          VolunteersWidget,
          SizedBox(
            height: 10,
          ),
          organizerWidget,
        ],
      ),
    );
  }

  Widget get LocationWidget {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).location,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor)),
        SizedBox(
          height: 7,
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(color: HexColor("#4A4A4A")),
            children: [
              TextSpan(
                text: timebankModel!.address,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Europa',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget get allGroupsUnderCommunity {
    return FutureBuilder<List<TimebankModel>>(
        future: FirestoreManager.getAllTheGroups(widget.communityModel.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error! as String);
            return Text(S.of(context).general_stream_error);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (snapshot.data == null) {
            return Center(
              child: Text(
                S.of(context).no_groups_found,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }
          List<TimebankModel> timabanksList =
              filterGroupsOfUser(snapshot.data as List<TimebankModel>);
          if (timabanksList.isEmpty) {
            return Container(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Image.asset(
                        'images/icons/empty_feed.png',
                        height: 160,
                        width: 214,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        S.of(context).no_groups_found,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
            // Text(S.of(context).no_groups_found);
          }
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: timabanksList.length,
            itemBuilder: (context, index) => ShortGroupCard(
              isSelected: false,
              imageUrl: timabanksList[index].photoUrl ??
                  'https://img.freepik.com/free-vector/group-young-people-posing-photo_52683-18823.jpg?size=338&ext=jpg',
              title: timabanksList[index].name,
              membersCount: (timabanksList[index].members as int?) ?? 0,
              subtitle: '',
              onTap: () {
                if (widget.joinStatus == CompareUserStatus.JOINED) {
                  switchCommunity(message: S.of(context).groups.toLowerCase());
                } else {
                  showAlertMessage(message: S.of(context).groups.toLowerCase());
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
          );
        });
  }

  void switchCommunity({String? message}) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            content: Text(S.of(context).please_switch_to_access + message!),
            actions: [
              CustomElevatedButton(
                color: Colors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                textColor: Colors.white,
                onPressed: () {
                  _profileBloc!.setDefaultCommunity(
                      widget.userModel.email!, widget.communityModel, context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SwitchTimebank(content: widget.communityModel.id),
                    ),
                  );
                },
                child: Text(S.of(context).switch_timebank),
              )
            ],
          );
        });
  }

  void showAlertMessage({String? message}) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            content: Text(S.of(context).please_join_seva_to_access + message!),
            actions: [
              CustomElevatedButton(
                color: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                textColor: Colors.white,
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(S.of(context).ok),
              )
            ],
          );
        });
  }

  Widget get allProjectsUnderCommunity {
    return FutureBuilder<List<ProjectModel>>(
        future: FirestoreManager.getAllPublicProjects(
            timebankid: widget.communityModel.primary_timebank),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error as String);
            return Text(S.of(context).general_stream_error);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (snapshot.data == null) {
            return Center(
              child: Text(
                S.of(context).no_events_available,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }
          List<ProjectModel> projectsList = snapshot.data as List<ProjectModel>;
          if (projectsList.isEmpty) {
            return Container(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Image.asset(
                        'images/icons/empty_feed.png',
                        height: 160,
                        width: 214,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        S.of(context).no_events_available,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 10),
            itemCount: projectsList.length,
            itemBuilder: (context, index) {
              ProjectModel project = snapshot.data![index];
              int totalTask = project.completedRequests != null &&
                      project.pendingRequests != null
                  ? project.pendingRequests!.length +
                      project.completedRequests!.length
                  : 0;
              return ProjectsCard(
                  timestamp: project.createdAt!,
                  startTime: project.startTime!,
                  endTime: project.endTime!,
                  title: project.name!,
                  description: project.description!,
                  photoUrl: project.photoUrl!,
                  location: project.address!,
                  tasks: totalTask,
                  pendingTask: project.pendingRequests!.length!,
                  onTap: () {
                    if (widget.joinStatus == CompareUserStatus.JOINED) {
                      switchCommunity(message: S.of(context).event);
                    } else {
                      showAlertMessage(
                          message: S.of(context).projects.toLowerCase());
                    }
                  });
            },
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
}

class ShortGroupCard extends StatelessWidget {
  const ShortGroupCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.membersCount,
    required this.onTap,
    this.padding,
    this.sponsoredWidget,
    this.isSelected = false,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final int membersCount;
  final bool isSelected;
  final EdgeInsetsGeometry? padding;
  final VoidCallback onTap;
  final Widget? sponsoredWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFECEDF1) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      imageUrl,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  sponsoredWidget!,
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  membersCount != null && membersCount != 0
                      ? Text(
                          '$membersCount ${S.of(context).members}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        )
                      : Text(
                          subtitle ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
