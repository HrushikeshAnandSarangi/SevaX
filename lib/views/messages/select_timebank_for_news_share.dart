import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/members_of_timebank.dart';
import 'package:sevaexchange/views/core.dart';

class SelectTimeBankNewsShare extends StatefulWidget {
  final NewsModel newsModel;
  SelectTimeBankNewsShare(this.newsModel);

  @override
  SelectTimeBankForNewsShareState createState() =>
      SelectTimeBankForNewsShareState(newsModel);
}

class SelectTimeBankForNewsShareState extends State<SelectTimeBankNewsShare> {
  NewsModel newsModel;
  SelectTimeBankForNewsShareState(NewsModel newsModel) {
    this.newsModel = newsModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)
              .translate('create_request', 'select_timebank'),
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: getTimebanks(context, newsModel),
    );
  }
}

List<String> dropdownList = [];

Widget getTimebanks(
  BuildContext context,
  NewsModel newsModel,
) {
  List<TimebankModel> timebankList = [];
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
                        newsModel: newsModel,
                        isFromShare: true,
                        selectionMode: MEMBER_SELECTION_MODE.SHARE_FEED,
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
