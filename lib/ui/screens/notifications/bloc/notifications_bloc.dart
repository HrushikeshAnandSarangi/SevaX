import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/timebank_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/widgets/APi/notifications_api.dart';

class NotificationsBloc extends BlocBase {
  final _personalNotifications = BehaviorSubject<List<NotificationsModel>>();
  final _timebanksUserIsAdmin = BehaviorSubject<List<TimebankModel>>();
  final _adminNotifications =
      BehaviorSubject<Map<String, List<NotificationsModel>>>();

  Stream<List<NotificationsModel>> get personalNotifications =>
      _personalNotifications.stream;

  Stream<Map<String, List<NotificationsModel>>> get timebankNotifications =>
      _adminNotifications.stream;

  void init(String userEmail, String userId, String communityId) {
    NotificationsApi.getUserNotifications(userEmail, communityId)
        .listen((QuerySnapshot query) {
      List<NotificationsModel> notifications = [];
      query.documents.forEach((DocumentSnapshot document) {
        notifications.add(NotificationsModel.fromMap(document.data));
      });
      _personalNotifications.add(notifications);
    });
    NotificationsApi.getAllTimebankNotifications(communityId)
        .listen((QuerySnapshot snapshot) {
      Map<String, List<NotificationsModel>> _adminNotificationsMap = {};
      snapshot.documents.forEach((DocumentSnapshot document) {
        NotificationsModel notification =
            NotificationsModel.fromMap(document.data);
        if (_adminNotificationsMap.containsKey(notification.timebankId)) {
          _adminNotificationsMap[notification.timebankId].add(notification);
        } else {
          _adminNotificationsMap[notification.timebankId] = [notification];
        }
      });
      print(_adminNotificationsMap);
      _adminNotifications.add(_adminNotificationsMap);
    });

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
    _adminNotifications.close();
  }
}
