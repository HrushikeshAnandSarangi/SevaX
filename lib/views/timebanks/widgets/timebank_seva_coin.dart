import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/views/profile/widgets/seva_coin_widget.dart';

class TimeBankSevaCoin extends StatelessWidget {
  final String communityId;
  const TimeBankSevaCoin({
    Key key, this.communityId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("communities")
          .document(communityId)
          .collection("balance")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        double balance = 0;
        if (snapshot.hasData && snapshot.data != null) {
          snapshot.data.documents.forEach(
            (DocumentSnapshot snap) {
              balance += snap.data["amount"];
            },
          );
          return Center(
            child: SevaCoinWidget(
              amount: balance ?? 0,
              onTap: () => {},
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
