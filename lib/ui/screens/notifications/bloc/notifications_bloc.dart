import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/widgets/APi/notifications_api.dart';
import 'package:sevaexchange/widgets/APi/timebank_api.dart';

class NotificationsBloc extends BlocBase {
  final _personalNotificationCount = BehaviorSubject<int>.seeded(0);
  final _timebankNotificationCount = BehaviorSubject<int>.seeded(0);
  final _personalNotifications = BehaviorSubject<List<NotificationsModel>>();
  final _adminNotificationData = BehaviorSubject<TimebankNotificationData>();

  Stream<List<NotificationsModel>> get personalNotifications =>
      _personalNotifications.stream;

  Stream<TimebankNotificationData> get timebankNotifications =>
      _adminNotificationData.stream;

  Stream<int> get personalNotificationCount =>
      _personalNotificationCount.stream;

  Stream<int> get timebankNotificationCount =>
      _timebankNotificationCount.stream;

  Stream<int> get notificationCount => CombineLatestStream.combine2(
        personalNotificationCount,
        timebankNotificationCount,
        (p, t) => p + t,
      );

  void init(String userEmail, String userId, String communityId) {
    NotificationsApi.getUserNotifications(userEmail, communityId)
        .listen((QuerySnapshot query) {
      List<NotificationsModel> notifications = [];
      query.documents.forEach((DocumentSnapshot document) {
        notifications.add(NotificationsModel.fromMap(document.data));
      });
      _personalNotifications.add(notifications);
    });

    CombineLatestStream.combine2(
        NotificationsApi.getAllTimebankNotifications(communityId),
        TimebankApi.getAllTimebanksUserIsAdminOf(userId, communityId),
        (QuerySnapshot notificationSnapshot, QuerySnapshot timebankSnapshot) {
      Map<String, List<NotificationsModel>> _adminNotificationsMap = {};
      Map<String, TimebankModel> _adminTimebanks = {};

      notificationSnapshot.documents.forEach((DocumentSnapshot document) {
        NotificationsModel notification =
            NotificationsModel.fromMap(document.data);
        if (_adminNotificationsMap.containsKey(notification.timebankId)) {
          _adminNotificationsMap[notification.timebankId].add(notification);
        } else {
          _adminNotificationsMap[notification.timebankId] = [notification];
        }
      });

      timebankSnapshot.documents.forEach((DocumentSnapshot document) {
        TimebankModel timebank = TimebankModel.fromMap(document.data);
        _adminTimebanks[document.documentID] = timebank;
      });

      print(_adminNotificationsMap);
      print(_adminTimebanks);

      return TimebankNotificationData(
        notifications: _adminNotificationsMap,
        timebanks: _adminTimebanks,
      );
    }).listen((data) {
      _adminNotificationData.add(data);
    });

    // NotificationsApi.getAllTimebankNotifications(communityId)
    //     .listen((QuerySnapshot snapshot) {
    //   Map<String, List<NotificationsModel>> _adminNotificationsMap = {};
    //   snapshot.documents.forEach((DocumentSnapshot document) {
    //     NotificationsModel notification =
    //         NotificationsModel.fromMap(document.data);
    //     if (_adminNotificationsMap.containsKey(notification.timebankId)) {
    //       _adminNotificationsMap[notification.timebankId].add(notification);
    //     } else {
    //       _adminNotificationsMap[notification.timebankId] = [notification];
    //     }
    //   });
    //   print(_adminNotificationsMap);
    //   _adminNotifications.add(_adminNotificationsMap);
    // });

    // TimebankApi.getAllTimebanksUserIsAdminOf(userId, communityId)
    //     .listen((QuerySnapshot snapshot) {
    //   List<TimebankModel> _timebanks = [];
    //   Map<String, List<NotificationsModel>> _adminNotifications = {};
    //   snapshot.documents.forEach((DocumentSnapshot document) {
    //     _timebanks.add(TimebankModel(document.data));
    //     NotificationsApi.getTimebankNotifications(document.documentID)
    //         .listen((event) {
    //       _adminNotifications[document.documentID] = [];
    //       event.documents.forEach((element) {
    //         _adminNotifications[document.documentID]
    //             .add(NotificationsModel.fromMap(element.data));
    //       });
    //     });
    //   });
    //   _timebanksUserIsAdmin.add(_timebanks);
    // });
  }

  Future clearNotification({String email, String notificationId}) {
    return NotificationsApi.readUserNotification(
      notificationId,
      email,
    );
  }

  void dispose() {
    _personalNotifications.close();
    _adminNotificationData.close();
    _personalNotificationCount.close();
    _timebankNotificationCount.close();
  }
}

class TimebankNotificationData {
  final Map<String, List<NotificationsModel>> notifications;
  final Map<String, TimebankModel> timebanks;

  TimebankNotificationData({
    @required this.notifications,
    @required this.timebanks,
  });

  bool get isAdmin => timebanks.isNotEmpty;
  bool get isNotificationPresent => notifications.isNotEmpty;
}
