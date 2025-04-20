import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/helpers/get_request_user_status.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

enum FavoriteUserStatus { LOADING, LOADED, EMPTY }

class FavoriteUsers extends StatefulWidget {
  final String timebankId;
  final String? requestModelId;
  final String? sevaUserId;

  FavoriteUsers({
    required this.timebankId,
    this.requestModelId,
    this.sevaUserId,
  });

  @override
  _FavoriteUsersState createState() => _FavoriteUsersState();
}

enum RequestUserStatus { INVITE, INVITED, APPROVED, REJECTED }

class _FavoriteUsersState extends State<FavoriteUsers> {
  var validItems;
  bool isAdmin = false;
  TimeBankModelSingleton timebank = TimeBankModelSingleton();

  List<UserModel> users = [];
  FavoriteUserStatus userStatus = FavoriteUserStatus.LOADING;
  BuildContext? dialogLoadingContext;
  RequestModel? requestModel;
  UserModel? loggedinUser;

  @override
  void initState() {
    super.initState();

    if (isAccessAvailable(timebank.model, widget.sevaUserId!)) {
      isAdmin = true;
    }

    CollectionRef.requests
        .doc(widget.requestModelId)
        .snapshots()
        .listen((reqModel) {
      requestModel =
          RequestModel.fromMap(reqModel.data() as Map<String, dynamic>);
      setState(() {});
    });
  }

  Widget build(BuildContext context) {
    loggedinUser = SevaCore.of(context).loggedInUser;
    return StreamBuilder(
      stream: CollectionRef.users
          .where(isAdmin ? "favoriteByTimeBank" : "favoriteByMember",
              arrayContains: isAdmin ? widget.timebankId : widget.sevaUserId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List<UserModel> userList = [];

          snapshot.data!.docs.forEach((userModel) {
            UserModel model = UserModel.fromMap(
                userModel.data() as Map<String, dynamic>, 'fav_users');
            userList.add(model);
          });

          userList.removeWhere((user) => user.sevaUserID == widget.sevaUserId);
          if (userList.length == 0) {
            return getEmptyWidget(
              S.of(context).users,
              S.of(context).no_user_found,
            );
          }
          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              UserModel user = userList.elementAt(index);
              return RequestCardWidget(
                timebankModel: timebank.model,
                requestModel: requestModel!,
                userModel: user,
                currentCommunity: loggedinUser!.currentCommunity!,
                loggedUserId: loggedinUser!.sevaUserID!,
                isFavorite: true,
                isAdmin: isAdmin,
                refresh: () {},
                reqStatus: getRequestUserStatus(
                    requestModel: requestModel!,
                    userId: user.sevaUserID!,
                    email: user.email!,
                    context: context),
              );
            },
          );
        }
        return LoadingIndicator();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
