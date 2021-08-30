import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class LendingParticipantCard extends StatelessWidget {
  final Padding padding;
  final double radius;
  final String imageUrl;
  final String name;
  final int acceptTime;
  final double rating;
  final Function onMessageTapped;
  final Function onTap;
  final Function onImageTap;
  final Widget buttonsContainer;

  const LendingParticipantCard(
      {Key key,
      this.padding,
      this.radius = 8,
      this.imageUrl,
      this.name,
      this.acceptTime,
      this.onMessageTapped,
      this.onTap,
      this.rating,
      this.onImageTap,
      this.buttonsContainer = const SizedBox()})
      : assert(name != null, acceptTime != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.94,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 25,
                  child: ClipOval(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CustomNetworkImage(
                        imageUrl ?? defaultUserImageURL,
                        fit: BoxFit.cover,
                        onTap: onImageTap,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      child: Text(
                        name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      acceptTime != null
                          ? DateFormat(
                                  'MMMM dd, yyyy @ h:mm a',
                                  Locale(AppConfig.prefs
                                          .getString('language_code'))
                                      .toLanguageTag())
                              .format(
                              getDateTimeAccToUserTimezone(
                                dateTime: DateTime.fromMillisecondsSinceEpoch(
                                    acceptTime),
                                timezoneAbb:
                                    SevaCore.of(context).loggedInUser.timezone,
                              ),
                            )
                          : S.of(context).error_loading_data,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                SizedBox(width: 8),
                buttonsContainer
              ],
            ),
            Divider(
              color: Colors.grey[100],
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class RequestParticipantCard extends StatelessWidget {
  final Padding padding;
  final double radius;
  final String imageUrl;
  final String name;
  final String bio;
  final VoidCallback onTap;
  final Color buttonColor;
  final String buttonTitle;

  const RequestParticipantCard({
    Key key,
    this.padding,
    this.radius = 8,
    this.imageUrl,
    this.name,
    this.bio,
    this.onTap,
    this.buttonColor,
    this.buttonTitle,
  })  : assert(name != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              elevation: 4,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(60, 35, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        bio ?? S.of(context).bio_not_updated,
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 30,
                          child: CustomElevatedButton(
                            color: buttonColor,
                            child: Text(
                              buttonTitle,
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            onPressed: onTap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: MediaQuery.of(context).size.width * 0.2 - 60,
            child: CircleAvatar(
              radius: 35,
              child: ClipOval(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: imageUrl != null
                      ? CustomNetworkImage(
                          imageUrl,
                          fit: BoxFit.cover,
                        )
                      : CustomAvatar(
                          name: name,
                        ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
