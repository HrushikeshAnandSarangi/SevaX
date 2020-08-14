import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';
import 'package:sevaexchange/repositories/timebank_repository.dart';

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
    NotificationsRepository.getUserNotifications(userEmail, communityId)
        .listen((QuerySnapshot query) {
      List<NotificationsModel> notifications = [];
      query.documents.forEach((DocumentSnapshot document) {
        notifications.add(NotificationsModel.fromMap(document.data));
      });
      _personalNotificationCount.add(notifications.length);
      _personalNotifications.add(notifications);
    }).onError((error) {
      print("There is an error");
    });

    CombineLatestStream.combine2(
        NotificationsRepository.getAllTimebankNotifications(communityId),
        TimebankRepository.getAllTimebanksUserIsAdminOf(userId, communityId),
        (QuerySnapshot notificationSnapshot, QuerySnapshot timebankSnapshot) {
      Map<String, List<NotificationsModel>> _adminNotificationsMap = {};
      Map<String, TimebankModel> _adminTimebanks = {};
      var _adminTimebankIds = <String>[];
      int _adminNotificationCount = 0;

      timebankSnapshot.documents.forEach((DocumentSnapshot document) {
        TimebankModel timebank = TimebankModel.fromMap(document.data);
        _adminTimebankIds.add(document.documentID);
        _adminTimebanks[document.documentID] = timebank;
      });

      notificationSnapshot.documents.forEach((DocumentSnapshot document) {
        NotificationsModel notification =
            NotificationsModel.fromMap(document.data);

        if (_adminTimebankIds.contains(notification.timebankId)) {
          _adminNotificationCount++;
        }
        if (_adminNotificationsMap.containsKey(notification.timebankId)) {
          _adminNotificationsMap[notification.timebankId].add(notification);
        } else {
          _adminNotificationsMap[notification.timebankId] = [notification];
        }
      });
      _timebankNotificationCount.add(_adminNotificationCount);
      return TimebankNotificationData(
        notifications: _adminNotificationsMap,
        timebanks: _adminTimebanks,
      );
    }).listen((data) {
      _adminNotificationData.add(data);
    });
  }

  Future clearNotification({String email, String notificationId}) {
    return NotificationsRepository.readUserNotification(
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

  bool isNotificationAvailable() {
    bool status = false;
    print(" timebanks ${timebanks.keys}");
    print(notifications.keys);
    timebanks.forEach((key, value) {
      if (notifications.containsKey(key)) {
        if (notifications[key].length == 0) {
          status = false;
        } else {
          status = true;
        }
      }
    });
    return status;
  }
}
