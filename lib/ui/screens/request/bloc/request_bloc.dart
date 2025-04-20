import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/repositories/request_repository.dart';
import 'package:sevaexchange/views/exchange/create_request/createrequest.dart';

class RequestBloc {
  final _requests = BehaviorSubject<RequestLists>();
  final _filter = BehaviorSubject<RequestFilter>.seeded(RequestFilter());

  Stream<RequestFilter> get filter => _filter.stream;
  Stream<RequestLists> get requests => _requests.stream;

  Function(RequestFilter) get onFilterChange => _filter.sink.add;

  void init(String timebankId, String userId) {
    var _allRequests =
        RequestRepository.getAllRequestOfTimebank(timebankId, userId)
            .asBroadcastStream();

    CombineLatestStream.combine2<List<RequestModel>, RequestFilter,
        RequestLists>(_allRequests, filter, (models, filter) {
      RequestLists requestLists = RequestLists([], []);
      if (filter.isFilterSelected) {
        for (var model in models) {
          if (filter.timeRequest && model.requestType == RequestType.TIME) {
            if (!model.isFromOfferRequest!)
              requestLists.addRequest(userId, model);
            continue;
          }
          if (filter.cashRequest && model.requestType == RequestType.CASH) {
            requestLists.addRequest(userId, model);
            continue;
          }

          if (filter.oneToManyRequest &&
              model.requestType == RequestType.ONE_TO_MANY_REQUEST) {
            requestLists.addRequest(userId, model);
            continue;
          }

          if (filter.borrowRequest && model.requestType == RequestType.BORROW) {
            requestLists.addRequest(userId, model);
            continue;
          }

          if (filter.goodsRequest && model.requestType == RequestType.GOODS) {
            requestLists.addRequest(userId, model);
            continue;
          }
          if (filter.publicRequest && model.public! ?? false) {
            requestLists.addRequest(userId, model);
            continue;
          }
          if (filter.virtualRequest && model.virtualRequest!) {
            requestLists.addRequest(userId, model);
            continue;
          }
        }
      } else {
        models.forEach((model) {
          if (!model.isFromOfferRequest!)
            requestLists.addRequest(userId, model);
        });
      }
      return requestLists;
    }).listen((value) {
      _requests.add(value);
    });
  }

  void dispose() {
    _requests.close();
    _filter.close();
  }
}

class RequestLists {
  final List<RequestModel> myRequests;
  final List<RequestModel> communityRequests;

  void addRequest(String userId, RequestModel model) {
    if (model.requestMode == RequestMode.PERSONAL_REQUEST &&
        model.sevaUserId == userId) {
      myRequests?.add(model);
    } else {
      communityRequests?.add(model);
    }
  }

  bool get isEmpty => myRequests.isEmpty && communityRequests.isEmpty;

  RequestLists(this.myRequests, this.communityRequests);
}

class RequestFilter {
  final bool timeRequest;
  final bool goodsRequest;
  final bool cashRequest;
  final bool oneToManyRequest;
  final bool borrowRequest;
  final bool publicRequest;
  final bool virtualRequest;

  RequestFilter({
    this.timeRequest = false,
    this.goodsRequest = false,
    this.cashRequest = false,
    this.oneToManyRequest = false,
    this.borrowRequest = false,
    this.publicRequest = false,
    this.virtualRequest = false,
  });

  RequestFilter copyWith({
    bool? timeRequest,
    bool? goodsRequest,
    bool? cashRequest,
    bool? oneToManyRequest,
    bool? borrowRequest,
    bool? publicRequest,
    bool? virtualRequest,
  }) =>
      RequestFilter(
        timeRequest: timeRequest ?? this.timeRequest,
        goodsRequest: goodsRequest ?? this.goodsRequest,
        cashRequest: cashRequest ?? this.cashRequest,
        oneToManyRequest: oneToManyRequest ?? this.oneToManyRequest,
        borrowRequest: borrowRequest ?? this.borrowRequest,
        publicRequest: publicRequest ?? this.publicRequest,
        virtualRequest: virtualRequest ?? this.virtualRequest,
      );

  bool get isFilterSelected =>
      timeRequest ||
      goodsRequest ||
      cashRequest ||
      oneToManyRequest ||
      borrowRequest ||
      publicRequest ||
      virtualRequest;

  bool operator ==(Object other) {
    if (other is RequestFilter) {
      return this.timeRequest == other.timeRequest &&
          this.goodsRequest == other.goodsRequest &&
          this.cashRequest == other.cashRequest &&
          this.oneToManyRequest == other.oneToManyRequest &&
          this.borrowRequest == other.borrowRequest &&
          this.publicRequest == other.publicRequest &&
          this.virtualRequest == other.virtualRequest;
    } else {
      return false;
    }
  }

  bool checkFilter(RequestModel model) {
    if (isFilterSelected) {
      if (timeRequest && model.requestType == RequestType.TIME) {
        return true;
      } else if (cashRequest && model.requestType == RequestType.CASH) {
        return true;
      } else if (oneToManyRequest &&
          model.requestType == RequestType.ONE_TO_MANY_REQUEST) {
        return true;
      } else if (goodsRequest && model.requestType == RequestType.GOODS) {
        return true;
      } else if (borrowRequest && model.requestType == RequestType.BORROW) {
        return true;
      } else if (publicRequest && model.public!) {
        return true;
      } else if (virtualRequest && model.virtualRequest!) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }
}
