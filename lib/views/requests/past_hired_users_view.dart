import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';
//import 'package:smooth_star_rating/smooth_star_rating.dart';

class PastHiredUsersView extends StatefulWidget {
  final String timebankId;
  final RequestModel requestModel;

  PastHiredUsersView({@required this.timebankId, this.requestModel});

  @override
  _PastHiredUsersViewState createState() {
    return _PastHiredUsersViewState();
  }
}

class _PastHiredUsersViewState extends State<PastHiredUsersView> {
  final _firestore = Firestore.instance;
  TimeBankModelSingleton timebank = TimeBankModelSingleton();
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    _firestore
        .collection("users")
        .where(
          "recommendedTimebank",
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
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: users.length,
      itemBuilder: (context, index) {
        return RequestCardWidget(
          userModel: users[index],
          requestModel: widget.requestModel,
          timebankModel: timebank.model,
        );
      },
    );
  }

  // bool isBookMarked = false;
  // var validItems;
  // @override
  // Widget build(BuildContext context) {
  //   return StreamBuilder<List<UserModel>>(
  //     stream: SearchManager.searchForUserWithTimebankId(
  //         queryString: "", validItems: validItems),
  //     builder: (context, snapshot) {
  //       print('$snapshot');

  //       //print('find ${snapshot.data}');
  //       if (snapshot.hasError) {
  //         Text(snapshot.error.toString());
  //       }
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(
  //           child: SizedBox(
  //             height: 48,
  //             width: 48,
  //             child: CircularProgressIndicator(),
  //           ),
  //         );
  //       }
  //       List<UserModel> userList = snapshot.data;
  //       if (userList.length == 0) {
  //         return getEmptyWidget('Users', 'No user found');
  //       }
  //       return ListView.builder(
  //         itemCount: userList.length,

  //         itemBuilder: (context, index) {
  //           if (index == 0) {
  //             return Container(
  //               padding: EdgeInsets.only(left: 8, top: 16),
  //               child: Text('Users', style: sectionTextStyle),
  //             );
  //           }
  //           UserModel user = userList.elementAt(index);
  //           return RequestCardWidget(userModel: user,);
  //         },
  //       );
  //     },
  //   );
  // }

  // Widget getEmptyWidget(String title, String notFoundValue) {
  //   return Center(
  //     child: Text(
  //       notFoundValue,
  //       overflow: TextOverflow.ellipsis,
  //       style: sectionHeadingStyle,
  //     ),
  //   );
  // }

  // TextStyle get sectionHeadingStyle {
  //   return TextStyle(
  //     fontWeight: FontWeight.w600,
  //     fontSize: 12.5,
  //     color: Colors.black,
  //   );
  // }

  // TextStyle get sectionTextStyle {
  //   return TextStyle(
  //     fontWeight: FontWeight.w600,
  //     fontSize: 11,
  //     color: Colors.grey,
  //   );
  // }

}
