import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ParticipantCard extends StatelessWidget {
  final Padding padding;
  final double radius;
  final String imageUrl;
  final String name;
  final String bio;
  final double rating;
  final Function onMessageTapped;
  final Function onTap;

  const ParticipantCard({
    Key key,
    this.padding,
    this.radius = 8,
    this.imageUrl,
    this.name,
    this.bio,
    this.onMessageTapped,
    this.onTap,
    this.rating,
  })  : assert(name != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        // aspectRatio: bio == null ? 4 / 2 : 4 / 3,
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
                                  SmoothStarRating(
                                    allowHalfRating: true,
                                    size: 20,
                                    rating: rating ?? 5.0,
                                    filledIconData: Icons.star,
                                    color: Theme.of(context).accentColor,
                                    defaultIconData: Icons.star,
                                    borderColor: Colors.grey,
                                  )
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
                        Text(bio ?? "No bio uploaded."),
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
                    child: CustomNetworkImage(imageUrl ?? defaultUserImageURL)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
