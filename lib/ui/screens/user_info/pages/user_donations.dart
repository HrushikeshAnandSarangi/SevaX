import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class UserDonations extends StatefulWidget {
  final Function onTap;
  final bool isTimeBank;
  final String timebankId;

  UserDonations({this.onTap, this.isTimeBank, this.timebankId});

  @override
  _UserDonationsState createState() => _UserDonationsState();
}

class _UserDonationsState extends State<UserDonations> {
  bool isLifeTime = false;
  int timeStamp = 0;
  List<String> timeList = [];
  int selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    timeList = [
      '30 ${S.of(context).day(30)}',
      '90 ${S.of(context).day(30)}',
      '1 ${S.of(context).year(1)}',
      S.of(context).lifetime
    ];
    return FutureBuilder<int>(
      future: widget.isTimeBank
          ? FirestoreManager.getTimebankRaisedAmount(
              timebankId: widget.timebankId,
              timeFrame: timeStamp,
              isLifeTime: isLifeTime)
          : FirestoreManager.getUserDonatedAmount(
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
              timeFrame: timeStamp,
              isLifeTime: isLifeTime),
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Card(
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.attach_money,
                  color: Colors.orange,
                ),
                Text(
                  '${snapshot.data.toString() ?? 0.toString() + ' Donated'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Spacer(),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
//              style: TextStyle(color: Colors.black),
//              focusColor: Colors.black,
//              iconEnabledColor: Colors.black,
                    value: selectedItem,
                    onChanged: (value) {
                      switch (value) {
                        case 0:
                          {
                            setState(() {
                              timeStamp = DateTime.now()
                                  .subtract(Duration(days: 30))
                                  .millisecondsSinceEpoch;
                              selectedItem = 0;
                            });
                          }
                          break;
                        case 1:
                          {
                            setState(() {
                              selectedItem = 1;
                              timeStamp = DateTime.now()
                                  .subtract(Duration(days: 90))
                                  .millisecondsSinceEpoch;
                            });
                          }
                          break;
                        case 2:
                          {
                            setState(() {
                              selectedItem = 2;
                              timeStamp = DateTime.now()
                                  .subtract(Duration(days: 365))
                                  .millisecondsSinceEpoch;
                            });
                          }
                          break;
                        case 3:
                          {
                            setState(() {
                              selectedItem = 3;
                              isLifeTime = true;
                            });
                          }
                          break;
                      }

                      print(timeStamp);
                    },
                    items: List.generate(
                      timeList.length,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text(
                          timeList[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
