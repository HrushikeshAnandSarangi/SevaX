import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';

class PersonalMessageCard extends StatelessWidget {
  final String photoUrl;
  final String name;
  final String message;
  final int timestamp;
  const PersonalMessageCard({
    Key key,
    this.photoUrl,
    this.name,
    this.message,
    this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: <Widget>[
          InkWell(
            splashColor: Colors.transparent,
            onTap: () => print("clicked"),
            child: Row(
              children: <Widget>[
                photoUrl != null
                    ? CircleAvatar(
                        radius: 30,
                      )
                    : CustomAvatar(
                        name: name,
                        radius: 30,
                      ),
                SizedBox(width: 20),
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
                      Text(
                        message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Divider(
                  thickness: 1,
                  // color: Colors.grey,
                ),
              ),
              SizedBox(width: 20),
              Text(
                "Now 10:00 pm",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
