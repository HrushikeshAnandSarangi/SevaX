import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/views/messages/new_select_member.dart';

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
              : "Select Timebank",
          style: TextStyle(color: Colors.white),
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
        print("Length ${dropdownList.length}");

        return ListView.builder(
            itemCount: timebankList.length,
            itemBuilder: (context, index) {
              TimebankModel timebank = timebankList.elementAt(index);
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectMember(
                        timebankId: timebank.id,
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
