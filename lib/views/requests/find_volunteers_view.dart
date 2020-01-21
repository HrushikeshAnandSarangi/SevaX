

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/user_model.dart';

import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../search_view.dart';

class FindVolunteersView extends StatefulWidget{
  final String timebankId;


  FindVolunteersView({this.timebankId});

  @override
  _FindVolunteersViewState createState() => _FindVolunteersViewState();

}

class _FindVolunteersViewState extends State<FindVolunteersView>{
  final TextEditingController searchTextController =
  new TextEditingController();

  final searchOnChange = new BehaviorSubject<String>();
  var validItems = List<String>();
  @override
  void initState() {
    super.initState();
    FirestoreManager.getAllTimebankIdStream(
      timebankId: widget.timebankId,
    ).then((onValue) {
      setState(() {
        validItems = onValue;

      });
    });
  }
  void _search(String queryString) {
    if (queryString.length == 1) {
      setState(() {
        searchOnChange.add(queryString);
      });
    } else {
      searchOnChange.add(queryString);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0,15,10,10),
              child: TextField(
                style: TextStyle(color: Colors.black),
               controller: searchTextController,
                onChanged: _search,

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
                    fillColor: Colors.grey[200],
                    focusedBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white),
                      borderRadius: new BorderRadius.circular(15.7),
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: new BorderRadius.circular(15.7)),
                    hintText: 'Type your team members name',
                    hintStyle: TextStyle(color: Colors.black45, fontSize: 14)),
              ),
            ),
            Expanded(
              child: UserResultViewElastic(searchTextController, widget.timebankId, validItems),
            ),
          ],
        ),
      );
  }

}
class UserResultViewElastic extends StatefulWidget {
  final TextEditingController controller;
  final String timebankId;
  final List<String> validItems;

  UserResultViewElastic(this.controller, this.timebankId,
      this.validItems,);

  @override
  _UserResultViewElasticState createState() {
    return _UserResultViewElasticState();
  }
}

class _UserResultViewElasticState extends State<UserResultViewElastic> {
  bool checkValidSting(String str) {
    return str != null && str.trim().length != 0;
  }

  bool isBookMarked = false;


  Widget build(BuildContext context) {
    if (widget == null ||
        widget.controller == null ||
        widget.controller.text == null) {
      return Container();
    }

    if (widget.controller.text.trim().isEmpty) {
      return Center(
        child: ClipOval(
          child: FadeInImage.assetNetwork(
              placeholder: 'lib/assets/images/search.png',
              image: 'lib/assets/images/search.png'),
        ),
      );
    } else if (widget.controller.text.trim().length < 3) {
      print('Search requires minimum 3 characters');
      return getEmptyWidget('Users', 'Search requires minimum 3 characters');
    }
    return StreamBuilder<List<UserModel>>(
      stream: SearchManager.searchForUserWithTimebankId(
          queryString: widget.controller.text, validItems: widget.validItems),
      builder: (context, snapshot) {
        print('$snapshot');

        //print('find ${snapshot.data}');
        if (snapshot.hasError) {
          Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              height: 48,
              width: 48,
              child: CircularProgressIndicator(),
            ),
          );
        }
        List<UserModel> userList = snapshot.data;
        /*if (userList.length == 0) {
          return getEmptyWidget('Users', 'No user found');
        }*/
        return ListView.builder(
          //itemCount: userList.length + 1,
          itemCount: 10,


          itemBuilder: (context, index) {
            /*if (index == 0) {
              return Container(
                padding: EdgeInsets.only(left: 8, top: 16),
                child: Text('Users', style: sectionTextStyle),
              );
            }*/
           // UserModel user = userList.elementAt(index - 1);
            return makeUserWidget();
          },
        );
      },
    );
  }


  Widget makeUserWidget(){
    return Container(
        margin: EdgeInsets.fromLTRB(35, 20, 30, 10),
        child: Stack(
            children: <Widget>[
              getUserCard(),
              getUserThumbnail(),
            ]
        )
    );
  }

  Widget getUserThumbnail() {
    return Container(
        margin: EdgeInsets.only(top:20,right: 15),
        width: 60.0,
        height: 60.0,
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill,
                image: new NetworkImage(
                    "https://www.itl.cat/pngfile/big/43-430987_cute-profile-images-pic-for-whatsapp-for-boys.jpg")
            )
        ));
  }
  Widget getUserCard({BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Container(
        height: 250,
        width: 500,
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: new BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: new Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right:10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text("Tony Stark", style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.bold),),
                  ),
//              Spacer(),
                  InkWell(

                    onTap: (){
                      setState(() {
                        isBookMarked = !isBookMarked;
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        isBookMarked ?

                        Icon(
                          Icons.bookmark, color: Colors.redAccent,
                          size: 35,
                        ): Icon(
                        Icons.bookmark,
                        color: Colors.grey,
                        size: 35,
                ),
                      ],
                    ),
                  ),
                ],
              ),
              SmoothStarRating(
                  allowHalfRating: true,
                  onRatingChanged: (v) {
//                    rating = v;
//                    setState(() {});
                  },
                  starCount: 5,
                  rating: 3.5,
                  size: 20.0,
                  filledIconData: Icons.star,
                  halfFilledIconData: Icons.star_half,
                  defaultIconData: Icons.star_border,
                  color: Colors.orangeAccent,
                  borderColor: Colors.orangeAccent,
                  spacing:1.0
              ),
              SizedBox(
                  height:10
              ),
              Expanded(
                child: Text("Tony Stark Tony StarkTony StarkTony StarkTony StarkTony Stark", style: TextStyle(color: Colors.black, fontSize: 12,),),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    height: 33,
                    width: 80,
                    child: RaisedButton(
                      shape: StadiumBorder(),
                      color: Colors.indigo,
                      textColor: Colors.white,
                      onPressed: () {},
                      child: const Text(
                          'Invite',
                          style: TextStyle(fontSize: 16)
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getEmptyWidget(String title, String notFoundValue) {
    return Center(
      child: Text(
        notFoundValue,
        overflow: TextOverflow.ellipsis,
        style: sectionHeadingStyle,
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
}