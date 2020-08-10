import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

//import 'package:timezone/timezone.dart';
class TimezoneListData {
  final timezonelist = [
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -11,
        timezoneAbb: 'ST',
        timezoneName: 'Samoa Standard Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -10,
        timezoneAbb: 'HAT',
        timezoneName: 'Hawaii-Aleutian Standard Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -9,
        timezoneAbb: 'AKT',
        timezoneName: 'Alaska Standard Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -9,
        timezoneAbb: 'AKDT',
        timezoneName: 'Alaska Day Light Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -7,
        timezoneAbb: 'MST',
        timezoneName: 'Mountain Day Light Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -6,
        timezoneAbb: 'MDT',
        timezoneName: 'Mountain Day Light Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -8,
        timezoneAbb: 'PT',
        timezoneName: 'Pacific Standard Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -7,
        timezoneAbb: 'PDT',
        timezoneName: 'Pacific Day Light Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -7,
        timezoneAbb: 'MT',
        timezoneName: 'Mountain Standard Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -6,
        timezoneAbb: 'CT',
        timezoneName: 'Central Standard Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -5,
        timezoneAbb: 'CDT',
        timezoneName: 'Central Day Light Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -5,
        timezoneAbb: 'EDT',
        timezoneName: 'Eastern Day Light Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -10,
        timezoneAbb: 'HST',
        timezoneName: 'Hawaii-Aleutian Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -9,
        timezoneAbb: 'HDT',
        timezoneName: 'Hawaii-Aleutian Day Light Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -5,
        timezoneAbb: 'ET',
        timezoneName: 'Eastern Standard Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: -4,
        timezoneAbb: 'AST',
        timezoneName: 'Atlantic Standard Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 10,
        timezoneAbb: 'ChT',
        timezoneName: 'Chamorro Standard Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 12,
        timezoneAbb: 'WIT',
        timezoneName: 'Wake Island Time Zone'),

    //europian timezones

    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 0,
        timezoneAbb: 'WET',
        timezoneName: 'Western European Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 1,
        timezoneAbb: 'CET',
        timezoneName: 'Central European Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 2,
        timezoneAbb: 'EET',
        timezoneName: 'Eastern European Time'),
    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 3,
        timezoneAbb: 'MSK',
        timezoneName: 'Moscow Time'),

    //Australia

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 11,
      timezoneAbb: 'ACTT',
      timezoneName: 'Australian Capital Territory Time',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 11,
      timezoneAbb: 'VT',
      timezoneName: 'Victoria Time',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 11,
      timezoneAbb: 'NSWT',
      timezoneName: 'New South Wales Time',
    ),

    TimeZoneModel(
        offsetFromUtcMin: 0,
        offsetFromUtc: 10,
        timezoneAbb: 'QT',
        timezoneName: 'Queensland Time'),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 9,
      timezoneAbb: 'NTT',
      timezoneName: 'Northern Territory Time',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'TT',
      timezoneName: 'Tasmania Time',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'WA',
      timezoneName: 'Western Australia (Most)',
    ),
    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'WA',
      timezoneName: 'Western Australia (Eucla)',
    ),
    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 10,
      timezoneAbb: 'SAT',
      timezoneName: 'South Australia Time',
    ),

    //Asian

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'AT',
      timezoneName: 'AFGHANISTAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'AAT',
      timezoneName: 'ALMA-ATA TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'AT',
      timezoneName: 'ARMENIA TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'AMST',
      timezoneName: 'ARMENIA SUMMER TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 11,
      timezoneAbb: 'AT',
      timezoneName: 'ANADYR TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'AQTT',
      timezoneName: 'AQTOBE TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'ADT',
      timezoneName: 'ARABIA DAYLIGHT TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'AST',
      timezoneName: 'ARAB STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'AST',
      timezoneName: 'ARABIA STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'AT',
      timezoneName: 'AZERBAIJAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'AZST',
      timezoneName: 'AZERBAIJAN SUMMER TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'BT',
      timezoneName: 'BRUNEI TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'BT',
      timezoneName: 'BANGLADESH TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'BST',
      timezoneName: 'BANGLADESH STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'BTT',
      timezoneName: 'BHUTAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'CHOT',
      timezoneName: 'CHOIBALSAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 9,
      timezoneAbb: 'CHOST',
      timezoneName: 'CHOIBALSAN SUMMER TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'CST',
      timezoneName: 'CHINA STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'CT',
      timezoneName: 'CHINA TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'EEST',
      timezoneName: 'EASTERN EUROPE SUMMER TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 2,
      timezoneAbb: 'EET',
      timezoneName: 'EASTERN EUROPE TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'GET',
      timezoneName: 'GEORGIA STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 0,
      timezoneAbb: 'GMT',
      timezoneName: 'GREENWICH MEAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'GST',
      timezoneName: 'GULF STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'HKT',
      timezoneName: 'HONG KONG TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 7,
      timezoneAbb: 'HOVT',
      timezoneName: 'HOVD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 7,
      timezoneAbb: 'ICT',
      timezoneName: 'INDOCHINA TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'IDT',
      timezoneName: 'ISRAEL DAYLIGHT TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'IRDT',
      timezoneName: 'IRAN DAYLIGHT TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'IRKT',
      timezoneName: 'IRKUTSK TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 9,
      timezoneAbb: 'IRKST',
      timezoneName: 'IRKUTSK SUMMER TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'IRST',
      timezoneName: 'IRAN STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 30,
      offsetFromUtc: 5,
      timezoneAbb: 'IST',
      timezoneName: 'INDIA STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 2,
      timezoneAbb: 'IST',
      timezoneName: 'ISRAEL STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 9,
      timezoneAbb: 'JST',
      timezoneName: 'JAPAN STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'KGT',
      timezoneName: 'KYRGYZSTAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 7,
      timezoneAbb: 'KRAT',
      timezoneName: 'KRASNOYARSK TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'KST',
      timezoneName: 'KOREA STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 11,
      timezoneAbb: 'MAGT',
      timezoneName: 'MAGADAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'MMT',
      timezoneName: 'MYANMAR TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'MSK',
      timezoneName: 'MOSCOW STANDARD TIME',
    ),
    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'MVT',
      timezoneName: 'MALDIVES TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'MYT',
      timezoneName: 'MALAYSIA TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'NOVT',
      timezoneName: 'NOVOSIBIRSK TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'NPT',
      timezoneName: 'NEPAL TIME',
    ),
    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'OMST',
      timezoneName: 'OMSK STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'ORAT',
      timezoneName: 'ORAL TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 12,
      timezoneAbb: 'PETT',
      timezoneName: 'KAMCHATKA TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'PHT',
      timezoneName: 'PHILIPPINE TIME',
    ),
    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'PKT',
      timezoneName: 'PAKISTAN STANDARD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'PST',
      timezoneName: 'PYONGYANG TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 11,
      timezoneAbb: 'SAKT',
      timezoneName: 'SAKHALIN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 6,
      timezoneAbb: 'QYZT',
      timezoneName: 'QYZYLORDA TIME',
    ),
    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'SAMT',
      timezoneName: 'SAMARA TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'SGT',
      timezoneName: 'SINGAPORE TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 11,
      timezoneAbb: 'SRAT',
      timezoneName: 'SREDNEKOLYMSK TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'TJT',
      timezoneName: 'TAJIKISTAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'TLT',
      timezoneName: 'TURKEY TIME OR TURKISH TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 3,
      timezoneAbb: 'TRT',
      timezoneName: 'TURKMENISTAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 10,
      timezoneAbb: 'TRUT',
      timezoneName: 'TRUK TIME ',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'ULAT',
      timezoneName: 'ULAANBAATAR TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'UZAT',
      timezoneName: 'UZBEKISTAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 10,
      timezoneAbb: 'VLAT',
      timezoneName: 'VLADIVOSTOK TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 4,
      timezoneAbb: 'VOLT',
      timezoneName: 'VOLGOGRAD TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 7,
      timezoneAbb: 'WIB',
      timezoneName: 'WESTERN INDONESIAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 9,
      timezoneAbb: 'WIT',
      timezoneName: 'EASTERN INDONESIAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 8,
      timezoneAbb: 'WITA',
      timezoneName: 'CENTRAL INDONESIAN TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 9,
      timezoneAbb: 'YAKT',
      timezoneName: 'YAKUTSK TIME',
    ),

    TimeZoneModel(
      offsetFromUtcMin: 0,
      offsetFromUtc: 5,
      timezoneAbb: 'YEKT',
      timezoneName: 'YEKATERINBURG TIME',
    ),
  ];

  TimezoneListData();

  List<int> getTimezoneData(timezoneName) {
    for (var i = 0; i < timezonelist.length; i++) {
      if (timezonelist[i].timezoneName == timezoneName) {
        return [
          timezonelist[i].offsetFromUtc,
          timezonelist[i].offsetFromUtcMin
        ];
      }
    }
    return [-5, 0];
  }

  String getTimeZoneByCodeData(timezoneCode) {
    for (var i = 0; i < timezonelist.length; i++) {
      if (timezonelist[i].timezoneAbb == timezoneCode) {
        return timezonelist[i].timezoneName;
      }
    }
    return "Pacific Standard Time";
  }

  List<TimeZoneModel> getData() {
    return timezonelist;
  }
}

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
            S.of(context).my_timezone,
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
//  ScrollController _scrollController =   ScrollController();

  @override
  void initState() {
    timezonelist = TimezoneListData().getData();
    timezonelist.sort((a, b) {
      return a.timezoneName
          .toLowerCase()
          .compareTo(b.timezoneName.toLowerCase());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: FirestoreManager.getUserForIdStream(
            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          UserModel userModel = snapshot.data;
          isSelected = userModel.timezone;
          return ListView.builder(
            itemCount: timezonelist.length,
//            controller: _scrollController,
            itemBuilder: (context, index) {
              TimeZoneModel model = timezonelist.elementAt(index);
              DateFormat format = DateFormat(
                  'dd/MMM/yyyy HH:mm',
                  Locale(AppConfig.prefs.getString('language_code'))
                      .toLanguageTag());
              DateTime timeInUtc = DateTime.now().toUtc();

              DateTime localtime = timeInUtc.add(Duration(
                  hours: model.offsetFromUtc, minutes: model.offsetFromUtcMin));
              return Card(
                child: ListTile(
                  leading: getIcon(isSelected, model.timezoneName),
                  trailing: Text(
                    '${model.timezoneAbb}',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  title: Text('${model.timezoneName}'),
                  subtitle: Text('${format.format(localtime)}'),
                  onTap: () async {
                    if (userModel.timezone != model.timezoneName) {
                      userModel.timezone = model.timezoneName;
                      await updateUser(user: userModel);
                    }
                  },
                ),
              );
            },
          );
        });
  }

  Widget getIcon(String isSelected, String userTimezone) {
    if (isSelected == userTimezone) {
//      print("inside if card");
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
  int offsetFromUtcMin;
  String timezoneAbb;

  TimeZoneModel(
      {this.timezoneName,
      this.offsetFromUtc,
      this.timezoneAbb,
      this.offsetFromUtcMin});
}
