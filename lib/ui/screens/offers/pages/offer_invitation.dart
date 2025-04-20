import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/offer_card_widget.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class FindVolunteersViewForOffer extends StatefulWidget {
  final String? timebankId;
  final String? sevaUserId;
  final OfferModel? offerModel;

  FindVolunteersViewForOffer({
    this.timebankId,
    this.sevaUserId,
    this.offerModel,
  });

  @override
  _FindVolunteersViewStateForOffer createState() =>
      _FindVolunteersViewStateForOffer();
}

class _FindVolunteersViewStateForOffer
    extends State<FindVolunteersViewForOffer> {
  TimebankModel? timebankModel;
  TimebankParticipantsDataHolder timebankParticipantsDataHolder =
      TimebankParticipantsDataHolder();
  final TextEditingController searchTextController = TextEditingController();
  final _textUpdates = StreamController<String>();
  final volunteerUsersBloc = VolunteerFindBloc();

  final searchOnChange = BehaviorSubject<String>();
  // var validItems = [];
  List<UserModel> users = [];
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    String _searchText = "";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirestoreManager.getAllTimebankIdStream(
        timebankId: widget.timebankId!,
      ).then((onValue) {
        setState(() {
          timebankParticipantsDataHolder = onValue;
        });
      });
      // executes after build
    });

    searchTextController.addListener(() {
      _debouncer.run(() {
        String s = searchTextController.text;

        if (s.isEmpty) {
          setState(() {
            _searchText = "";
          });
        } else {
          setState(() {
            _searchText = s;
          });
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
            child: ElasticSearchResultsHolder(
              searchTextController,
              widget.timebankId!,
              timebankParticipantsDataHolder.listOfElement!,
              widget.offerModel!.id!,
              timebankParticipantsDataHolder.timebankModel!,
              widget.sevaUserId!,
            ),
          ),
        ],
      ),
    );
  }
}

class ElasticSearchResultsHolder extends StatefulWidget {
  final TextEditingController controller;
  final String timebankId;
  final List<String> validItems;
  final String offerId;
  final String sevaUserId;
  final TimebankModel timebankModel;

  ElasticSearchResultsHolder(
    this.controller,
    this.timebankId,
    this.validItems,
    this.offerId,
    this.timebankModel,
    this.sevaUserId,
  );

  @override
  _ElasticSearchResultsHolderState createState() {
    return _ElasticSearchResultsHolderState();
  }
}

class _ElasticSearchResultsHolderState
    extends State<ElasticSearchResultsHolder> {
  HashMap<String, dynamic> userFilterMap = HashMap();

  bool checkValidSting(String str) {
    return str != null && str.trim().length != 0;
  }

  bool isAdmin = false;
  OfferModel? offerModel;
  bool isBookMarked = false;
  UserModel? loggedinUser;

  List<String>? offerAcceptors;
  List<String>? offerInvites;

  @override
  void initState() {
    logger.i("INIT STATE==================||||||");
    super.initState();
    if (widget.timebankModel != null &&
        widget.timebankModel.admins != null &&
        isAccessAvailable(widget.timebankModel, widget.sevaUserId)) {
      isAdmin = true;
    }

    CollectionRef.offers.doc(widget.offerId).snapshots().listen((model) {
      offerModel = OfferModel.fromMap(model.data() as Map<String, dynamic>);

      offerAcceptors = offerModel!.individualOfferDataModel?.offerAcceptors;
      offerInvites = offerModel!.individualOfferDataModel?.offerInvites;

      try {
        logger.i("UPDATE==============================");
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
      return Container();
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
              user.sevaUserID == offerModel!.sevaUserId);

          if (userList.length == 0) {
            return getEmptyWidget(S.of(context).no_user_found);
          }
          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              UserModel user = userList[index];

              return OfferCardWidget(
                offerId: widget.offerId,
                userModel: user,
                timebankModel: widget.timebankModel,
                memberInvited: false,
                offerAcceptors: offerAcceptors!,
                offerInvites: offerInvites!,
                offerModel: offerModel!,
              );
            },
          );
        },
      );
    }
  }

  void refresh() {
    CollectionRef.offers.doc(widget.offerId).snapshots().listen((model) {
      offerModel = OfferModel.fromMap(model.data() as Map<String, dynamic>);
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
