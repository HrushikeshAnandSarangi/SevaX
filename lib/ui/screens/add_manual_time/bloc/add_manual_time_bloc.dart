import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/manual_time_repository.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:uuid/uuid.dart';

class AddManualTimeBloc {
  AddManualTimeBloc() {
    _hours.stream.listen((event) {
      if (_hours.value != null || _hours.value.isNotEmpty) {
        var x = int.tryParse(_hours.value);
        if (x == null) {
          _error.add(true);
        } else {
          _error.add(false);
        }
      }
    });
  }
  final _reason = BehaviorSubject<String>();
  final _hours = BehaviorSubject<String>();
  final _minutes = BehaviorSubject<String>();
  final _error = BehaviorSubject<bool>();

  void onReasonChanged(String value) {
    if (value != null && value.isNotEmpty) {
      _reason.add(value);
    } else {
      _reason.addError('error');
    }
  }

  Function(String) get onHoursChanged => _hours.sink.add;
  Function(String) get onMinutesChanged => _minutes.sink.add;

  Stream<String> get reason => _reason.stream;
  Stream<String> get hours => _hours.stream;
  Stream<String> get minutes => _minutes.stream;
  Stream<bool> get error => _error.stream;

  Future<bool> claim(
    UserModel user,
    ManualTimeType type,
    String typeId,
    String timebankId,
    String communityName,
    UserRole userType,
  ) async {
    if (_error.value == false && _reason.value != null) {
      String notificationId = Uuid().v4();

      ManualTimeModel model = ManualTimeModel(
        id: Uuid().v4(),
        type: type,
        typeId: typeId,
        userDetails: UserDetails(
          id: user.sevaUserID,
          name: user.fullname,
          photoUrl: user.photoURL,
          email: user.email,
        ),
        claimedTime: _time(),
        communityId: user.currentCommunity,
        reason: _reason.value,
        relatedNotificationId: notificationId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        claimedBy: userType,
        timebankId: timebankId,
        communityName: communityName,
        liveMode: !AppConfig.isTestCommunity,
      );

      NotificationsModel notificationsModel = NotificationsModel()
        ..id = notificationId
        ..type = NotificationType.MANUAL_TIME_CLAIM
        ..data = model.toMap()
        ..communityId = user.currentCommunity
        ..isTimebankNotification = true
        ..timebankId = timebankId
        ..senderUserId = user.sevaUserID;

      try {
        if (userType == UserRole.TimebankCreator) {
          model.actionBy = user.sevaUserID;
          model.status = ClaimStatus.Approved;
          model.relatedNotificationId = null;
          await ManualTimeRepository.createClaim(model);
          await ManualTimeRepository.approveManualCreditClaim(
            memberTransactionModel:
                ManualTimeRepository.getMemberTransactionModel(
              model,
            ),
            timebankTransaction:
                ManualTimeRepository.getTimebankTransactionModel(
              model,
            ),
            model: model,
            notificationId: model.id!,
            userModel: user,
          );
        } else {
          await ManualTimeRepository.createClaim(model);
          await NotificationsRepository.createNotification(
            notificationsModel,
            user.email ?? '',
          );
        }

        return true;
      } catch (e) {
        logger.e(e);
        rethrow;
      }
    } else if (_reason.value == null) {
      _reason.addError('error');
      throw 'No Description';
    } else {
      _error.add(true);
    }

    return false;
  }

  int _time() {
    return 60 * int.parse(_hours.value) + int.parse(_minutes.value ?? '0');
  }

  void dispose() {
    _reason.close();
    _hours.close();
    _minutes.close();
    _error.close();
  }
}
