import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/views/timebanks/timebank_view.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';

class TimeBankList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TimebankCreate(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('timebanks')
            .orderBy('posttimestamp', descending: true)
            .snapshots(),
        builder: (
          BuildContext streamContext,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (BuildContext listContext, int i) {
              Map<String, dynamic> dataMap =
                  Map.castFrom(snapshot.data.documents[i].data);
              TimebankModel model = TimebankModel.fromMap(dataMap);
              model.id = snapshot.data.documents[i].documentID;

              return GestureDetector(
                child: Card(
                  child: Container(
                      padding: EdgeInsets.only(top: 5.0),
                      constraints: BoxConstraints.expand(
                        height: 120.0,
                      ),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: 10,
                            child: CircleAvatar(
                              minRadius: 40.0,
                              backgroundColor: Colors.grey,
                              backgroundImage: _getImage(model),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 100.0, right: 5.0),
                            child: Wrap(
                              children: <Widget>[
                                Text(
                                  model.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 10.0,
                            right: 100.0,
                            child: Icon(
                              Icons.notifications_none,
                              color: Colors.black,
                            ),
                          ),
                          Positioned(
                            bottom: 10.0,
                            right: 145.0,
                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.black,
                            ),
                          ),
                          Positioned(
                            bottom: 10.0,
                            right: 55.0,
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.black,
                            ),
                          ),
                          Positioned(
                            bottom: 10.0,
                            right: 10.0,
                            child: Icon(
                              Icons.share,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      )),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (routeContext) {
                        return TimebankView(timebankId: model.id);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  ImageProvider _getImage(TimebankModel model) {
    if (model.avatarUrl == null) {
      return AssetImage('lib/assets/images/profile.png');
    } else {
      return NetworkImage(model.avatarUrl);
    }
  }
}
