import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class UserDonations extends StatefulWidget {
  final Function onTap;
  final bool isTimeBank;
  final String timebankId;
  final bool isGoods;

  UserDonations({this.onTap, this.isTimeBank, this.timebankId, this.isGoods});

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
          ? FirestoreManager.getTimebankRaisedAmountAndGoods(
              timebankId: widget.timebankId,
              timeFrame: timeStamp,
              isGoods: widget.isGoods,
              isLifeTime: isLifeTime)
          : FirestoreManager.getUserDonatedGoodsAndAmount(
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
              timeFrame: timeStamp,
              isGoods: widget.isGoods,
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
                Image.asset(
                  !widget.isGoods
                      ? 'lib/assets/images/dollar.jpeg'
                      : 'lib/assets/images/goods.jpeg',
                ),
                !widget.isGoods
                    ? Text(
                        ' \$' +
                            '${snapshot.data.toString() ?? 0.toString()} ${widget.isTimeBank ? ' Raised' : ' Donated'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        ' ${snapshot.data.toString() ?? 0.toString()} ${widget.isTimeBank ? ' Items Collected' : ' Items Donated'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                Spacer(),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
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
