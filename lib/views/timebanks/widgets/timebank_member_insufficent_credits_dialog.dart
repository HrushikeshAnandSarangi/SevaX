import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/new_baseline/models/user_insufficient_credits_model.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class TimebankUserInsufficientCreditsDialog extends StatelessWidget {
  final UserInsufficentCreditsModel? userInsufficientModel;
  final String? timeBankId;
  final String? notificationId;
  final UserModel? userModel;
  final String? memberId;
  final TimebankModel? timebankModel;
  final VoidCallback? onMessageClick;
  final VoidCallback? onDonateClick;

  TimebankUserInsufficientCreditsDialog(
      {this.userInsufficientModel,
      this.timeBankId,
      this.notificationId,
      this.userModel,
      this.memberId,
      this.timebankModel,
      this.onMessageClick,
      this.onDonateClick});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))),
      content: Form(
        //key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getCloseButton(context),
            Container(
              height: 70,
              width: 70,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    userInsufficientModel?.senderPhotoUrl ??
                        defaultUserImageURL),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                userInsufficientModel?.senderName ?? 'Unknown User',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: Text(
                userInsufficientModel?.timebankName ??
                    S.of(context).seva_community_name_not_updated,
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Text(
            //     userExitModel.reason ?? "Reason not mentioned",
            //     maxLines: 5,
            //     overflow: TextOverflow.ellipsis,
            //     textAlign: TextAlign.center,
            //   ),
            // ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: CustomElevatedButton(
                        color: FlavorConfig.values.theme!.colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        elevation: 2.0,
                        textColor: Colors.white,
                        child: Text(
                          S.of(context).message,
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Europa'),
                        ),
                        onPressed: onMessageClick ?? () {},
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      child: CustomElevatedButton(
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        elevation: 2.0,
                        textColor: Colors.white,
                        child: Text(
                          S.of(context).donate,
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Europa'),
                        ),
                        onPressed: onDonateClick ?? () {},
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _getCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        alignment: FractionalOffset.topRight,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'lib/assets/images/close.png',
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}
