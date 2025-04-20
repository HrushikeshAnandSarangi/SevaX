import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';
import 'package:sevaexchange/repositories/timebank_repository.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';

List<NotificationType> dismissiableNotification = [
  NotificationType.RequestScheduleReminder,
  NotificationType.RecurringRequestUpdated,
  NotificationType.RecurringOfferUpdated,
  // NotificationType.RequestInvite,
  NotificationType.RequestReject,
  NotificationType.RequestCompletedApproved,
  NotificationType.RequestCompletedRejected,
  NotificationType.TransactionCredit,
  NotificationType.TransactionDebit,
  NotificationType.OfferAccept,
  NotificationType.OfferReject,
  NotificationType.AcceptedOffer,
  NotificationType.TypeMemberExitTimebank,
  NotificationType.TypeMemberAdded,
  NotificationType.TypeMemberJoinViaCode,
  NotificationType.TYPE_DEBIT_FROM_OFFER,
  NotificationType.TYPE_CREDIT_FROM_OFFER_ON_HOLD,
  NotificationType.TYPE_CREDIT_FROM_OFFER_APPROVED,
  NotificationType.TYPE_CREDIT_FROM_OFFER,
  NotificationType.TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK,
  NotificationType.TYPE_NEW_MEMBER_SIGNUP_OFFER,
  NotificationType.TYPE_OFFER_FULFILMENT_ACHIEVED,
  NotificationType.TYPE_OFFER_SUBSCRIPTION_COMPLETED,
  NotificationType.TYPE_DELETION_REQUEST_OUTPUT,
  NotificationType.TYPE_REPORT_MEMBER,
  NotificationType.APPROVED_MEMBER_WITHDRAWING_REQUEST,
  NotificationType.OFFER_CANCELLED_BY_CREATOR,
  NotificationType.DEBITED_SEVA_COINS_TIMEBANK,
  NotificationType.SEVA_COINS_DEBITED,
  NotificationType.SEVA_COINS_CREDITED,
  NotificationType.ADMIN_DEMOTED_FROM_ORGANIZER,
  NotificationType.ADMIN_PROMOTED_AS_ORGANIZER,
  NotificationType.MEMBER_PROMOTED_AS_ADMIN,
  NotificationType.MEMBER_DEMOTED_FROM_ADMIN,
  NotificationType.CASH_DONATION_COMPLETED_SUCCESSFULLY,
  NotificationType.GOODS_DONATION_COMPLETED_SUCCESSFULLY,
  NotificationType.RequestApprove,
  NotificationType.APPROVE_SPONSORED_GROUP_REQUEST,
  NotificationType.MANUAL_TIME_CLAIM_APPROVED,
  NotificationType.MANUAL_TIME_CLAIM_REJECTED,
  NotificationType.MEMBER_ADDED_TO_MESSAGE_ROOM,
  NotificationType.MEMBER_REMOVED_FROM_MESSAGE_ROOM,
  NotificationType.OneToManyRequestInviteAccepted,
  NotificationType.OneToManyCreatorRejectedCompletion,
];

//Not dismissiable notifications
// RequestAccept,
// RequestApprove,
// RequestCompleted,
// JoinRequest,
// TypeChangeOwnership,
// GroupJoinInvite,
// TYPE_FEEDBACK_FROM_SIGNUP_MEMBER,
// GOODS_DONATION_REQUEST,
// ACKNOWLEDGE_DONOR_DONATION, //creator and timebank

// CASH_DONATION_MODIFIED_BY_CREATOR, //donor
// GOODS_DONATION_MODIFIED_BY_CREATOR, //donor
// CASH_DONATION_ACKNOWLEDGED_BY_DONOR, //creator and timebank
// GOODS_DONATION_ACKNOWLEDGED_BY_DONOR, //creator and timebank
// CASH_DONATION_MODIFIED_BY_DONOR, //creator and timebank
// GOODS_DONATION_MODIFIED_BY_DONOR, //creator and timebank

class NotificationsBloc extends BlocBase {
  final _personalNotificationCount = BehaviorSubject<int>.seeded(0);
  final _timebankNotificationCount = BehaviorSubject<int>.seeded(0);
  final _personalNotifications = BehaviorSubject<List<NotificationsModel>>();
  final _adminNotificationData = BehaviorSubject<TimebankNotificationData>();
  //Used for clearing all notifications
  List<String> personalNotificationsToBeCleared = [];

  bool checkIfDismissible(NotificationType type) {
    return dismissiableNotification.contains(type);
  }

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
        (p, t) => ((p as int?) ?? 0) + ((t as int?) ?? 0),
      );

  void init(String userEmail, String userId, String communityId) {
    NotificationsRepository.getUserNotifications(userEmail, communityId)
        .listen((QuerySnapshot query) {
      List<NotificationsModel> notifications = [];
      personalNotificationsToBeCleared = [];
      query.docs.forEach((DocumentSnapshot document) {
        var notification = NotificationsModel.fromMap(
          (document.data() ?? {}) as Map<String, dynamic>,
        );
        if (notification.type != null &&
            checkIfDismissible(notification.type!)) {
          if (notification.id != null) {
            personalNotificationsToBeCleared.add(notification.id!);
          }
        }
        notifications.add(notification);
      });
      if (!_personalNotificationCount.isClosed)
        _personalNotificationCount.add(notifications.length);
      if (!_personalNotifications.isClosed)
        _personalNotifications.add(notifications);
    }).onError((error) {
      logger.e("There is an error");
    });

    CombineLatestStream.combine2<List<NotificationsModel>, List<TimebankModel>,
            TimebankNotificationData>(
        NotificationsRepository.getAllTimebankNotifications(communityId),
        TimebankRepository.getAllTimebanksUserIsAdminOf(userId, communityId), (
      List<NotificationsModel> notificationSnapshot,
      List<TimebankModel> timebankSnapshot,
    ) {
      Map<String, List<NotificationsModel>> _adminNotificationsMap = {};
      Map<String, TimebankModel> _adminTimebanks = {};
      var _adminTimebankIds = <String>[];
      int _adminNotificationCount = 0;

      timebankSnapshot.forEach((element) {
        _adminTimebankIds.add(element.id);
        _adminTimebanks[element.id] = element;
      });

      for (NotificationsModel notification in notificationSnapshot) {
        final timebankId = notification.timebankId;
        if (timebankId != null && _adminTimebankIds.contains(timebankId)) {
          final timebankModel = _adminTimebanks[timebankId];
          if (timebankModel != null) {
            var userRole = getLoggedInUserRole(timebankModel, userId);

            if (notification.type == NotificationType.MANUAL_TIME_CLAIM) {
              var data = ManualTimeModel.fromMap(
                Map<String, dynamic>.from(notification.data ?? {}),
              );

              if (!isManualTimeNotificationVisible(
                      userRole,
                      data.claimedBy ?? UserRole.Member,
                      (timebankModel.parentTimebankId ?? '') ==
                          (FlavorConfig.values.timebankId ?? '')) ||
                  (data.userDetails?.id ?? '') == userId) {
                continue;
              }
            }
          }
        }

        if (timebankId != null && _adminTimebankIds.contains(timebankId)) {
          _adminNotificationCount++;
        }
        if (timebankId != null) {
          if (_adminNotificationsMap.containsKey(timebankId)) {
            _adminNotificationsMap[timebankId]?.add(notification);
          } else {
            _adminNotificationsMap[timebankId] = [notification];
          }
        }
      }

      if (!_timebankNotificationCount.isClosed)
        _timebankNotificationCount.add(_adminNotificationCount);
      return TimebankNotificationData(
        notifications: _adminNotificationsMap,
        timebanks: _adminTimebanks,
      );
    }).listen((data) {
      if (!_adminNotificationData.isClosed) _adminNotificationData.add(data);
    });
  }

  Future clearNotification(
      {required String email, required String notificationId}) {
    return NotificationsRepository.readUserNotification(
      notificationId,
      email,
    );
  }

  bool isManualTimeNotificationVisible(
    UserRole userRole,
    UserRole claimedBy,
    bool isGroup,
  ) {
    if (isGroup) {
      return true;
    }
    // if (isGroup && [UserRole.TimebankCreator, UserRole.Organizer,UserRole.Admin].contains(userRole)) {
    //   return true;
    // }
    if (claimedBy == UserRole.Organizer && userRole == UserRole.Creator) {
      return true;
    } else if (claimedBy == UserRole.Admin &&
        [UserRole.Creator, UserRole.Organizer].contains(userRole)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> clearAllNotification(String email,
      {List<String>? notificationIdsToBeCleared}) async {
    var x = notificationIdsToBeCleared ?? personalNotificationsToBeCleared;
    WriteBatch batch = CollectionRef.batch;
    x.forEach((String id) {
      batch.update(
        CollectionRef.users.doc(email).collection("notifications").doc(id),
        {"isRead": true},
      );
    });
    await batch.commit();
  }

  @override
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
    required this.notifications,
    required this.timebanks,
  });

  bool get isAdmin => timebanks.isNotEmpty;
  bool get isNotificationPresent => notifications.isNotEmpty;

  bool isNotificationAvailable() {
    bool status = false;

    timebanks.forEach((key, value) {
      if (notifications.containsKey(key)) {
        if ((notifications[key]?.length ?? 0) == 0) {
          status = false;
        } else {
          status = true;
        }
      }
    });
    return status;
  }
}
