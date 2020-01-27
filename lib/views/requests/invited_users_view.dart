

import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class InvitedUsersView extends StatefulWidget{

  final String timebankId;

  InvitedUsersView({@required this.timebankId});

  @override
  _InvitedUsersViewState createState() {
    // TODO: implement createState
    return _InvitedUsersViewState();
  }

}

class _InvitedUsersViewState extends State<InvitedUsersView> {
  bool isBookMarked = false;
  var validItems;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  StreamBuilder<List<UserModel>>(
      stream: SearchManager.searchForUserWithTimebankId(
          queryString: "", validItems: validItems),
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
        if (userList.length == 0) {
          return getEmptyWidget('Users', 'No user found');
        }
        return ListView.builder(
          //itemCount: userList.length + 1,
          itemCount: userList.length,


          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                padding: EdgeInsets.only(left: 8, top: 16),
                child: Text('Users', style: sectionTextStyle),
              );
            }
             UserModel user = userList.elementAt(index);
            //UserModel user;
            return RequestCardWidget(userModel: user,);
          },
        );
      },
    );
  }


}