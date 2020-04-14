import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/ui/screens/offers/offers_ui.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/group_models/GroupingStrategy.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';


class OfferListItems extends StatelessWidget {
  final String timebankId;
  final BuildContext parentContext;
  String sevaUserId;
  OfferListItems({
    Key key,
    this.parentContext,
    this.timebankId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    sevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
    if (timebankId != 'All') {
      return StreamBuilder<List<OfferModel>>(
        stream: getOffersStream(timebankId: timebankId),
        builder:
            (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<OfferModel> offersList = snapshot.data;
              offersList = filterBlockedOffersContent(
                  context: context, requestModelList: offersList);
              if (offersList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text('No Offers'),
                  ),
                );
              }
              var consolidatedList =
                  GroupOfferCommons.groupAndConsolidateOffers(
                      offersList, SevaCore.of(context).loggedInUser.sevaUserID);
              print("============== $consolidatedList");
              return formatListOffer(consolidatedList: consolidatedList);
          }
        },
      );
    } else {
      print("set stream for offers");
      return StreamBuilder<List<OfferModel>>(
        stream: getAllOffersStream(),
        builder:
            (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<OfferModel> offersList = snapshot.data;
              offersList = filterBlockedOffersContent(
                  context: context, requestModelList: offersList);
              if (offersList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text('No Offers'),
                  ),
                );
              }
              var consolidatedList =
                  GroupOfferCommons.groupAndConsolidateOffers(
                      offersList, SevaCore.of(context).loggedInUser.sevaUserID);
              return formatListOffer(consolidatedList: consolidatedList);
          }
        },
      );
    }
  }

  List<OfferModel> filterBlockedOffersContent(
      {List<OfferModel> requestModelList, BuildContext context}) {
    List<OfferModel> filteredList = [];
    requestModelList.forEach((request) => SevaCore.of(context)
                .loggedInUser
                .blockedMembers
                .contains(request.sevaUserId) ||
            SevaCore.of(context)
                .loggedInUser
                .blockedBy
                .contains(request.sevaUserId)
        ? "Filtering blocked content"
        : filteredList.add(request));
    return filteredList;
  }

  Widget formatListOffer({List<OfferModelList> consolidatedList}) {
    return Expanded(
      child: Container(
        child: ListView.builder(
            itemCount: consolidatedList.length + 1,
            itemBuilder: (context, index) {
              if (index >= consolidatedList.length) {
                return Container(
                  width: double.infinity,
                  height: 65,
                );
              }
              return getOfferWidget(consolidatedList[index]);
            }),
      ),
    );
  }

  Widget getOfferWidget(OfferModelList model) {
    return Container(
      decoration: containerDecoration,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: getOfferView(model),
    );
  }

  Widget getOfferView(OfferModelList offerModelList) {
    switch (offerModelList.getType()) {
      case OfferModelList.TITLE:
        var isMyContent =
            (offerModelList as OfferTitle).groupTitle.contains("My");
        return Container(
          height: isMyContent ? 0 : 18,
          margin: isMyContent
              ? EdgeInsets.all(0)
              : EdgeInsets.fromLTRB(5, 12, 12, 18),
          child: Text(
            GroupOfferCommons.getGroupTitleForOffer(
                groupKey: (offerModelList as OfferTitle).groupTitle),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        );
      case OfferModelList.OFFER:
        return getOfferViewHolder((offerModelList as OfferItem).offerModel);
    }
  }

  Widget getOfferViewHolder(OfferModel model) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            parentContext,
            MaterialPageRoute(
              builder: (context) => OfferCardView(offerModel: model),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      getOfferTitle(offerDataModel: model),
                      // style: Theme.of(parentContext).textTheme.subhead,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      getOfferDescription(offerDataModel: model),
                      style: Theme.of(parentContext).textTheme.subtitle,
                    ),
                    getOfferMetaData(
                      offerModel: model,
                    ),
                    model.email != SevaCore.of(parentContext).loggedInUser.email
                        ? model.offerType == OfferType.INDIVIDUAL_OFFER
                            ? getBottomActionsForIndividualOffer(
                                offerModel: model,
                              )
                            : getBottomActionsForGroupOffer(offerModel: model)
                        : Offstage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getBottomActionsForIndividualOffer({OfferModel offerModel}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(0),
          child: Text(
            'Share',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          onPressed: () {},
        ),
        SizedBox(
          width: 10,
        ),
        getWidgetForAcceptOrRemoveBookmark(offerModel: offerModel),
      ],
    );
  }

  Widget getBottomActionsForGroupOffer({OfferModel offerModel}) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(0),
            child: Text(
              'Share',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: () {},
          ),
          SizedBox(
            width: 10,
          ),
          getWidgetForSignUpOrWithdrawClassOffer(
            offerModel: offerModel,
          )
        ],
      ),
    );
  }

  Widget getOfferMetaData({OfferModel offerModel}) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: offerModel.offerType == OfferType.GROUP_OFFER
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: <Widget>[
          offerModel.offerType == OfferType.GROUP_OFFER
              ? getStatsIcon(
                  label: getFormatedTimeFromTimeStamp(
                    timeStamp: offerModel.groupOfferDataModel.startDate,
                    timeZone: SevaCore.of(parentContext).loggedInUser.timezone,
                  ),
                  icon: Icons.calendar_today)
              : Offstage(),
          offerModel.offerType == OfferType.GROUP_OFFER
              ? getStatsIcon(
                  label: getFormatedTimeFromTimeStamp(
                      timeStamp: offerModel.groupOfferDataModel.startDate,
                      timeZone:
                          SevaCore.of(parentContext).loggedInUser.timezone,
                      format: "h:mm a"),
                  icon: Icons.access_time)
              : Offstage(),
          getStatsIcon(
              label: getOfferLocation(offerDataModel: offerModel),
              icon: Icons.location_on),
        ],
      ),
    );
  }

  Widget getStatsIcon({String label, IconData icon}) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 15,
          color: Colors.grey,
        ),
        SizedBox(
          width: 4,
        ),
        Text(
          label.trim(),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String getTimeFormattedString(int timeInMilliseconds) {
    DateFormat dateFormat = DateFormat('d MMM h:m a ');
    String from = dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
    );
    return from;
  }

  BoxDecoration get containerDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(0),
            spreadRadius: 4,
            offset: Offset(0, 3),
            blurRadius: 6)
      ],
      color: Colors.white,
    );
  }

  Widget getWidgetForAcceptOrRemoveBookmark({OfferModel offerModel}) {
    var isBookmarked = getOfferParticipants(offerDataModel: offerModel)
        .contains(SevaCore.of(parentContext).loggedInUser.sevaUserID);

    return FlatButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.only(left: 10, right: 10),
      color: Theme.of(parentContext).primaryColor,
      child: Text(
        isBookmarked ? '  Bookmarked  ' : '  Bookmark  ',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: () {
        var myUserID = SevaCore.of(parentContext).loggedInUser.sevaUserID;
        Firestore.instance
            .collection("offers")
            .document(offerModel.id)
            .updateData({
          'individualOfferDataModel.offerAcceptors': isBookmarked
              ? FieldValue.arrayRemove([myUserID])
              : FieldValue.arrayUnion([myUserID])
        });
      },
    );
  }

  Widget getWidgetForSignUpOrWithdrawClassOffer({OfferModel offerModel}) {
    var isSubscribed = getOfferParticipants(offerDataModel: offerModel)
        .contains(SevaCore.of(parentContext).loggedInUser.sevaUserID);

    return FlatButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.only(left: 10, right: 10),
      color: Theme.of(parentContext).primaryColor,
      child: Text(
        !isSubscribed ? '  Signup  ' : '  Withdraw  ',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: () {
        var myUserID = SevaCore.of(parentContext).loggedInUser.sevaUserID;
        Firestore.instance
            .collection("offers")
            .document(offerModel.id)
            .updateData({
          'groupOfferDataModel.signedUpMembers': isSubscribed
              ? FieldValue.arrayRemove([myUserID])
              : FieldValue.arrayUnion([myUserID])
        });
      },
    );
  }
}

class NearOfferListItems extends StatelessWidget {
  final String timebankId;
  final BuildContext parentContext;
  const NearOfferListItems({Key key, this.parentContext, this.timebankId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (timebankId != 'All') {
      return StreamBuilder<List<OfferModel>>(
        stream: getNearOffersStream(timebankId: timebankId),
        builder:
            (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<OfferModel> offersList = snapshot.data;
              offersList = filterBlockedOffersContent(
                  context: context, requestModelList: offersList);
              if (offersList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text('No Offers'),
                  ),
                );
              }
              return Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      OfferModel offer = offersList[index];
                      return getOfferWidget(offer);
                    },
                    itemCount: offersList.length,
                  ),
                ),
              );
          }
        },
      );
    } else {
      return StreamBuilder<List<OfferModel>>(
        stream: getNearOffersStream(),
        builder:
            (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              List<OfferModel> offersList = snapshot.data;
              offersList = filterBlockedOffersContent(
                  context: context, requestModelList: offersList);
              if (offersList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text('No Offers'),
                  ),
                );
              }
              return Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      OfferModel offer = offersList[index];
                      return getOfferWidget(offer);
                    },
                    itemCount: offersList.length,
                  ),
                ),
              );
          }
        },
      );
    }
  }

  List<OfferModel> filterBlockedOffersContent(
      {List<OfferModel> requestModelList, BuildContext context}) {
    List<OfferModel> filteredList = [];
    requestModelList.forEach((request) => SevaCore.of(context)
                .loggedInUser
                .blockedMembers
                .contains(request.sevaUserId) ||
            SevaCore.of(context)
                .loggedInUser
                .blockedBy
                .contains(request.sevaUserId)
        ? "Filtering blocked content"
        : filteredList.add(request));
    return filteredList;
  }

  Widget getOfferWidget(OfferModel model) {
    return Container(
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.push(
              parentContext,
              MaterialPageRoute(
                builder: (context) => OfferCardView(offerModel: model),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        getOfferTitle(offerDataModel: model),
                        style: Theme.of(parentContext).textTheme.subhead,
                      ),
                      Text(
                        getOfferDescription(offerDataModel: model),
                        style: Theme.of(parentContext).textTheme.subtitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getTimeFormattedString(int timeInMilliseconds) {
    DateFormat dateFormat = DateFormat('d MMM h:m a ');
    String from = dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
    );
    return from;
  }

  BoxDecoration get containerDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(10),
            spreadRadius: 4,
            offset: Offset(0, 3),
            blurRadius: 6)
      ],
      color: Colors.white,
    );
  }
}

