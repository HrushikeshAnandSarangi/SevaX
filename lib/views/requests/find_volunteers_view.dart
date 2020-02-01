import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';

import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../search_view.dart';

class FindVolunteersView extends StatefulWidget{
  final String timebankId;
  final RequestModel requestModel;
  final String sevaUserId;


  FindVolunteersView({this.timebankId,this.requestModel, this.sevaUserId});

  @override
  _FindVolunteersViewState createState() => _FindVolunteersViewState();

}

class _FindVolunteersViewState extends State<FindVolunteersView>{
  final TextEditingController searchTextController =
  new TextEditingController();
  final _firestore = Firestore.instance;
  bool isAdmin =false;


  TimeBankModelSingleton timebankModel = TimeBankModelSingleton();

  final searchOnChange = new BehaviorSubject<String>();
  var validItems = List<String>();
  List<UserModel> users = [];



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


    if(timebankModel.model.admins.contains(widget.sevaUserId)){
      isAdmin =true;

    }

    if(isAdmin){
      //   print('admin is true ');
      _firestore
          .collection("users")
          .where(
        'favoriteByTimeBank',
        arrayContains: widget.timebankId,
      )
          .getDocuments()
          .then(
            (QuerySnapshot querysnapshot) {
          querysnapshot.documents.forEach(
                (DocumentSnapshot user) => users.add(
              UserModel.fromMap(
                user.data,
              ),
            ),
          );


         // setState(() {});
        },
      );
    }else{
      //    print('admin is false ');
      _firestore
          .collection("users")

          .where(
        'favoriteByMember',
        arrayContains: widget.sevaUserId,
      )
          .getDocuments()
          .then(
            (QuerySnapshot querysnapshot) {
          querysnapshot.documents.forEach(
                (DocumentSnapshot user) => users.add(
              UserModel.fromMap(
                user.data,
              ),
            ),
          );


         // setState(() {});
        },
      );

    }

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
              child: UserResultViewElastic(searchTextController, widget.timebankId, validItems, widget.requestModel, timebankModel.model, users,),
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
  final RequestModel requestModel;
  final TimebankModel timebankModel;
  final List<UserModel> favoriteUsers;

  UserResultViewElastic(this.controller, this.timebankId,
      this.validItems,this.requestModel, this.timebankModel, this.favoriteUsers);

  @override
  _UserResultViewElasticState createState() {
    return _UserResultViewElasticState();
  }
}

class _UserResultViewElasticState extends State<UserResultViewElastic> {
  HashMap<String, dynamic> userFilterMap = HashMap();

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
      return getEmptyWidget('Users', 'Search requires minimum 3 characters');
    }
    return StreamBuilder<List<UserModel>>(
      stream: SearchManager.searchForUserWithTimebankId(
          queryString: widget.controller.text, validItems: widget.validItems),
      builder: (context, snapshot) {
        print("users snapshot is --- "+'$snapshot');

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
        if (userList.length == 0) {
          return getEmptyWidget('Users', 'No user found');
        }
        return ListView.builder(


          itemCount: userList.length,
          itemBuilder: (context, index) {


            bool favoriteStatus = false;
            UserModel user = userList.elementAt(index);
         // print("ids are  ${widget.favoriteUsers[index].sevaUserID} " + userList[index].sevaUserID);


            if (widget.favoriteUsers != null) {
              for (int i = 0; i < widget.favoriteUsers.length; i++) {

                //  print("ids are  ${userModelList[i].sevaUserID} " + sevaUserId);

                if (widget.favoriteUsers[i].sevaUserID == user.sevaUserID) {
                  favoriteStatus = true;
                }
              }
              return RequestCardWidget(userModel: user,
                requestModel: widget.requestModel,
                timebankModel: widget.timebankModel,
                isFavorite: favoriteStatus,
                cameFromInvitedUsersPage: false,
              );

            }else{
              return RequestCardWidget(userModel: user,
                requestModel: widget.requestModel,
                timebankModel: widget.timebankModel,
                isFavorite: false,
                cameFromInvitedUsersPage: false,
              );

            }

          },
        );
      },
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