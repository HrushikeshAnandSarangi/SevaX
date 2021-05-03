import 'package:flutter/material.dart';

class ExploreEventCard extends StatelessWidget {
  const ExploreEventCard({
    Key key,
    this.photoUrl,
    this.title,
    this.description,
    this.location,
    this.communityName,
    this.time,
    this.date,
    this.memberList,
    this.onTap,
  }) : super(key: key);

  final String photoUrl;
  final String title;
  final String description;
  final String location;
  final String communityName;
  final String time;
  final String date;
  final Widget memberList;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: SizedBox(
                      width: 308,
                      height: double.infinity,
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 24),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  communityName,
                  style: const TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    ...iconText(context, Icons.calendar_today, date),
                    ...iconText(context, Icons.access_time, time),
                    ...iconText(context, Icons.location_on, location),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                memberList ?? Container(),
                SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> iconText(BuildContext context, IconData icon, String text) {
    return text == null || text.isEmpty
        ? []
        : [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                text,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          ];
  }
}

class ExploreRequestCard extends StatelessWidget {
  const ExploreRequestCard({
    Key key,
    this.photoUrl,
    this.title,
    this.description,
    this.location,
    this.communityName,
    this.time,
    this.date,
    this.memberList,
  }) : super(key: key);

  final String photoUrl;
  final String title;
  final String description;
  final String location;
  final String communityName;
  final String time;
  final String date;
  final Widget memberList;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 235,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                bottomLeft: Radius.circular(13),
              ),
              child: SizedBox(
                width: 308,
                height: double.infinity,
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 24),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            communityName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      ...iconText(context, Icons.calendar_today, date),
                      ...iconText(context, Icons.access_time, time),
                      ...iconText(context, Icons.location_on, location),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  memberList ?? Container(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> iconText(BuildContext context, IconData icon, String text) {
    return text == null || text.isEmpty
        ? []
        : [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                text,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          ];
  }
}

class ExploreOfferCard extends StatelessWidget {
  const ExploreOfferCard({
    Key key,
    this.photoUrl,
    this.title,
    this.description,
    this.location,
    this.communityName,
    this.time,
    this.date,
    this.memberList,
  }) : super(key: key);

  final String photoUrl;
  final String title;
  final String description;
  final String location;
  final String communityName;
  final String time;
  final String date;
  final Widget memberList;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 235,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                bottomLeft: Radius.circular(13),
              ),
              child: SizedBox(
                width: 308,
                height: double.infinity,
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 24),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            communityName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      ...iconText(context, Icons.calendar_today, date),
                      ...iconText(context, Icons.access_time, time),
                      ...iconText(context, Icons.location_on, location),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  memberList ?? Container(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> iconText(BuildContext context, IconData icon, String text) {
    return text == null || text.isEmpty
        ? []
        : [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                text,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          ];
  }
}
