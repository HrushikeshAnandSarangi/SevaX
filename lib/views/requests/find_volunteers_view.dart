import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
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
  final TextEditingController searchTextController = TextEditingController();
  final _firestore = Firestore.instance;
  bool isAdmin = false;
  final _textUpdates = StreamController<String>();

  TimeBankModelSingleton timebankModel = TimeBankModelSingleton();

  final searchOnChange = BehaviorSubject<String>();
  var validItems = List<String>();
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    String _searchText = "";

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

    searchTextController
        .addListener(() => _textUpdates.add(searchTextController.text));

    Observable(_textUpdates.stream)
        .debounceTime(Duration(milliseconds: 400))
        .forEach((s) {
      if (s.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        volunteerUsersBloc.fetchUsers(s);
        setState(() {
          _searchText = s;
        });
      }
    });
  }

  void _search(String queryString) {
    if (queryString.length == 3) {
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
              autocorrect: true,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        searchTextController.clear();
                      }),
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
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(15.7),
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(15.7)),
                  hintText: AppLocalizations.of(context)
                      .translate('requests', 'type_team_member_name'),
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
    this.sevaUserId,
  );

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
      try {
        setState(() {});
      } on Exception catch (error) {
        print(error);
      }
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
          child: ClipOval(
            child: Image.asset('lib/assets/images/search.png'),
          ),
        ),
      );
    } else if (widget.controller.text.trim().length < 3) {
      return getEmptyWidget('Users',
          AppLocalizations.of(context).translate('requests', 'min_search_err'));
    }
    return StreamBuilder<List<UserModel>>(
      stream: SearchManager.searchForUserWithTimebankId(
          queryString: widget.controller.text, validItems: widget.validItems),
      builder: (context, snapshot) {
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
        userList.removeWhere((user) => user.sevaUserID == widget.sevaUserId);

        if (userList.length == 0) {
          return getEmptyWidget('Users',
              AppLocalizations.of(context).translate('requests', 'no_users'));
        }
        return ListView.builder(
          itemCount: userList.length,
          itemBuilder: (context, index) {
            UserModel user = userList[index];
            List<String> timeBankIds =
                snapshot.data[index].favoriteByTimeBank ?? [];
            List<String> memberId = user.favoriteByMember ?? [];

            return RequestCardWidget(
              userModel: user,
              requestModel: requestModel,
              timebankModel: widget.timebankModel,
              isAdmin: isAdmin,
              refresh: refresh,
              currentCommunity: loggedinUser.currentCommunity,
              loggedUserId: loggedinUser.sevaUserID,
              isFavorite: isAdmin
                  ? timeBankIds.contains(requestModel.timebankId)
                  : memberId.contains(widget.sevaUserId),
              reqStatus: getRequestUserStatus(
                  requestModel: requestModel,
                  userId: user.sevaUserID,
                  email: user.email,
                  context: context),
            );
          },
        );
      },
    );
  }

  void refresh() {
    _firestore
        .collection('requests')
        .document(widget.requestModelId)
        .snapshots()
        .listen((reqModel) {
      requestModel = RequestModel.fromMap(reqModel.data);
      try {
        setState(() {
          buildWidget();
        });
      } on Exception catch (error) {
        print(error);
      }
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
