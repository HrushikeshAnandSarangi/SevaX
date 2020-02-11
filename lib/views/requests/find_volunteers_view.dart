import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/get_request_user_status.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';

class FindVolunteersView extends StatefulWidget {
  final String timebankId;
  final RequestModel requestModel;
  final String sevaUserId;

  FindVolunteersView({this.timebankId, this.requestModel, this.sevaUserId});

  @override
  _FindVolunteersViewState createState() => _FindVolunteersViewState();
}

class _FindVolunteersViewState extends State<FindVolunteersView> {
  final TextEditingController searchTextController =
      new TextEditingController();
  final _firestore = Firestore.instance;
  bool isAdmin = false;

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

    if (timebankModel.model.admins.contains(widget.sevaUserId)) {
      isAdmin = true;
    }

    // if (isAdmin) {
    //   _firestore
    //       .collection("users")
    //       .where(
    //         'favoriteByTimeBank',
    //         arrayContains: widget.timebankId,
    //       )
    //       .getDocuments()
    //       .then(
    //     (QuerySnapshot querysnapshot) {
    //       querysnapshot.documents.forEach(
    //         (DocumentSnapshot user) => users.add(
    //           UserModel.fromMap(
    //             user.data,
    //           ),
    //         ),
    //       );

    //       // setState(() {});
    //     },
    //   );
    // } else {
    //   //    print('admin is false ');
    //   _firestore
    //       .collection("users")
    //       .where(
    //         'favoriteByMember',
    //         arrayContains: widget.sevaUserId,
    //       )
    //       .getDocuments()
    //       .then(
    //     (QuerySnapshot querysnapshot) {
    //       querysnapshot.documents.forEach(
    //         (DocumentSnapshot user) => users.add(
    //           UserModel.fromMap(
    //             user.data,
    //           ),
    //         ),
    //       );

    //       // setState(() {});
    //     },
    //   );
    // }
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
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 15, 10, 10),
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
            child: UserResultViewElastic(
                searchTextController,
                widget.timebankId,
                validItems,
                widget.requestModel.id,
                timebankModel.model,
                users,
                widget.sevaUserId),
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
  final String requestModelId;
  final String sevaUserId;
  final TimebankModel timebankModel;
  final List<UserModel> favoriteUsers;

  UserResultViewElastic(
      this.controller,
      this.timebankId,
      this.validItems,
      this.requestModelId,
      this.timebankModel,
      this.favoriteUsers,
      this.sevaUserId);

  @override
  _UserResultViewElasticState createState() {
    return _UserResultViewElasticState();
  }
}

class _UserResultViewElasticState extends State<UserResultViewElastic> {
  final _firestore = Firestore.instance;
  HashMap<String, dynamic> userFilterMap = HashMap();

  bool checkValidSting(String str) {
    return str != null && str.trim().length != 0;
  }

  bool isAdmin = false;
  RequestModel requestModel;
  bool isBookMarked = false;
  UserModel loggedinUser;

  @override
  void initState() {
    super.initState();

    if (widget.timebankModel.admins.contains(widget.sevaUserId)) {
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

    if (widget == null ||
        widget.controller == null ||
        widget.controller.text == null) {
      return Container();
    }

    return buildWidget();
  }

  Widget buildWidget() {
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
        //  print("users snapshot is --- " + '$snapshot');

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
        print("length ${snapshot.data}");

        List<UserModel> userList = snapshot.data;
        print("length ${userList.length}");
        userList.removeWhere((user) => user.sevaUserID == widget.sevaUserId);
        print("length ${userList.length}");

        if (userList.length == 0) {
          return getEmptyWidget('Users', 'No user found');
        }
        return ListView.builder(
          itemCount: userList.length,
          itemBuilder: (context, index) {
            UserModel user = userList[index];
            // List<String> timeBankIds = user.favoriteByTimeBank ?? [];
            List<String> timeBankIds =
                snapshot.data[index].favoriteByTimeBank ?? [];
            List<String> memberId = user.favoriteByMember ?? [];

            //      print("fav mem  ${memberId} " + 'fav tb ${timeBankIds}');
            //    print("is Admin  ${widget.timebankModel.id} + ${timeBankIds}");

            return RequestCardWidget(
              userModel: user,
              requestModel: requestModel,
              timebankModel: widget.timebankModel,
              isAdmin: isAdmin,
              refresh: refresh,
              currentCommunity: loggedinUser.currentCommunity,
              loggedUserId: loggedinUser.sevaUserID,
              isFavorite: isAdmin
                  ? timeBankIds.contains(widget.timebankModel.id)
                  : memberId.contains(widget.sevaUserId),
              reqStatus: getRequestUserStatus(
                requestModel: requestModel,
                userId: user.sevaUserID,
                email: user.email,
              ),
            );
          },
        );
      },
    );
  }

  refresh() {
    setState(() {
      buildWidget();
    });
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
