import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/widgets/no_group_placeholder.dart';
import 'package:sevaexchange/ui/screens/home_page/widgets/timebank_card.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/tasks/completed_list.dart';
import 'package:sevaexchange/views/tasks/my_tasks_list.dart';
import 'package:sevaexchange/views/tasks/notAccepted_tasks.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';

import '../../../../flavor_config.dart';
import '../../../../labels.dart';

class TimebankHomePage extends StatefulWidget {
  final SelectedCommuntityGroup selectedCommuntityGroup;
  final TimebankModel primaryTimebankModel;

  const TimebankHomePage(
      {Key? key,
      required this.selectedCommuntityGroup,
      required this.primaryTimebankModel})
      : super(key: key);
  @override
  _TimebankHomePageState createState() => _TimebankHomePageState();
}

class _TimebankHomePageState extends State<TimebankHomePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  HomeDashBoardBloc? _homeDashBoardBloc;
  TabController? controller;
  ScrollController? _scrollController;
  bool isTitleVisible = false;

  @override
  void initState() {
    controller = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController?.addListener(() {
      if ((_scrollController?.offset ?? 0) > 260 && !isTitleVisible) {
        isTitleVisible = true;
        setState(() {});
      }
      if ((_scrollController?.offset ?? 0) < 250 && isTitleVisible) {
        isTitleVisible = false;
        setState(() {});
      }
    });
    _homeDashBoardBloc = BlocProvider.of<HomeDashBoardBloc>(context);
    Provider.of<HomePageBaseBloc>(context, listen: false)
        .changeTimebank(widget.primaryTimebankModel);
    super.initState();
  }

  @override
  void dispose() {
    _homeDashBoardBloc?.dispose();
    controller?.dispose();
    super.dispose();
  }

  void navigateToCreateGroup() {
    if (widget.primaryTimebankModel.id == FlavorConfig.values.timebankId &&
        !isAccessAvailable(widget.primaryTimebankModel,
            SevaCore.of(context).loggedInUser.sevaUserID ?? '')) {
      showAdminAccessMessage(context: context);
    } else {
      createEditCommunityBloc
          .updateUserDetails(SevaCore.of(context).loggedInUser);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimebankCreate(
            timebankId: SevaCore.of(context).loggedInUser.currentTimebank ?? '',
            communityCreatorId:
                _homeDashBoardBloc?.selectedCommunityModel!.created_by ?? '',
          ),
        ),
      );
    }
  }

  // void navigateToCreateProjectGroup() {
  //   createEditCommunityBloc
  //       .updateUserDetails(SevaCore.of(context).loggedInUser);
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => TimeBankProjectsView(
  //         timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final user = BlocProvider.of<UserDataBloc>(context);
    final covidcheck = json.decode(AppConfig.remoteConfig!.getString('covid'));
    super.build(context);
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              title: Text(
                S.of(context).your_tasks,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isTitleVisible ? Colors.black : Colors.transparent,
                ),
              ),
              titleSpacing: 20,
              backgroundColor: Colors.white,
              pinned: true,
              expandedHeight: covidcheck['show'] ? 480.0 : 370,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ButtonTheme(
                          minWidth: 110.0,
                          height: 50.0,
                          buttonColor: Color.fromRGBO(234, 135, 137, 1.0),
                          child: Stack(
                            fit: StackFit.loose,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  right: 10,
                                ),
                                child: CustomTextButton(
                                  onPressed: () {},
                                  child: Text(
                                    S.of(context).your_groups,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // will be positioned in the top right of the container
                                top: 0,
                                right: -20,
                                child: Container(
                                  padding: EdgeInsets.only(left: 4, right: 4),
                                  child: infoButton(
                                    context: context,
                                    key: GlobalKey(),
                                    type: InfoType.GROUPS,
                                    // text:
                                    //     infoDetails['groupsInfo'] ?? description,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TransactionLimitCheck(
                          comingFrom: ComingFrom.Home,
                          timebankId: widget.primaryTimebankModel.id,
                          isSoftDeleteRequested:
                              widget.primaryTimebankModel.requestedSoftDelete,
                          child: ConfigurationCheck(
                            actionType: 'create_group',
                            role: MemberType.CREATOR,
                            child: IconButton(
                              icon: Icon(Icons.add_circle),
                              color: Theme.of(context).primaryColor,
                              onPressed: widget.primaryTimebankModel.protected
                                  ? isAccessAvailable(
                                          widget.primaryTimebankModel,
                                          SevaCore.of(context)
                                                  .loggedInUser
                                                  .sevaUserID ??
                                              '')
                                      ? navigateToCreateGroup
                                      : showProtctedTImebankDialog
                                  : navigateToCreateGroup,
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    Container(
                      height: 210,
                      child: getTimebanks(user!),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 10,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        S.of(context).your_tasks,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              forceElevated: false,
              bottom: TabBar(
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                indicatorColor: Theme.of(context).primaryColor,
                tabs: [
                  Tab(
                    child: Text(S.of(context).to_do),
                  ),
                  Tab(
                    child: Text(S.of(context).pending),
                  ),
                  Tab(
                    child: Text(S.of(context).completed),
                  ),
                ],
                controller: controller,
                isScrollable: false,
                unselectedLabelColor: Colors.black,
              ),
            ),
          ),
        ];
      },
      body: SafeArea(
        minimum: EdgeInsets.only(top: 104),
        child: TabBarView(
          controller: controller,
          children: <Widget>[
            MyTaskList(
              email: SevaCore.of(context).loggedInUser.email!,
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID ?? '',
            ),
            NotAcceptedTaskList(),
            CompletedList()
          ],
        ),
      ),
    );
  }

  void showProtctedTImebankDialog() {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(S.of(context).protected_timebank),
          content: Text(S.of(context).protected_timebank_group_creation_error),
          actionsPadding: EdgeInsets.only(right: 20),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            CustomTextButton(
              shape: StadiumBorder(),
              color: Theme.of(context).colorScheme.secondary,
              textColor: Colors.white,
              child: Text(
                S.of(context).close,
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Europa',
                ),
              ),
              onPressed: () {
                Navigator.of(_context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget getTimebanks(UserDataBloc user) {
    if (widget.selectedCommuntityGroup.timebanks.length <= 1) {
      return NoGroupPlaceHolder(navigateToCreateGroup: navigateToCreateGroup);
    }
    return FadeAnimation(
      0,
      Container(
        height: MediaQuery.of(context).size.height * 0.25,
        child: ListView.builder(
          itemCount: widget.selectedCommuntityGroup.timebanks.length,
          itemBuilder: (context, index) {
            if (widget.selectedCommuntityGroup.timebanks[index].id !=
                widget.selectedCommuntityGroup.currentCommunity
                    .primary_timebank) {
              return TimeBankCard(
                user: user,
                timebank: widget.selectedCommuntityGroup.timebanks[index],
              );
            }
            return Container();
          },
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 12),
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  void showGroupsWebPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig!.getString("links_${S.of(context).localeName}"),
    );
    navigateToWebView(
      aboutMode: AboutMode(
        title: S.of(context).groups_help_text,
        urlToHit: dynamicLinks['groupsInfoLink'],
      ),
      context: context,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
