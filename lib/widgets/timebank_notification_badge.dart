import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetActiveTimebankNotifications extends StatelessWidget {
  final String timebankId;

  const GetActiveTimebankNotifications({Key key, this.timebankId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("timebanknew")
          .document(timebankId)
          .collection("notifications")
          .where("isRead", isEqualTo: false)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Icon(
            Icons.notifications_none,
            color: Colors.black,
          );
        }
        if (snapshot.data.documents.length > 0) {
          return Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Icon(Icons.notifications_active, color: Colors.red),
                ),
                Text(
                  "${snapshot.data.documents.length}",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Icon(
            Icons.notifications_none,
            color: Colors.black,
          );
        }
      },
    );
  }
}
