import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/timebank_message_page.dart';
import 'package:sevaexchange/ui/utils/avatar.dart';

class AdminMessageCard extends StatelessWidget {
  final AdminMessageWrapperModel model;
  const AdminMessageCard({
    Key key,
    this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: <Widget>[
          InkWell(
            splashColor: Colors.transparent,
            onTap: () => Navigator.of(context).push(
              TimebankMessagePage.route(adminMessageWrapperModel: model),
            ),
            child: Row(
              children: <Widget>[
                model.photoUrl != null
                    ? CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            CachedNetworkImageProvider(model.photoUrl),
                      )
                    : CustomAvatar(
                        name: model.name,
                        radius: 30,
                      ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      model.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      color: Colors.grey[300],
                      child: Row(
                        children: <Widget>[
                          Text("13 new messages"),
                          Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ],
                ),
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
