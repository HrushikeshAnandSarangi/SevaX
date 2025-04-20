import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/helpers/get_request_user_status.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

import '../core.dart';
//import 'package:smooth_star_rating/smooth_star_rating.dart';

enum PastHiredUserStatus { LOADING, LOADED, EMPTY }

class PastHiredUsersView extends StatefulWidget {
  final String timebankId;
  final RequestModel? requestModel;
  final String? sevaUserId;
  final List<UserModel>? favouriteMembers;

  PastHiredUsersView(
      {required this.timebankId,
      this.requestModel,
      this.sevaUserId,
      this.favouriteMembers});

  @override
  _PastHiredUsersViewState createState() {
    return _PastHiredUsersViewState();
  }
}

enum UserFavoriteStatus { Favorite, NotFavorite }

class _PastHiredUsersViewState extends State<PastHiredUsersView> {
  TimeBankModelSingleton timebank = TimeBankModelSingleton();
  List<UserModel> users = [];
  List<UserModel> favoriteUsers = [];
  bool isAdmin = false;
  PastHiredUserStatus userStatus = PastHiredUserStatus.LOADING;
  RequestModel? requestModel;
  UserModel? loggedinUser;

  @override
  void initState() {
    super.initState();

    if (isAccessAvailable(timebank.model, widget.sevaUserId!)) {
      isAdmin = true;
    }
    CollectionRef.requests
        .doc(widget.requestModel!.id!)
        .snapshots()
        .listen((reqModel) {
      requestModel =
          RequestModel.fromMap(reqModel.data() as Map<String, dynamic>);
      setState(() {});
    });

    CollectionRef.users
        .where(
          "recommendedTimebank",
          arrayContains: widget.timebankId,
        )
        .get()
        .then(
      (QuerySnapshot querysnapshot) {
        querysnapshot.docs.forEach(
          (DocumentSnapshot user) => users.add(
            UserModel.fromMap(
                user.data() as Map<String, dynamic>, 'past_hired'),
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
      stream: CollectionRef.users
          .where(
            'recommendedTimebank',
            arrayContains: widget.timebankId,
          )
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List<UserModel> userList = [];

          snapshot.data!.docs.forEach((userModel) {
            UserModel model = UserModel.fromMap(
                userModel.data() as Map<String, dynamic>, 'past_hired');
            userList.add(model);
          });

          userList.removeWhere((user) => user.sevaUserID == widget.sevaUserId);
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
                requestModel: requestModel!,
                userModel: user,
                isAdmin: isAdmin,
                currentCommunity: loggedinUser!.currentCommunity!,
                loggedUserId: loggedinUser!.sevaUserID!,
                refresh: () {},
                isFavorite: isAdmin ?? false
                    ? timeBankIds.contains(widget.timebankId)
                    : memberId.contains(widget.sevaUserId),
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

  /*Widget getUserWidget(List<UserModel> favoriteUsers, UserModel user){


    if(favoriteUsers != null){

      bool isfavorite =false;

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
