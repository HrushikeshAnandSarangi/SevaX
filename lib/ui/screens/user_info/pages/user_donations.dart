import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class GoodsAndAmountDonations extends StatefulWidget {
  final Function onTap;
  final bool isTimeBank;
  final String timebankId;
  final bool isGoods;
  final String userId;

  GoodsAndAmountDonations(
      {this.onTap,
      this.isTimeBank,
      this.timebankId,
      this.isGoods,
      this.userId});

  @override
  _GoodsAndAmountDonationsState createState() =>
      _GoodsAndAmountDonationsState();
}

class _GoodsAndAmountDonationsState extends State<GoodsAndAmountDonations> {
  bool isLifeTime = false;
  int timeStamp = 0;
  List<String> timeList = [];
  int selectedItem = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeStamp =
        DateTime.now().subtract(Duration(days: 30)).millisecondsSinceEpoch;
  }

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
              sevaUserId: widget.userId,
              timeFrame: timeStamp,
              isGoods: widget.isGoods,
              isLifeTime: isLifeTime),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
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
                      ? SevaAssetIcon.donateCash
                      : SevaAssetIcon.donateGood,
                  height: 30,
                  width: 30,
                ),
                !widget.isGoods
                    ? Text(
                        ' \$' +
                            '${snapshot.data.toString() ?? 0.toString()} ${widget.isTimeBank ? ' ${S.of(context).raised}' : ' ${S.of(context).donated}'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        ' ${snapshot.data.toString() ?? 0.toString()} ${widget.isTimeBank ? ' ${S.of(context).items_collected}' : ' ${S.of(context).items_donated}'}',
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
