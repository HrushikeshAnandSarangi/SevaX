import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/helpers/get_request_user_status.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';

import '../core.dart';
//import 'package:smooth_star_rating/smooth_star_rating.dart';

enum PastHiredUserStatus { LOADING, LOADED, EMPTY }

class PastHiredUsersView extends StatefulWidget {
  final String timebankId;
  final RequestModel requestModel;
  final String sevaUserId;

  PastHiredUsersView(
      {@required this.timebankId, this.requestModel, this.sevaUserId});

  @override
  _PastHiredUsersViewState createState() {
    return _PastHiredUsersViewState();
  }
}

enum UserFavoriteStatus { Favorite, NotFavorite }

class _PastHiredUsersViewState extends State<PastHiredUsersView> {
  final _firestore = Firestore.instance;
  TimeBankModelSingleton timebank = TimeBankModelSingleton();
  List<UserModel> users = [];
  List<UserModel> favoriteUsers = [];
  bool isAdmin = false;
  PastHiredUserStatus userStatus = PastHiredUserStatus.LOADING;
  RequestModel requestModel;
  UserModel loggedinUser;

  @override
  void initState() {
    super.initState();

    if (timebank.model.admins.contains(widget.sevaUserId)) {
      isAdmin = true;
    }
    _firestore
        .collection('requests')
        .document(widget.requestModel.id)
        .snapshots()
        .listen((reqModel) {
      requestModel = RequestModel.fromMap(reqModel.data);
      setState(() {});
    });

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
        if (users.isEmpty) {
          userStatus = PastHiredUserStatus.EMPTY;
        } else {
          userStatus = PastHiredUserStatus.LOADED;
        }

        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    loggedinUser = SevaCore.of(context).loggedInUser;

    return StreamBuilder(
      stream: Firestore.instance
          .collection("users")
          .where(
            'recommendedTimebank',
            arrayContains: widget.timebankId,
          )
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List<UserModel> userList = [];

          snapshot.data.documents.forEach((userModel) {
            UserModel model = UserModel.fromMap(userModel.data);
            userList.add(model);
          });

          print("length ${userList.length}");
          userList.removeWhere((user) => user.sevaUserID == widget.sevaUserId);
          //print("length ${userList.length}");
          if (userList.length == 0) {
            return Center(
              child: getEmptyWidget('Users', S.of(context).no_user_found),
            );
          }
          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              UserModel user = userList.elementAt(index);
              List timeBankIds = user.favoriteByTimeBank ?? [];
              List memberId = user.favoriteByMember ?? [];

              return RequestCardWidget(
                timebankModel: timebank.model,
                requestModel: requestModel,
                userModel: user,
                isAdmin: isAdmin,
                currentCommunity: loggedinUser.currentCommunity,
                loggedUserId: loggedinUser.sevaUserID,
                refresh: () {},
                isFavorite: isAdmin ?? false
                    ? timeBankIds.contains(widget.timebankId)
                    : memberId.contains(widget.sevaUserId),
                reqStatus: getRequestUserStatus(
                    requestModel: requestModel,
                    userId: user.sevaUserID,
                    email: user.email,
                    context: context),
              );
            },
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  /*Widget getUserWidget(List<UserModel> favoriteUsers, UserModel user){


    if(favoriteUsers != null){

      bool isfavorite =false;

      print(" favorite ids are ${favoriteUsers[0].sevaUserID}");



      return RequestCardWidget(
        userModel: user,
        requestModel: widget.requestModel,
        timebankModel: timebank.model,
        isFavorite: true,
      );


    } else{
      return RequestCardWidget(
        userModel: user,
        requestModel: widget.requestModel,
        timebankModel: timebank.model,
        isFavorite: false,

      );
    }

  }
*/

}
