import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/get_request_user_status.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class FindVolunteersView extends StatefulWidget {
  final String? timebankId;
  final RequestModel? requestModel;
  final String? sevaUserId;

  FindVolunteersView({this.timebankId, this.requestModel, this.sevaUserId});

  @override
  _FindVolunteersViewState createState() => _FindVolunteersViewState();
}

class _FindVolunteersViewState extends State<FindVolunteersView> {
  final TextEditingController searchTextController = TextEditingController();
  final _firestore = CollectionRef;
  bool isAdmin = false;
  final _textUpdates = StreamController<String>();

  TimeBankModelSingleton timebankModel = TimeBankModelSingleton();

  final searchOnChange = BehaviorSubject<String>();
  List<String> validItems = [];
  List<UserModel> users = [];
  final _searchText = BehaviorSubject<String>();
  final _debouncer = Debouncer(milliseconds: 400);
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirestoreManager.getAllTimebankIdStream(
        timebankId: widget.timebankId!,
      ).then((onValue) {
        setState(() {
          validItems = onValue.listOfElement!;
          timebankModel.model = onValue.timebankModel!;
        });
        if (isAccessAvailable(timebankModel.model, widget.sevaUserId!)) {
          isAdmin = true;
        }
      });
      // executes after build
    });

    searchTextController.addListener(() {
      _debouncer.run(() {
        String s = searchTextController.text;

        if (s.isEmpty) {
          setState(() {});
        } else {
          setState(() {});
        }
      });
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
                hintText: S.of(context).type_team_member_name,
                hintStyle: TextStyle(
                  color: Colors.black45,
                  fontSize: 14,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
            ),
          ),
          Expanded(
            child: UserResultViewElastic(
                searchTextController,
                widget.timebankId!,
                validItems,
                widget.requestModel!.id!,
                timebankModel.model,
                users,
                widget.sevaUserId!),
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
  HashMap<String, dynamic> userFilterMap = HashMap();

  bool checkValidSting(String str) {
    return str != null && str.trim().length != 0;
  }

  bool isAdmin = false;
  RequestModel? requestModel;
  bool isBookMarked = false;
  UserModel? loggedinUser;

  @override
  void initState() {
    super.initState();
    if (widget.timebankModel != null &&
        widget.timebankModel.admins != null &&
        isAccessAvailable(widget.timebankModel, widget.sevaUserId)) {
      isAdmin = true;
    }

    CollectionRef.requests
        .doc(widget.requestModelId)
        .snapshots()
        .listen((reqModel) {
      requestModel =
          RequestModel.fromMap(reqModel.data() as Map<String, dynamic>);
      try {
        setState(() {});
      } on Exception catch (error) {
        logger.e(error);
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
    if (widget.controller.text.trim().length < 1) {
      return recommendedUsers();
    } else if (widget.controller.text.trim().length < 3) {
      return getEmptyWidget(
          S.of(context).validation_error_search_min_characters);
    } else {
      return StreamBuilder<List<UserModel>>(
        stream: SearchManager.searchForUserWithTimebankId(
          queryString: widget.controller.text,
          validItems: widget.validItems,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return Center(
              child: SizedBox(
                height: 48,
                width: 48,
                child: LoadingIndicator(),
              ),
            );
          }

          List<UserModel> userList = snapshot.data!;
          userList.removeWhere((user) =>
              user.sevaUserID == widget.sevaUserId ||
              user.sevaUserID == requestModel!.sevaUserId);

          if (userList.length == 0) {
            return getEmptyWidget(S.of(context).no_user_found);
          }
          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              UserModel user = userList[index];

              List<String> timeBankIds = (snapshot.data != null
                      ? snapshot.data![index].favoriteByTimeBank
                      : []) ??
                  [];
              List<String> memberId = user.favoriteByMember ?? [];

              return RequestCardWidget(
                userModel: user,
                requestModel: requestModel!,
                timebankModel: widget.timebankModel,
                isAdmin: isAdmin,
                refresh: refresh,
                currentCommunity: loggedinUser!.currentCommunity!,
                loggedUserId: loggedinUser!.sevaUserID!,
                isFavorite: isAdmin
                    ? timeBankIds.contains(requestModel!.timebankId!)
                    : memberId.contains(widget.sevaUserId),
                reqStatus: getRequestUserStatus(
                    requestModel: requestModel!,
                    userId: user.sevaUserID!,
                    email: user.email!,
                    context: context),
              );
            },
          );
        },
      );
    }
  }

  Widget recommendedUsers() {
    return StreamBuilder<List<UserModel>>(
      stream: FirestoreManager.getRecommendedUsersStream(
        requestId: requestModel!.id!,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Text(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              height: 48,
              width: 48,
              child: LoadingIndicator(),
            ),
          );
        }

        List<UserModel> userList = snapshot.data!;
        userList.removeWhere((user) => user.sevaUserID == widget.sevaUserId);

        if (userList.length == 0) {
          return Center(
            child: ClipOval(
              child: ClipOval(
                child: Image.asset('lib/assets/images/search.png'),
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: getEmptyWidget('Recommended'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: userList.length,
                itemBuilder: (context, index) {
                  UserModel user = userList[index];
                  List<String> timeBankIds = (snapshot.data != null
                          ? snapshot.data![index].favoriteByTimeBank
                          : []) ??
                      [];
                  List<String> memberId = user.favoriteByMember ?? [];

                  return RequestCardWidget(
                    userModel: user,
                    requestModel: requestModel!,
                    timebankModel: widget.timebankModel,
                    isAdmin: isAdmin,
                    refresh: refresh,
                    currentCommunity: loggedinUser!.currentCommunity!,
                    loggedUserId: loggedinUser!.sevaUserID!,
                    isFavorite: isAdmin
                        ? timeBankIds.contains(requestModel!.timebankId!)
                        : memberId.contains(widget.sevaUserId),
                    reqStatus: getRequestUserStatus(
                        requestModel: requestModel!,
                        userId: user.sevaUserID!,
                        email: user.email!,
                        context: context),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void refresh() {
    CollectionRef.requests
        .doc(widget.requestModelId)
        .snapshots()
        .listen((reqModel) {
      requestModel =
          RequestModel.fromMap(reqModel.data() as Map<String, dynamic>);
      try {
        setState(() {
          buildWidget();
        });
      } on Exception catch (error) {
        logger.e(error);
      }
    });
  }

  Widget getEmptyWidget(String notFoundValue) {
    return Text(
      notFoundValue,
      overflow: TextOverflow.ellipsis,
      style: sectionHeadingStyle,
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
