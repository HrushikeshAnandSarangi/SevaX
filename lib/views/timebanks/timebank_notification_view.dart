import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeBankNotificationView extends StatefulWidget {
  final String timebankId;

  const TimeBankNotificationView({Key key, this.timebankId}) : super(key: key);
  @override
  _TimeBankNotificationViewState createState() =>
      _TimeBankNotificationViewState();
}

class _TimeBankNotificationViewState extends State<TimeBankNotificationView> {
  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('timebanknew')
            .document(widget.timebankId)
            .collection('notifications')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load data'),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return Container(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: ListTile(
                      leading: CircleAvatar(),
                      title: Text('Amman'),
                      subtitle: Text('Task Completion rejected'),
                    ),
                  );
                },
              ),
            );
          }
          return Center(
            child: Text('Failed to load data'),
          );
        },
      ),
    );
  }
}
