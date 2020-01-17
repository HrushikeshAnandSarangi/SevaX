import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/views/community/communitycreate.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/invitation/OnboardWithTimebankCode.dart';

class FindCommunitiesView extends StatefulWidget {
  final bool keepOnBackPress;

  FindCommunitiesView({@required this.keepOnBackPress});

  @override
  State<StatefulWidget> createState() {
    return FindCommunitiesViewState();
  }
}

class FindCommunitiesViewState extends State<FindCommunitiesView> {
  final TextEditingController searchTextController =
      new TextEditingController();

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
    return MaterialApp(
      theme: FlavorConfig.values.theme,
      home: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: widget.keepOnBackPress,
            leading: widget.keepOnBackPress
                ? BackButton(color: Colors.black54)
                : null,
            elevation: 0.5,
            backgroundColor: Color(0xFFFFFFFF),
            title: Text(
              'Find your community',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: SearchTeams()),
    );
  }

  Widget SearchTeams() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        ),
        Text(
          'Look for existing communities to join',
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
              hasFloatingPlaceholder: false,
              alignLabelWithHint: true,
              isDense: true,
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey,
              ),
              contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
              filled: true,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.white),
                borderRadius: new BorderRadius.circular(25.7),
              ),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: new BorderRadius.circular(25.7)),
              hintText: 'Type your community name. Ex: Alaska (min 5 char)',
              hintStyle: TextStyle(color: Colors.black45, fontSize: 14)),
        ),
        buildList(),
        // This container holds the align
        CreateCommunity(),
      ]),
    );
  }

  Widget CreateCommunity() {
    return Container(
        // This align moves the children to the bottom
        child: Align(
            alignment: FractionalOffset.bottomCenter,
            // This container holds all the children that will be aligned
            // on the bottom and should not scroll with the above ListView
            child: Container(
                height: 100,
                width: 200,
                child: Column(
                  children: <Widget>[
                    Text('Or'),
                    RaisedButton(
                      onPressed: () {
                        createEditCommunityBloc.updateUserDetails(
                            SevaCore.of(context).loggedInUser);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context1) => SevaCore(
                                    loggedInUser:
                                        SevaCore.of(context).loggedInUser,
                                    child: CreateEditCommunityView(
                                      timebankId:
                                          FlavorConfig.values.timebankId,
                                    ))));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Text('Create your Community'),
                          ),
                        ],
                      ),
                      color: Theme.of(context).accentColor,
                      textColor: FlavorConfig.values.buttonTextColor,
                      shape: StadiumBorder(),
                    )
                  ],
                ))));
  }

  Widget buildList() {
    // ListView contains a group of widgets that scroll inside the drawer
    return StreamBuilder(
        stream: communityBloc.allCommunities,
        builder: (context, AsyncSnapshot<CommunityListModel> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null && snapshot.data.loading) {
              return Expanded(
                  child: Center(child: CircularProgressIndicator()));
            } else {
              return Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: 0, right: 0, top: 12.0),
                      child: ListView.builder(
                          itemCount: snapshot.data.communities.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              onTap: goToNext(snapshot.data),
                              title: Text(snapshot.data.communities[index].name,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w700)),
                              // subtitle: Text("Created by " +
                              //     snapshot.data.communities[index].created_by),
                              subtitle: FutureBuilder(
                                future: getUserForId(sevaUserId:snapshot.data.communities[index].created_by),
                                builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
                                  if (snapshot.hasError) {
                                    return Text(
                                      "Not found",
                                    );
                                  }
                                  else if(snapshot.connectionState==ConnectionState.waiting){
                                    return Text("...");
                                  }
                                  else if (snapshot.hasData) {
                                    return Text(
                                      "Created by "+snapshot.data.fullname,
                                    );
                                  } else {
                                    return Text(
                                      "Community",
                                    );
                                  }
                                },
                              ),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    RaisedButton(
                                      onPressed: () {
                                        var communityModel =
                                            snapshot.data.communities[index];
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
                                              communityModel: communityModel,
                                            ),
                                          ),
                                        );
                                        print('clicked ${communityModel.id}');
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: Text('Join'),
                                          ),
                                        ],
                                      ),
                                      color: Theme.of(context).accentColor,
                                      textColor:
                                          FlavorConfig.values.buttonTextColor,
                                      shape: StadiumBorder(),
                                    )
                                  ]),
                            );
                          })));
            }
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Expanded(
            child: Text(""),
          );
        });
  }

  goToNext(data) {
    print(data);
  }

//  openDetailPage(ItemModel data, int index) {
//    final page = MovieDetailBlocProvider(
//      child: MovieDetail(
//        title: data.results[index].title,
//        posterUrl: data.results[index].backdrop_path,
//        description: data.results[index].overview,
//        releaseDate: data.results[index].release_date,
//        voteAverage: data.results[index].vote_average.toString(),
//        movieId: data.results[index].id,
//      ),
//    );
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) {
//        return page;
//      }),
//    );
//  }
}
