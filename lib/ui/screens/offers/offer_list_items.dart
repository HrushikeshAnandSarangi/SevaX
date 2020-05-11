import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/offer_card.dart';
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
          height: isMyContent ? 0 : 25,
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

  _navigateToOfferDetails(OfferModel model) {
    print(model);
    Navigator.push(
      parentContext,
      MaterialPageRoute(
        builder: (context) => OfferDetailsRouter(offerModel: model),
      ),
    );
  }

  Widget getOfferViewHolder(OfferModel model) {
    return OfferCard(
      isCardVisible: isOfferVisible(
        model,
        SevaCore.of(parentContext).loggedInUser.sevaUserID,
      ),
      isCreator: model.email == SevaCore.of(parentContext).loggedInUser.email,
      title: getOfferTitle(offerDataModel: model),
      subtitle: getOfferDescription(offerDataModel: model),
      offerType: model.offerType,
      startDate: model?.groupOfferDataModel?.startDate,
      selectedAddress: model.selectedAdrress,
      actionButtonLabel: getButtonLabel(
          model, SevaCore.of(parentContext).loggedInUser.sevaUserID),
      buttonColor: isParticipant(parentContext, model)
          ? Colors.grey
          : Theme.of(parentContext).primaryColor,
      onCardPressed: () => _navigateToOfferDetails(model),
      onActionPressed: () => offerActions(parentContext, model),
    );
  }

  BoxDecoration get containerDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(0),
          spreadRadius: 4,
          offset: Offset(0, 3),
          blurRadius: 6,
        )
      ],
      color: Colors.white,
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
    return OfferCard(
      isCardVisible: isOfferVisible(
        model,
        SevaCore.of(parentContext).loggedInUser.sevaUserID,
      ),
      isCreator: model.email == SevaCore.of(parentContext).loggedInUser.email,
      title: getOfferTitle(offerDataModel: model),
      subtitle: getOfferDescription(offerDataModel: model),
      offerType: model.offerType,
      startDate: model?.groupOfferDataModel?.startDate,
      selectedAddress: model.selectedAdrress,
      actionButtonLabel: getButtonLabel(
          model, SevaCore.of(parentContext).loggedInUser.sevaUserID),
      buttonColor: isParticipant(parentContext, model)
          ? Colors.grey
          : Theme.of(parentContext).primaryColor,
      onCardPressed: () => _navigateToOfferDetails(model),
      onActionPressed: () => offerActions(parentContext, model),
    );
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

  _navigateToOfferDetails(OfferModel model) {
    Navigator.push(
      parentContext,
      MaterialPageRoute(
        builder: (context) => OfferDetailsRouter(offerModel: model),
      ),
    );
  }
}
