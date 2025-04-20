import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/manual_time_repository.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/custom_close_button.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

void manualTimeActionDialog(
  BuildContext context,
  String notificationId,
  String timebankId,
  ManualTimeModel model,
) {
  // Future<void> createNotification(UserModel user, ManualTimeModel model) async {
  //   NotificationsModel notificationsModel = NotificationsModel()
  //     ..id = Uuid().generateV4()
  //     ..type = model.status == ClaimStatus.Approved
  //         ? NotificationType.MANUAL_TIME_CLAIM_APPROVED
  //         : NotificationType.MANUAL_TIME_CLAIM_REJECTED
  //     ..data = model.toMap()
  //     ..communityId = user.currentCommunity
  //     ..isTimebankNotification = false
  //     ..timebankId = timebankId
  //     ..senderUserId = user.sevaUserID;

  //   await NotificationsRepository.createNotification(
  //     notificationsModel,
  //     model.userDetails.email,
  //   );
  // }

  showDialog(
    context: context,
    builder: (_context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25.0),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CustomCloseButton(onTap: () => Navigator.of(_context).pop()),
            Container(
              height: 70,
              width: 70,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  model.userDetails!.photoUrl ?? defaultUserImageURL,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                model.userDetails!.name!,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Europa',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "${S.of(context).by_approving_you_accept} ${model.userDetails!.name!} ${S.of(context).has_worked_for_text} ${model.claimedTime! / 60} ${S.of(context).hours_text}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Europa',
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    model.reason!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Europa',
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )),
            Padding(
              padding: EdgeInsets.all(5.0),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    elevation: 2.0,
                    textColor: Colors.white,
                    child: Text(
                      S.of(context).approve,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Europa',
                      ),
                    ),
                    onPressed: () async {
                      //TODO Create transaction for crediting seva credits
                      var _model = model;
                      _model.status = ClaimStatus.Approved;
                      _model.actionBy =
                          SevaCore.of(context).loggedInUser.sevaUserID;

                      await ManualTimeRepository.approveManualCreditClaim(
                        memberTransactionModel:
                            ManualTimeRepository.getMemberTransactionModel(
                          _model,
                        ),
                        timebankTransaction:
                            ManualTimeRepository.getTimebankTransactionModel(
                          _model,
                        ),
                        model: _model,
                        notificationId: notificationId,
                        userModel: SevaCore.of(context).loggedInUser,
                      );
                      Navigator.of(_context).pop();
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      elevation: 2.0,
                      textColor: Colors.white,
                      child: Text(
                        S.of(context).reject,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Europa',
                        ),
                      ),
                      onPressed: () async {
                        // reject the claim
                        var _model = model;
                        _model.status = ClaimStatus.Rejected;
                        _model.actionBy =
                            SevaCore.of(context).loggedInUser.sevaUserID;
                        ManualTimeRepository.rejectManualCreditClaim(
                          model: _model,
                          notificationId: notificationId,
                          userModel: SevaCore.of(context).loggedInUser,
                        );
                        Navigator.of(_context).pop();
                      },
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      );
    },
  );
}

class CreateTransaction {
  static bool? createTransaction({
    TransactionModel? transactionModel,
    ManualTimeModel? manualTimeModel,
    String? notificationId,
  }) {}

  static updateMemberBalance({
    TransactionModel? transactionModel,
  }) {
    CollectionRef.users.doc();
  }
}
