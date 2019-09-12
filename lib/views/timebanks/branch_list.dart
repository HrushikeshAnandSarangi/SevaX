import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/views/timebanks/branch_view.dart';
import 'package:sevaexchange/views/timebanks/timebank_view.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';

class BranchList extends StatelessWidget {
  final String timebankid;
  BranchList({@required this.timebankid,});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Branches',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(
                  context, ModalRoute.withName(Navigator.defaultRouteName));
            },
          )
        ],
      ),
      body: Center(
        child: StreamBuilder<Object>(
          stream: getTimebankModelStream(timebankId: timebankid),
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            TimebankModel rootTB = snapshot.data;
            if (rootTB.children.length < 1 || rootTB.children == null) {
              return Center(
                child: Text('No Branches'),
              );
            } else {
              return ListView.builder(
                itemCount: rootTB.children.length,
                itemBuilder: (BuildContext listContext, int i) {
                  String childTimebankId = rootTB.children.elementAt(i);
                  return StreamBuilder<Object>(
                    stream: getTimebankModelStream(timebankId: childTimebankId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return new Text('Error: ${snapshot.error}');
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Offstage();
                      }
                      TimebankModel model = snapshot.data;
                      return model.id != FlavorConfig.values.timebankId
                          ? GestureDetector(
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
                                          padding: EdgeInsets.only(
                                              left: 100.0, right: 5.0),
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
                                      return BranchView(timebankId: model.id);
                                    },
                                  ),
                                );
                              },
                            )
                          : Offstage();
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  ImageProvider _getImage(TimebankModel model) {
    if (model.photoUrl == null) {
      return AssetImage('lib/assets/images/profile.png');
    } else {
      return NetworkImage(model.photoUrl);
    }
  }
}
