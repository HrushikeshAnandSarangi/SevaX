import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/views/community/communitycreate.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'timbank_admin_request_list.dart';
import 'package:sevaexchange/views/timebanks/timebank_view.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
import 'package:sevaexchange/views/timebanks/waiting_admin_accept.dart';

import '../core.dart';

class TimeBankRequestList extends StatelessWidget {
  final String timebankid;
  final String title;
  TimebankModel superAdminTimebankModel;
  TimeBankRequestList(
      {@required this.timebankid,
        @required this.title,
        @required this.superAdminTimebankModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //automaticallyImplyLeading: false,
          title: Text(
            "${FlavorConfig.values.timebankTitle} request list",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName)
                );
              },
            )
          ],
        ),
        body: getSubTimebanks(timebankid));
  }

  Widget getSubTimebanks(String timebankId) {
    return StreamBuilder<List<TimebankModel>>(
      stream: getChildTimebanks(
        timebankId: timebankId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        List<TimebankModel> reportedList = snapshot.data;
        return Container(
          child: ListView(
            children: <Widget>[
              getDataScrollView(
                context,
                reportedList,
              ),
              Container(
                height: 100,
              )
            ],
          ),
        );
      },
    );
  }

  Widget getDataScrollView(
      BuildContext context,
      List<TimebankModel> reportedList,
      ) {
    return getContent(context, reportedList);
  }

  Widget getContent(BuildContext context, List<TimebankModel> timebankList) {

    return Column(
      children: <Widget>[
        ...timebankList.map((model) {
          if (model.id == 'ab7c6033-8b82-42df-9f41-3c09bae6c3a2') {
            return Offstage();
          }

          return model.id != FlavorConfig.values.timebankId
              ? GestureDetector(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: CircleAvatar(
                        minRadius: 32.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: _getImage(model),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      child: Expanded(
                        child: Text(
                          model.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TimebankRequestAdminPage(
                      isUserAdmin: model.admins.contains(UserData.shared.user.sevaUserID),
                      timebankId: model.id,
                      userEmail: SevaCore.of(context)
                          .loggedInUser
                          .email,
                    )),
              );
//              Navigator.of(context).push(s
            },
          )
              : Offstage();
        })
      ],
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
