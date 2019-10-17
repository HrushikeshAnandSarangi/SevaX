import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/views/messages/new_select_member.dart';

class SelectTimeBankForNewChat extends StatefulWidget {
  @override
  SelectTimeBankForNewChatState createState() =>
      SelectTimeBankForNewChatState();
}

class SelectTimeBankForNewChatState extends State<SelectTimeBankForNewChat> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text("Select Timebank"),
          ),
          body: abc(context)),
    );
  }
}

List<String> dropdownList = [];

Widget abc(BuildContext context) {
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
        // timebankList.forEach((t){
        //   if(t.name==timebankName){
        //     timebankId=t.id;
        //   }
        // });
        timebankList.forEach((t) {
          dropdownList.add(t.id);
        });

        print("Length ${dropdownList.length}");

        return ListView.builder(
            itemCount: timebankList.length,
            itemBuilder: (context, index) {
              TimebankModel timebank = timebankList.elementAt(index);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectMember(
                        timebankId: timebank.id,
                      ),
                    ),
                  );

                  // home: SelectMember(
                  //   timebankId: "73d0de2c-198b-4788-be64-a804700a88a4",
                  // ),
                  // print("inside tap");
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
