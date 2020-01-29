

import 'package:flutter/material.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class InvitedUsersView extends StatefulWidget{

  final String timebankId;
  final RequestModel requestModel;

  InvitedUsersView({@required this.timebankId, this.requestModel});

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
    timeBankBloc.setInvitedUsersData(widget.requestModel.id);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  StreamBuilder<TimebankController>(
//      stream: SearchManager.searchForUserWithTimebankId( // TODO : replace function here
//          queryString: "", validItems: validItems),
      stream: timeBankBloc.timebankController,
      builder: (context, AsyncSnapshot<TimebankController> snapshot) {

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
        List<UserModel> userList = snapshot.data.invitedUsersForRequest;
        if (userList.length == 0) {
          return getEmptyWidget('Users', 'No user found');
        }
        return ListView(
          children: <Widget>[
            Text('Users'),
//            ...userList.map((data)=>RequestCardWidget(userModel: data,requestModel: widget.requestModel,cameFromInvitedUsersPage: true,)).toList()
            ...userList.map((data)=>RequestCardWidget(userModel: data,requestModel: widget.requestModel,cameFromInvitedUsersPage: true,))
          ],
        );
//        return ListView.builder(
//          itemCount: userList.length,
//
//          itemBuilder: (context, index) {
//            if (index == 0) {
//              Container(
//                padding: EdgeInsets.only(left: 8, top: 16),
//                child: Text('Users', style: sectionTextStyle),
//              );
//            }
//            UserModel user = userList.elementAt(index);
//
//              return RequestCardWidget(userModel: user,requestModel: widget.requestModel, cameFromInvitedUsersPage: true,);
//
//
//          },
//        );
      },
    );
  }


}