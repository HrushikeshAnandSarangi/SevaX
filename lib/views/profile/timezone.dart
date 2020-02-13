import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

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
          title: Text(
            'My Timezone',
            style: TextStyle(fontSize: 18),
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
      //europian timezones
      TimeZoneModel(
          offsetFromUtc: 0,
          timezoneAbb: 'WET',
          timezoneName: 'Western European Time'),
      TimeZoneModel(
          offsetFromUtc: 1,
          timezoneAbb: 'CET',
          timezoneName: 'Central European Time'),
      TimeZoneModel(
          offsetFromUtc: 2,
          timezoneAbb: 'EET',
          timezoneName: 'Eastern European Time'),
      TimeZoneModel(
          offsetFromUtc: 3, timezoneAbb: 'MSK', timezoneName: 'Moscow Time'),

      //Australia

      TimeZoneModel(
        offsetFromUtc: 11,
        timezoneAbb: 'ACTT',
        timezoneName: 'Australian Capital Territory Time',
      ),

      TimeZoneModel(
        offsetFromUtc: 11,
        timezoneAbb: 'VT',
        timezoneName: 'Victoria Time',
      ),

      TimeZoneModel(
        offsetFromUtc: 11,
        timezoneAbb: 'TT',
        timezoneName: 'Tasmania Time',
      ),

      TimeZoneModel(
        offsetFromUtc: 11,
        timezoneAbb: 'NSWT',
        timezoneName: 'New South Wales Time',
      ),

      TimeZoneModel(
          offsetFromUtc: 10,
          timezoneAbb: 'QT',
          timezoneName: 'Queensland Time'),

      TimeZoneModel(
        offsetFromUtc: 9,
        timezoneAbb: 'NTT',
        timezoneName: 'Northern Territory Time',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'TT',
        timezoneName: 'Tasmania Time',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'WA',
        timezoneName: 'Western Australia (Most)',
      ),
      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'WA',
        timezoneName: 'Western Australia (Eucla)',
      ),
      TimeZoneModel(
        offsetFromUtc: 10,
        timezoneAbb: 'SAT',
        timezoneName: 'South Australia Time',
      ),

      //Asian

      TimeZoneModel(
        offsetFromUtc: 4,
        timezoneAbb: 'AT',
        timezoneName: 'AFGHANISTAN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 6,
        timezoneAbb: 'AAT',
        timezoneName: 'ALMA-ATA TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 4,
        timezoneAbb: 'AT',
        timezoneName: 'ARMENIA TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 5,
        timezoneAbb: 'AMST',
        timezoneName: 'ARMENIA SUMMER TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 11,
        timezoneAbb: 'AT',
        timezoneName: 'ANADYR TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 5,
        timezoneAbb: 'AQTT',
        timezoneName: 'AQTOBE TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 3,
        timezoneAbb: 'ADT',
        timezoneName: 'ARABIA DAYLIGHT TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 3,
        timezoneAbb: 'AST',
        timezoneName: 'ARAB STANDARD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 3,
        timezoneAbb: 'AST',
        timezoneName: 'ARABIA STANDARD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 4,
        timezoneAbb: 'AT',
        timezoneName: 'AZERBAIJAN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 5,
        timezoneAbb: 'AZST',
        timezoneName: 'AZERBAIJAN SUMMER TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'BT',
        timezoneName: 'BRUNEI TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 6,
        timezoneAbb: '',
        timezoneName: 'BANGLADESH TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 6,
        timezoneAbb: 'BST',
        timezoneName: 'BANGLADESH STANDARD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 6,
        timezoneAbb: 'BTT',
        timezoneName: 'BHUTAN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'CHOT',
        timezoneName: 'CHOIBALSAN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 9,
        timezoneAbb: 'CHOST',
        timezoneName: 'CHOIBALSAN SUMMER TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'CST',
        timezoneName: 'CHINA STANDARD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'CT',
        timezoneName: 'CHINA TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 3,
        timezoneAbb: 'EEST',
        timezoneName: 'EASTERN EUROPE SUMMER TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 2,
        timezoneAbb: 'EET',
        timezoneName: 'EASTERN EUROPE TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 4,
        timezoneAbb: 'GET',
        timezoneName: 'GEORGIA STANDARD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 0,
        timezoneAbb: 'GMT',
        timezoneName: 'GREENWICH MEAN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 4,
        timezoneAbb: 'GST',
        timezoneName: 'GULF STANDARD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'HKT',
        timezoneName: 'HONG KONG TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 7,
        timezoneAbb: 'HOVT',
        timezoneName: 'HOVD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 7,
        timezoneAbb: 'ICT',
        timezoneName: 'INDOCHINA TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 3,
        timezoneAbb: 'IDT',
        timezoneName: 'ISRAEL DAYLIGHT TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 4,
        timezoneAbb: 'IRDT',
        timezoneName: 'IRAN DAYLIGHT TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'IRKT',
        timezoneName: 'IRKUTSK TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 9,
        timezoneAbb: 'IRKST',
        timezoneName: 'IRKUTSK SUMMER TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 3,
        timezoneAbb: 'IRST',
        timezoneName: 'IRAN STANDARD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 5,
        timezoneAbb: 'IST',
        timezoneName: 'INDIA STANDARD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 2,
        timezoneAbb: 'IST',
        timezoneName: 'ISRAEL STANDARD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 9,
        timezoneAbb: 'JST',
        timezoneName: 'JAPAN STANDARD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 6,
        timezoneAbb: 'KGT',
        timezoneName: 'KYRGYZSTAN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 7,
        timezoneAbb: 'KRAT',
        timezoneName: 'KRASNOYARSK TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'KST',
        timezoneName: 'KOREA STANDARD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 11,
        timezoneAbb: 'MAGT',
        timezoneName: 'MAGADAN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 6,
        timezoneAbb: 'MMT',
        timezoneName: 'MYANMAR TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 3,
        timezoneAbb: 'MSK',
        timezoneName: 'MOSCOW STANDARD TIME',
      ),
      TimeZoneModel(
        offsetFromUtc: 5,
        timezoneAbb: 'MVT',
        timezoneName: 'MALDIVES TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'MYT',
        timezoneName: 'MALAYSIA TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 6,
        timezoneAbb: 'NOVT',
        timezoneName: 'NOVOSIBIRSK TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 5,
        timezoneAbb: 'NPT',
        timezoneName: 'NEPAL TIME',
      ),
      TimeZoneModel(
        offsetFromUtc: 6,
        timezoneAbb: 'OMST',
        timezoneName: 'OMSK STANDARD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 5,
        timezoneAbb: 'ORAT',
        timezoneName: 'ORAL TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 12,
        timezoneAbb: 'PETT',
        timezoneName: 'KAMCHATKA TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'PHT',
        timezoneName: 'PHILIPPINE TIME',
      ),
      TimeZoneModel(
        offsetFromUtc: 5,
        timezoneAbb: 'PKT',
        timezoneName: 'PAKISTAN STANDARD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'PST',
        timezoneName: 'PYONGYANG TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 11,
        timezoneAbb: 'SAKT',
        timezoneName: 'SAKHALIN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 6,
        timezoneAbb: 'QYZT',
        timezoneName: 'QYZYLORDA TIME',
      ),
      TimeZoneModel(
        offsetFromUtc: 4,
        timezoneAbb: 'SAMT',
        timezoneName: 'SAMARA TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'SGT',
        timezoneName: 'SINGAPORE TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 11,
        timezoneAbb: 'SRAT',
        timezoneName: 'SREDNEKOLYMSK TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 5,
        timezoneAbb: 'TJT',
        timezoneName: 'TAJIKISTAN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 3,
        timezoneAbb: 'TLT',
        timezoneName: 'TURKEY TIME OR TURKISH TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 3,
        timezoneAbb: 'TRT',
        timezoneName: 'TURKMENISTAN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 10,
        timezoneAbb: 'TRUT',
        timezoneName: 'TRUK TIME ',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'ULAT',
        timezoneName: 'ULAANBAATAR TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 5,
        timezoneAbb: 'UZAT',
        timezoneName: 'UZBEKISTAN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 10,
        timezoneAbb: 'VLAT',
        timezoneName: 'VLADIVOSTOK TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 4,
        timezoneAbb: 'VOLT',
        timezoneName: 'VOLGOGRAD TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 7,
        timezoneAbb: 'WIB',
        timezoneName: 'WESTERN INDONESIAN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 9,
        timezoneAbb: 'WIT',
        timezoneName: 'EASTERN INDONESIAN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 8,
        timezoneAbb: 'WITA',
        timezoneName: 'CENTRAL INDONESIAN TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 9,
        timezoneAbb: 'YAKT',
        timezoneName: 'YAKUTSK TIME',
      ),

      TimeZoneModel(
        offsetFromUtc: 5,
        timezoneAbb: 'YEKT',
        timezoneName: 'YEKATERINBURG TIME',
      ),
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
