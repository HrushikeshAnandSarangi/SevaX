import 'dart:collection';

import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';

import '../../flavor_config.dart';

abstract class RequestModelList {
  static const int TITLE = 91;
  static const int REQUEST = 12;

  int getType();
}

class GroupTitle extends RequestModelList {
  final String groupTitle;

  GroupTitle.create({this.groupTitle});

  @override
  int getType() {
    return RequestModelList.TITLE;
  }
}

class RequestItem extends RequestModelList {
  RequestModel requestModel;

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

    List<RequestModelList> consolidatedList = List();

    hashedList.forEach((k, v) {
      consolidatedList.add(GroupTitle.create(groupTitle: k));
      for (var req in v) {
        consolidatedList.add(RequestItem.create(requestModel: req));
      }
    });
    return consolidatedList;
  }

  static HashMap<String, List<RequestModel>> getListHashed(
      {List<RequestModel> requestModelList, String sevaUserId}) {
    HashMap<String, List<RequestModel>> hashMap = new HashMap();

    for (var req in requestModelList) {
      if (req.sevaUserId == sevaUserId) {
        if (hashMap["MyPost"] == null) {
          //create new list
          hashMap["MyPost"] = List();
          hashMap["MyPost"].add(req);
        } else {
          //add to existing
          hashMap["MyPost"].add(req);
        }
      } else {
        if (hashMap["Others"] == null) {
          //create new list
          hashMap["Others"] = List();
          hashMap["Others"].add(req);
        } else {
          //add to existing
          hashMap["Others"].add(req);
        }
      }
    }

    return hashMap;
  }

  static String getGroupTitle({String groupKey}) {
    switch (groupKey) {
      case "MyPost":
        return "My Requests";

      case "Others":
        return (FlavorConfig.appFlavor == Flavor.APP || FlavorConfig.appFlavor == Flavor.SEVA_DEV)
            ? "Timebank Requests"
            : "Timebank Requests";

      default:
        return "Timebank Requests";
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
  final String groupTitle;

  OfferTitle.create({this.groupTitle});

  @override
  int getType() {
    return OfferModelList.TITLE;
  }
}

class OfferItem extends OfferModelList {
  OfferModel offerModel;

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

    List<OfferModelList> consolidatedList = List();

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
      {List<OfferModel> offerModelList, String sevaUserId}) {
    SplayTreeMap<String, List<OfferModel>> hashMap = new SplayTreeMap();

    // offerModelList.sort();

    for (var offer in offerModelList) {
      if (offer.sevaUserId == sevaUserId) {
        if (hashMap["MyOffers"] == null) {
          //create new list
          hashMap["MyOffers"] = List();
          hashMap["MyOffers"].add(offer);
        } else {
          //add to existing
          hashMap["MyOffers"].add(offer);
        }
      } else {
        if (hashMap["Others"] == null) {
          //create new list
          hashMap["Others"] = List();
          hashMap["Others"].add(offer);
        } else {
          //add to existing
          hashMap["Others"].add(offer);
        }
      }
    }

    hashMap.keys.toList()..sort();

    return hashMap;
  }

  static String getGroupTitleForOffer({String groupKey}) {
    switch (groupKey) {
      case "MyOffers":
        return "";
        
      case "Others":
        // return "${FlavorConfig.values.timebankTitle} Offers";
        return 'Timebank Offers';
      default:
        return "Others";
    }
  }
}
