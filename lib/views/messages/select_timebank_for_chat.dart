import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/members_of_timebank.dart';
import 'package:sevaexchange/views/core.dart';

import '../../flavor_config.dart';

class SelectTimeBankForNewChat extends StatefulWidget {
  @override
  SelectTimeBankForNewChatState createState() =>
      SelectTimeBankForNewChatState();
}

class SelectTimeBankForNewChatState extends State<SelectTimeBankForNewChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlavorConfig.values.timebankName == "Yang 2020"
              ? "Select Yang Gang Chapter"
              : AppLocalizations.of(context).translate('members','select_timebank'),
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: getTimebanks(context),
    );
  }
}

List<String> dropdownList = [];

Widget getTimebanks(BuildContext context) {
  List<TimebankModel> timebankList = [];
  print("Getting data for messages timebanks");
  return StreamBuilder<List<TimebankModel>>(
      stream: FirestoreManager.getTimebanksForUserStream(
        userId: SevaCore.of(context).loggedInUser.sevaUserID,
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        timebankList = snapshot.data;
        timebankList.forEach((t) {
          dropdownList.add(t.id);
        });

        // Navigator.pop(context);
        print("Length -=-=-=-= ${dropdownList.length}");

        return ListView.builder(
            itemCount: timebankList.length,
            itemBuilder: (context, index) {
              TimebankModel timebank = timebankList.elementAt(index);
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  // home: SelectMembersInGroup(FlavorConfig.values.timebankId, HashMap())),
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectMembersFromTimebank(
                        timebankId: timebank.id,
                        newsModel: NewsModel(),
                        isFromShare: false,
                        selectionMode: MEMBER_SELECTION_MODE.NEW_CHAT,
                        userSelected: HashMap(),
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(5),
                  child: Container(
                    margin: EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(timebank.name),
                      ],
                    ),
                  ),
                ),
              );
            });
      });
}
