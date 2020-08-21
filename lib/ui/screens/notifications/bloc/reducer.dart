import 'package:flutter/material.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_donation_dispute_page.dart';

class PersonalNotificationsRedcerForDonations {
  static Widget getWidgetForDonationsModifiedByDonor({
    Function onDismissed,
    BuildContext context,
    NotificationsModel notificationsModel,
  }) {
    final holder = DonationModel.fromMap(notificationsModel.data);

    return NotificationCard(
      entityName: "Your pledged was modified by donor",
      title: "Please click to see the details",
      subTitle: "Your pledged was modifiedby donor",
      onDismissed: onDismissed,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RequestDonationDisputePage(
              model: holder,
            ),
          ),
        );
      },
    );
  }

  static Widget getWidgetForSuccessfullDonation({
    Function onDismissed,
  }) {
    return NotificationCard(
      entityName: "Doantion completed successfully",
      title: "Donation completed succesfully",
      subTitle: "You donation was completed successfully",
      onDismissed: onDismissed,
    );
  }

  static getWidgetForDonationsModifiedByCreator({
    Function onDismissed,
    BuildContext context,
    NotificationsModel notificationsModel,
  }) {
    final holder = DonationModel.fromMap(notificationsModel.data);

    return NotificationCard(
      entityName: "Your pledged was modified",
      title: "Please click to see the details",
      subTitle: "Your pledged was modified",
      onDismissed: onDismissed,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RequestDonationDisputePage(
              model: holder,
            ),
          ),
        );
      },
    );
  }
}
