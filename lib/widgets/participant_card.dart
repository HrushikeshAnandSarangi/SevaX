import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class ParticipantCard extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final double radius;
  final String imageUrl;
  final String name;
  final String? bio;
  final double? rating;
  final VoidCallback? onMessageTapped;
  final VoidCallback? onTap;
  final VoidCallback? onImageTap;
  final Widget buttonsContainer;

  const ParticipantCard({
    Key? key,
    this.padding,
    this.radius = 8,
    required this.imageUrl,
    required this.name,
    this.bio,
    this.onMessageTapped,
    this.onTap,
    this.rating,
    this.onImageTap,
    this.buttonsContainer = const SizedBox(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                                // SmoothStarRating(
                                //   allowHalfRating: true,
                                //   size: 20,
                                //   rating: rating ?? 5.0,
                                //   filledIconData: Icons.star,
                                //   color: Theme.of(context).accentColor,
                                //   defaultIconData: Icons.star,
                                //   borderColor: Colors.grey,
                                // )
                              ],
                            ),
                          ),
                          Transform(
                            transform: Matrix4.rotationY(math.pi),
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: Icon(
                                Icons.chat_bubble,
                              ),
                              color: Colors.black,
                              onPressed: onMessageTapped,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        bio ?? S.of(context).bio_not_updated,
                      ),
                      SizedBox(height: 8),
                      buttonsContainer
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
                  child: CustomNetworkImage(
                    imageUrl ?? defaultUserImageURL,
                    fit: BoxFit.cover,
                    onTap: onImageTap ?? () {},
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

class RequestParticipantCard extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final double radius;
  final String imageUrl;
  final String name;
  final String bio;
  final VoidCallback onTap;
  final Color buttonColor;
  final String buttonTitle;

  const RequestParticipantCard({
    Key? key,
    this.padding,
    this.radius = 8,
    required this.imageUrl,
    required this.name,
    required this.bio,
    required this.onTap,
    required this.buttonColor,
    required this.buttonTitle,
  }) : super(key: key);
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 2,
                            textColor: Colors.white,
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
