import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/helpers/get_request_user_status.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';

enum FavoriteUserStatus { LOADING, LOADED, EMPTY }

class FavoriteUsers extends StatefulWidget {
  final String timebankId;
  final String requestModelId;
  final String sevaUserId;

  FavoriteUsers({
    @required this.timebankId,
    this.requestModelId,
    this.sevaUserId,
  });

  @override
  _FavoriteUsersState createState() => _FavoriteUsersState();
}

enum RequestUserStatus { INVITE, INVITED, APPROVED, REJECTED }

class _FavoriteUsersState extends State<FavoriteUsers> {
  final _firestore = Firestore.instance;

  var validItems;
  bool isAdmin = false;
  TimeBankModelSingleton timebank = TimeBankModelSingleton();

  List<UserModel> users = [];
  FavoriteUserStatus userStatus = FavoriteUserStatus.LOADING;
  BuildContext dialogLoadingContext;
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
        .document(widget.requestModelId)
        .snapshots()
        .listen((reqModel) {
      requestModel = RequestModel.fromMap(reqModel.data);
      setState(() {});
    });
  }

  Widget build(BuildContext context) {
    loggedinUser = SevaCore.of(context).loggedInUser;
    return StreamBuilder(
      stream: Firestore.instance
          .collection("users")
          .where(isAdmin ? "favoriteByTimeBank" : "favoriteByMember",
              arrayContains: isAdmin ? widget.timebankId : widget.sevaUserId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List<UserModel> userList = [];

          snapshot.data.documents.forEach((userModel) {
            UserModel model = UserModel.fromMap(userModel.data);
            userList.add(model);
          });

          // print("length ${userList.length}");
          userList.removeWhere((user) => user.sevaUserID == widget.sevaUserId);
          //print("length ${userList.length}");
          if (userList.length == 0) {
            return getEmptyWidget('Users', 'No user found');
          }
          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              UserModel user = userList.elementAt(index);
              print(
                  "looger user ${loggedinUser.currentCommunity + loggedinUser.sevaUserID}");

              return RequestCardWidget(
                timebankModel: timebank.model,
                requestModel: requestModel,
                userModel: user,
                currentCommunity: loggedinUser.currentCommunity,
                loggedUserId: loggedinUser.sevaUserID,
                isFavorite: true,
                isAdmin: isAdmin,
                refresh: refresh,
                reqStatus: getRequestUserStatus(
                  requestModel: requestModel,
                  userId: user.sevaUserID,
                  email: user.email,
                ),
              );
            },
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  refresh() {}

  @override
  dispose() {
    super.dispose();
  }
}
