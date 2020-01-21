import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/views/invitation/InviteMembers.dart';
import 'package:sevaexchange/views/workshop/acceptedOffers.dart';

import '../admin_viewe_requests.dart';

class ManageTimebankSeva extends StatelessWidget {
  final TimebankModel timebankModel;

  ManageTimebankSeva.of({this.timebankModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getTitle,
            SizedBox(
              height: 30,
            ),
            viewRequests(context: context),
            viewAcceptedOffers(context: context),
            manageTimebankCodes(context: context),
          ],
        ),
      ),
    );
  }

  Widget viewRequests({BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewRequestsForAdmin(
              timebankModel.id,
            ),
          ),
        );
      },
      child: Text(
        'View requests',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget viewAcceptedOffers({BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AcceptedOffers(
              timebankId: timebankModel.id,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 20),
        child: Text(
          'View accepted offers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget manageTimebankCodes({BuildContext context}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InviteMembers(
              timebankModel.id,
              timebankModel.communityId,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 20),
        child: Text(
          'Invite members via code',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget get getTitle {
    return Text(
      "Manage ${timebankModel.name}",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    );
  }
}
