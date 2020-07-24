import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/widgets/APi/notifications_api.dart';

class NotificationsBloc extends BlocBase {
  final _personalNotifications = BehaviorSubject<List<NotificationsModel>>();

  Stream<List<NotificationsModel>> get personalNotifications =>
      _personalNotifications.stream;

  void init(String userEmail, String communityId) {
    NotificationsApi.getUserNotifications(userEmail, communityId)
        .listen((QuerySnapshot query) {
      List<NotificationsModel> notifications = [];
      query.documents.forEach((DocumentSnapshot document) {
        notifications.add(NotificationsModel.fromMap(document.data));
      });
      _personalNotifications.add(notifications);
    });
  }

  Future clearNotification({String email, String notificationId}) {
    return NotificationsApi.readUserNotification(
      notificationId,
      email,
    );
  }

  void dispose() {
    _personalNotifications.close();
  }
}
