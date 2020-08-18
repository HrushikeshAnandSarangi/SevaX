import 'package:flutter/material.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/views/requests/donations/accept_modified_acknowlegement.dart';

class ModifyDonationDataHolder {
  String requestTitle;
  RequestMode requestMode;
  String creatorSevaUserId;
  String description;
  String donationAmount;
  String entityTitle;
  String entityImageURL;
  String donorEmail;
  String donationId;

  ModifyDonationDataHolder.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('requestTitle')) {
      this.requestTitle = map['requestTitle'];
    }

    if (map.containsKey('requestMode')) {
      if (map['requestMode'] == "PERSONAL_REQUEST") {
        this.requestMode = RequestMode.PERSONAL_REQUEST;
      } else if (map['requestMode'] == "TIMEBANK_REQUEST") {
        this.requestMode = RequestMode.TIMEBANK_REQUEST;
      } else {
        this.requestMode = RequestMode.PERSONAL_REQUEST;
      }
    } else {
      this.requestMode = RequestMode.PERSONAL_REQUEST;
    }

    if (map.containsKey('creatorSevaUserId')) {
      this.creatorSevaUserId = map['creatorSevaUserId'];
    }

    if (map.containsKey('description')) {
      this.description = map['description'];
    }

    if (map.containsKey('donationAmount')) {
      this.donationAmount = map['donationAmount'];
    }

    if (map.containsKey('entityImageURL')) {
      this.entityImageURL = map['entityImageURL'];
    }

    if (map.containsKey('entityTitle')) {
      this.entityTitle = map['entityTitle'];
    }

    if (map.containsKey('donorEmail')) {
      this.donorEmail = map['donorEmail'];
    }

    if (map.containsKey('donationId')) {
      this.donationId = map['donationId'];
    }
  }
}

class PersonalNotificationsRedcerForDonations {
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
    final holder = ModifyDonationDataHolder.fromMap(notificationsModel.data);

    return NotificationCard(
      entityName: "Your pledged was modified",
      title: "Please click to see the details",
      subTitle: "Your pledged was modified",
      onDismissed: onDismissed,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return HandleModifiedAcknowlegementForDonation(
              builder: HandleModifiedAcknowlegementForDonationBuilder()
                ..notificationId = notificationsModel.id
                ..timeBankId = notificationsModel.timebankId
                ..communityId = notificationsModel.communityId
                ..userId = notificationsModel.targetUserId
                ..requestTitle = holder.requestTitle
                ..requestMode = holder.requestMode
                ..creatorSevaUserId = holder.creatorSevaUserId
                ..description = holder.description
                ..donationAmount = holder.donationAmount
                ..entityTitle = holder.entityTitle
                ..entityImageURL = holder.entityImageURL
                ..donorEmail = holder.donorEmail
                ..donationId = holder.donationId
                ..parentContext = context,
            );
          },
        );
      },
    );
  }
}
