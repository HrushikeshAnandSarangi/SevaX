import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/community/communitycreate.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/invitation/OnboardWithTimebankCode.dart';

class FindCommunitiesView extends StatefulWidget {
  final bool keepOnBackPress;
  final UserModel loggedInUser;
  final bool showBackBtn;

  FindCommunitiesView(
      {@required this.keepOnBackPress,
      @required this.loggedInUser,
      @required this.showBackBtn});

  @override
  State<StatefulWidget> createState() {
    return FindCommunitiesViewState();
  }
}

enum CompareUserStatus { JOINED, REQUESTED, REJECTED, JOIN }

class FindCommunitiesViewState extends State<FindCommunitiesView> {
  final TextEditingController searchTextController =
      new TextEditingController();
  static const String JOIN = "Join";
  static const String JOINED = "Joined";
  @override
  void initState() {
    super.initState();
    String _searchText = "";
    final _textUpdates = StreamController<String>();
    searchTextController
        .addListener(() => _textUpdates.add(searchTextController.text));
    Observable(_textUpdates.stream)
        .debounceTime(Duration(milliseconds: 400))
        .forEach((s) {
      if (s.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        communityBloc.fetchCommunities(s);
        setState(() {
          _searchText = s;
        });
      }
    });
  }

  @override
  void dispose() {
    communityBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showBachBtn = widget.showBackBtn;
    return MaterialApp(
      title: AppConfig.appName,
      theme: FlavorConfig.values.theme,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          // automaticallyImplyLeading: widget.keepOnBackPress,
          automaticallyImplyLeading: false,
          elevation: 0.5,

          leading: showBachBtn
              ? BackButton(
                  onPressed: () => Navigator.pop(context),
                )
              : Offstage(),
          title: Text(
            'Find your Timebank',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: searchTeams(),
      ),
    ); // );
  }

  Widget searchTeams() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        ),
        Text(
          'Looking for an existing timebank to join',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        ),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: searchTextController,
          decoration: InputDecoration(
              suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    searchTextController.clear();
                  }),
              hasFloatingPlaceholder: false,
              alignLabelWithHint: true,
              isDense: true,
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey,
              ),
              contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
              filled: true,
              fillColor: Colors.grey[300],
              focusedBorder: OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.white),
                borderRadius: new BorderRadius.circular(25.7),
              ),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: new BorderRadius.circular(25.7)),
              hintText: 'Type your timebank name. Ex: Alaska (min 5 char)',
              hintStyle: TextStyle(color: Colors.black45, fontSize: 14)),
        ),
        SizedBox(height: 20),
        // buildList(),
        Expanded(child: buildList()),
        // This container holds the align
        createCommunity(),
      ]),
    );
  }

  Widget buildList() {
    if (widget == null ||
        searchTextController == null ||
        searchTextController.text == null) {
      return Container();
    }

    if (searchTextController.text.trim().length < 3) {
      print('Search requires minimum 3 characters');
      return Column(
        children: <Widget>[
          getEmptyWidget('Users', 'Search requires minimum 3 characters'),
        ],
      );
    }
    // ListView contains a group of widgets that scroll inside the drawer
    return StreamBuilder<List<CommunityModel>>(
        stream: SearchManager.searchCommunity(
          queryString: searchTextController.text,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.data.length != 0) {
                List<CommunityModel> communityList = snapshot.data;
                return Padding(
                    padding: EdgeInsets.only(left: 0, right: 0, top: 12.0),
                    child: ListView.builder(
                        itemCount: communityList.length,
                        itemBuilder: (BuildContext context, int index) {
                          CompareUserStatus status;

                          status = _compareUserStatus(communityList[index],
                              widget.loggedInUser.sevaUserID);

                          return ListTile(
                            onTap: goToNext(snapshot.data),
                            title: Text(communityList[index].name,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700)),
                            subtitle: FutureBuilder(
                              future: getUserForId(
                                  sevaUserId: communityList[index].created_by),
                              builder: (BuildContext context,
                                  AsyncSnapshot<UserModel> snapshot) {
                                if (snapshot.hasError) {
                                  return Text(
                                    "Not found",
                                  );
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text("...");
                                } else if (snapshot.hasData) {
                                  return Text(
                                    "Created by " + snapshot.data.fullname,
                                  );
                                } else {
                                  return Text(
                                    "Community",
                                  );
                                }
                              },
                            ),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: <
                                    Widget>[
                              RaisedButton(
                                onPressed: status == CompareUserStatus.JOIN
                                    ? () {
                                        var communityModel =
                                            communityList[index];
                                        createEditCommunityBloc
                                            .selectCommunity(communityModel);
                                        createEditCommunityBloc
                                            .updateUserDetails(
                                                SevaCore.of(context)
                                                    .loggedInUser);
                                        // snapshot.data.communities[index].

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (contexts) =>
                                                OnBoardWithTimebank(
                                                    communityModel:
                                                        communityModel,
                                                    sevauserId: widget
                                                        .loggedInUser
                                                        .sevaUserID),
                                          ),
                                        );
                                        print('clicked ${communityModel.id}');
                                      }
                                    : null,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Text(
                                          getUserTimeBankStatusTitle(status) ??
                                              ""),
                                    ),
                                  ],
                                ),
                                color: Theme.of(context).accentColor,
                                textColor: FlavorConfig.values.buttonTextColor,
                                shape: StadiumBorder(),
                              )
                            ]),
                          );
                        }));
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 100, horizontal: 60),
                  child: Center(
                    child: Text("No timebanks found",
                        style: TextStyle(fontFamily: "Europa", fontSize: 14)),
                  ),
                );
              }
            }
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          /*else if(snapshot.data==null){
            return Expanded(
              child: Center(
                child: Text('No Timebank found'),
              ),
            );
          }*/
          return Text("");
        });
  }

  String getUserTimeBankStatusTitle(CompareUserStatus status) {
    switch (status) {
      case CompareUserStatus.JOIN:
        return JOIN;

      case CompareUserStatus.JOINED:
        return JOINED;

      default:
        return JOIN;
    }
  }

  CompareUserStatus _compareUserStatus(
    CommunityModel communityModel,
    String seveaUserId,
  ) {
    if (communityModel.members.contains(widget.loggedInUser.sevaUserID)) {
      print('u r joined user');
      return CompareUserStatus.JOINED;
    } else if (communityModel.admins.contains(widget.loggedInUser.sevaUserID)) {
      print('u rrr joined user');

      return CompareUserStatus.JOINED;
    } else {
      print('u r not joined user');

      return CompareUserStatus.JOIN;
    }
  }

  Widget getEmptyWidget(String title, String notFoundValue) {
    return Center(
      child: Text(
        notFoundValue,
        overflow: TextOverflow.ellipsis,
        // style: sectionHeadingStyle,
      ),
    );
  }

  TextStyle get sectionHeadingStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12.5,
      color: Colors.black,
    );
  }

  TextStyle get sectionTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.grey,
    );
  }

  Widget createCommunity() {
    return Container(
      // This align moves the children to the bottom
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        // This container holds all the children that will be aligned
        // on the bottom and should not scroll with the above ListView
        child: Container(
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Text(
                  'Create a Timebank',
                  style: Theme.of(context).primaryTextTheme.button,
                ),
                onPressed: () {
                  createEditCommunityBloc
                      .updateUserDetails(SevaCore.of(context).loggedInUser);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context1) => SevaCore(
                        loggedInUser: SevaCore.of(context).loggedInUser,
                        child: CreateEditCommunityView(
                          isCreateTimebank: true,
                          timebankId: FlavorConfig.values.timebankId,
                          isFromFind: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  goToNext(data) {
    print(data);
  }
}
