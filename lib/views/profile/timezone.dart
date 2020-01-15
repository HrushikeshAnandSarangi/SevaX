import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';

//import 'package:timezone/timezone.dart';

class TimezoneView extends StatefulWidget {
  @override
  _TimezoneViewState createState() => _TimezoneViewState();
}

class _TimezoneViewState extends State<TimezoneView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'My Timezone',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: TimezoneList());
  }
}

class TimezoneList extends StatefulWidget {
  @override
  TimezoneListState createState() => TimezoneListState();
}

class TimezoneListState extends State<TimezoneList> {
  List<TimeZoneModel> timezonelist = [];
  String isSelected;
  @override
  void initState() {
    timezonelist = [
      TimeZoneModel(
          offsetFromUtc: -11,
          timezoneAbb: 'ST',
          timezoneName: 'Samoa Standard Time'),
      TimeZoneModel(
          offsetFromUtc: -10,
          timezoneAbb: 'HAT',
          timezoneName: 'Hawaii-Aleutian Standard Time'),
      TimeZoneModel(
          offsetFromUtc: -9,
          timezoneAbb: 'AKT',
          timezoneName: 'Alaska Standard Time'),
      TimeZoneModel(
          offsetFromUtc: -8,
          timezoneAbb: 'PT',
          timezoneName: 'Pacific Standard Time'),
      TimeZoneModel(
          offsetFromUtc: -7,
          timezoneAbb: 'MT',
          timezoneName: 'Mountain Standard Time'),
      TimeZoneModel(
          offsetFromUtc: -6,
          timezoneAbb: 'CT',
          timezoneName: 'Central Standard Time'),
      TimeZoneModel(
          offsetFromUtc: -5,
          timezoneAbb: 'ET',
          timezoneName: 'Eastern Standard Time'),
      TimeZoneModel(
          offsetFromUtc: -4,
          timezoneAbb: 'AST',
          timezoneName: 'Atlantic Standard Time'),
      TimeZoneModel(
          offsetFromUtc: 10,
          timezoneAbb: 'ChT',
          timezoneName: 'Chamorro Standard Time'),
      TimeZoneModel(
          offsetFromUtc: 12,
          timezoneAbb: 'WIT',
          timezoneName: 'Wake Island Time Zone'),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: FirestoreManager.getUserForId(
            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          UserModel userModel = snapshot.data;
          isSelected = userModel.timezone;
          return ListView.builder(
            itemCount: timezonelist.length,
            itemBuilder: (context, index) {
              TimeZoneModel model = timezonelist.elementAt(index);
              DateFormat format = DateFormat('dd/MMM/yyyy HH:mm');
              DateTime timeInUtc = new DateTime.now().toUtc();

              DateTime localtime =
                  timeInUtc.add(Duration(hours: model.offsetFromUtc));
              //     String color = 'white';
              // if(isSelected==model.timezoneAbb){
              //    color='green';
              // }
              return Card(
                child: ListTile(
                  leading: getIcon(isSelected, model.timezoneAbb),
                  trailing: Text(
                    '${model.timezoneAbb}',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  title: Text('${model.timezoneName}'),
                  subtitle: Text('${format.format(localtime)}'),
                  onTap: () {
                    setState(() {
                      userModel.timezone = model.timezoneAbb;
                      updateUser(user: userModel);
                    });
                  },
                ),
              );
            },
          );
        });
  }

  Widget getIcon(String isSelected, String userTimezone) {
    if (isSelected == userTimezone) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Icon(
          Icons.done,
          color: Colors.green,
          size: 28,
        ),
      );
    } else {
      return null;
    }
  }
}

class TimeZoneModel {
  String timezoneName;
  int offsetFromUtc;
  String timezoneAbb;

  TimeZoneModel({this.timezoneName, this.offsetFromUtc, this.timezoneAbb});
}
