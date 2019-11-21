import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/views/exchange/createoffer.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';
import 'package:sevaexchange/views/messages/new_select_member.dart';
import 'package:sevaexchange/views/news/newscreate.dart';

import '../../flavor_config.dart';

class SelectTimeBankForNewRequest extends StatefulWidget {
  @override
  String isFrom;
  SelectTimeBankForNewRequest(this.isFrom);
  SelectTimeBankForNewRequestState createState() =>
      SelectTimeBankForNewRequestState();
}

class SelectTimeBankForNewRequestState
    extends State<SelectTimeBankForNewRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlavorConfig.values.timebankName == "Yang 2020"
              ? "My Yang Gang Chapters"
              : "My ${FlavorConfig.values.timebankTitle}",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: getTimebanks(context,widget.isFrom),
    );
  }
}

List<String> dropdownList = [];

Widget getTimebanks(BuildContext context,String isFrom) {
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
                  prefix0.Navigator.pop(context);

                  if (isFrom == "Offer") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateOffer(
                          timebankId: timebank.id,
                        ),
                      ),
                    );

                  } else if (isFrom == "Request") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateRequest(
                          timebankId: timebank.id,
                        ),
                      ),
                    );

                  } else if (isFrom == "Feed") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsCreate(
                          timebankId: timebank.id,
                        ),
                      ),
                    );

                  } else {
                    return;
                  }

//                  Navigator.push(
//                    context,
//                    MaterialPageRoute(
//                      builder: (context) => SelectMember(
//                        timebankId: timebank.id,
//                      ),
//                    ),
//                  );
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
