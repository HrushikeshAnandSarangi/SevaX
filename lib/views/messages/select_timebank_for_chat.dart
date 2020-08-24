import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/members_of_timebank.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

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
          S.of(context).select_group,
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
  return StreamBuilder<List<TimebankModel>>(
      stream: FirestoreManager.getTimebanksForUserStream(
        userId: SevaCore.of(context).loggedInUser.sevaUserID,
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        timebankList = snapshot.data;
        timebankList.forEach((t) {
          dropdownList.add(t.id);
        });

        // Navigator.pop(context);

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            timebank.parentTimebankId ==
                                    FlavorConfig.values.timebankId
                                ? S.of(context).timebank
                                : S.of(context).group,
                            style: TextStyle(fontSize: 8, color: Colors.white),
                          ),
                        ),
                        Text(timebank.name),
                      ],
                    ),
                  ),
                ),
              );
            });
      });
}
