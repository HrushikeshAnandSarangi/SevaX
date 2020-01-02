import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/community_model.dart';

class FindCommunitiesView extends StatefulWidget {
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
        .debounceTime(Duration(milliseconds: 1200))
        .forEach((s) {
      if (s.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        bloc.fetchCommunities(s);
        setState(() {
          _searchText = s;
        });
      }
    });
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.5,
          backgroundColor: Color(0xFFFFFFFF),
          leading: BackButton(color: Colors.black54),
          title: Text(
            'Find your community',
            style: TextStyle(
                color: Colors.black54,
                fontSize: 20,
                fontWeight: FontWeight.w500),
          ),
        ),
        body: SearchTeams());
  }

  Widget SearchTeams() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        ),
        Text(
          'Look for existing teams to join',
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
              prefixIcon: Icon(Icons.search),
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
              hintText: 'Type your community name. Ex: Alaska ',
              hintStyle: TextStyle(color: Colors.black45)),
        ),
        Expanded(
          // ListView contains a group of widgets that scroll inside the drawer
          child: StreamBuilder(
            stream: bloc.allCommunities,
            builder: (context, AsyncSnapshot<CommunityListModel> snapshot) {
              if (snapshot.hasData) {
                return buildList(snapshot.data);
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return Text("");
            },
          ),
        ),
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
                        print('create community');
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
  Widget buildList(data) {
    return GridView.builder(
        itemCount: data.communities.length,
        gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (BuildContext context, int index) {
          print(data.communities[index]);
          return ListTile(
              onTap: goToNext(data),
            title: Text(data.communities[index].name),
            subtitle: Text(data.communities[index].primaryEmail),
            trailing: Text("Hai"),
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
