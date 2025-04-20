import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';

abstract class RequestModelList {
  static const int TITLE = 91;
  static const int REQUEST = 12;

  int getType();
}

class GroupTitle extends RequestModelList {
  final String? groupTitle;

  GroupTitle.create({this.groupTitle});

  @override
  int getType() {
    return RequestModelList.TITLE;
  }
}

class RequestItem extends RequestModelList {
  RequestModel? requestModel;

  RequestItem.create({this.requestModel});

  @override
  int getType() {
    return RequestModelList.REQUEST;
  }
}

class GroupRequestCommons {
  static List<RequestModelList> groupAndConsolidateRequests(
      List<RequestModel> requestList, String sevaUserId) {
    var hashedList =
        getListHashed(requestModelList: requestList, sevaUserId: sevaUserId);

    List<RequestModelList> consolidatedList = [];

    hashedList.forEach((k, v) {
      consolidatedList.add(GroupTitle.create(groupTitle: k));
      for (var req in v) {
        consolidatedList.add(RequestItem.create(requestModel: req));
      }
    });
    return consolidatedList;
  }

  static HashMap<String, List<RequestModel>> getListHashed(
      {List<RequestModel>? requestModelList, String? sevaUserId}) {
    HashMap<String, List<RequestModel>> hashMap = HashMap();

    for (var req in requestModelList!) {
      if (req.sevaUserId == sevaUserId) {
        if (hashMap["MyPost"] == null) {
          //create list
          hashMap["MyPost"] = [];
          hashMap["MyPost"]!.add(req);
        } else {
          //add to existing
          hashMap["MyPost"]!.add(req);
        }
      } else {
        if (hashMap["Others"] == null) {
          //create list
          hashMap["Others"] = [];
          hashMap["Others"]!.add(req);
        } else {
          //add to existing
          hashMap["Others"]!.add(req);
        }
      }
    }

    return hashMap;
  }

  static String getGroupTitle(
      {String? groupKey,
      required BuildContext context,
      required bool isGroup}) {
    switch (groupKey) {
      case "MyPost":
        return S.of(context).my_requests;

      case "Others":
        return isGroup
            ? S.of(context).group + ' ' + S.of(context).requests
            : S.of(context).seva_community_requests;

      default:
        return isGroup
            ? S.of(context).group + ' ' + S.of(context).requests
            : S.of(context).seva_community_requests;
    }
  }
}

//For offers

abstract class OfferModelList {
  static const int TITLE = 91;
  static const int OFFER = 12;

  int getType();
}

class OfferTitle extends OfferModelList {
  final String? groupTitle;

  OfferTitle.create({this.groupTitle});

  @override
  int getType() {
    return OfferModelList.TITLE;
  }
}

class OfferItem extends OfferModelList {
  OfferModel? offerModel;

  OfferItem.create({this.offerModel});

  @override
  int getType() {
    return OfferModelList.OFFER;
  }
}

class GroupOfferCommons {
  static List<OfferModelList> groupAndConsolidateOffers(
      List<OfferModel> offerList, String sevaUserId) {
    var hashedList =
        getListHashed(offerModelList: offerList, sevaUserId: sevaUserId);

    List<OfferModelList> consolidatedList = [];

    hashedList.keys.toList()..sort();

    hashedList.forEach((k, v) {
      consolidatedList.add(OfferTitle.create(groupTitle: k));
      for (var req in v) {
        consolidatedList.add(OfferItem.create(offerModel: req));
      }
    });
    return consolidatedList;
  }

  static SplayTreeMap<String, List<OfferModel>> getListHashed(
      {List<OfferModel>? offerModelList, String? sevaUserId}) {
    SplayTreeMap<String, List<OfferModel>> hashMap = SplayTreeMap();

    // offerModelList.sort();

    for (var offer in offerModelList!) {
      if (offer.sevaUserId == sevaUserId) {
        if (hashMap["MyOffers"] == null) {
          //create list
          hashMap["MyOffers"] = [];
          hashMap["MyOffers"]!.add(offer);
        } else {
          //add to existing
          hashMap["MyOffers"]!.add(offer);
        }
      } else {
        if (hashMap["Others"] == null) {
          //create list
          hashMap["Others"] = [];
          hashMap["Others"]!.add(offer);
        } else {
          //add to existing
          hashMap["Others"]!.add(offer);
        }
      }
    }

    hashMap.keys.toList()..sort();

    return hashMap;
  }

  static String getGroupTitleForOffer({
    String? groupKey,
    bool isGroup = false,
    BuildContext? context,
  }) {
    switch (groupKey) {
      case "MyOffers":
        return "";

      case "Others":
        // return "${FlavorConfig.values.timebankTitle} Offers";
        return isGroup
            ? S.of(context!).group + ' ' + S.of(context).offers
            : S.of(context!).timebank_offers;
      default:
        return S.of(context!).other_text;
    }
  }
}
