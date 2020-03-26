import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final Function onPressed;

  const GroupCard({
    Key key,
    this.image,
    this.title,
    this.subtitle,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: image,
            fit: BoxFit.fitWidth,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 30,
                  child: FlatButton(
                    shape: StadiumBorder(),
                    color: Colors.grey[300],
                    textColor: Theme.of(context).primaryColor,
                    child: Text("Join"),
                    onPressed: onPressed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
