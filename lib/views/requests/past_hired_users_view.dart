import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class PastHiredUsersView extends StatefulWidget{
  final String timebankId;


  PastHiredUsersView({@required this.timebankId});

  @override
  _PastHiredUsersViewState createState() {
    // TODO: implement createState
    return _PastHiredUsersViewState();
  }



}

class _PastHiredUsersViewState extends State<PastHiredUsersView> {

  bool isBookMarked = false;
  var validItems;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder<List<UserModel>>(
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
             UserModel user ;
            return RequestCardWidget(userModel: user,);
          },
        );
      },
    );
  }


}