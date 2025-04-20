import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:shimmer/shimmer.dart';

class GoodsAndAmountDonations extends StatefulWidget {
  final VoidCallback onTap;
  final bool isTimeBank;
  final String timebankId;
  final bool isGoods;
  final String userId;

  GoodsAndAmountDonations({
    required this.onTap,
    required this.isTimeBank,
    required this.timebankId,
    required this.isGoods,
    required this.userId,
  });

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
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies

    super.didChangeDependencies();
    timeStamp = widget.userId == SevaCore.of(context).loggedInUser.sevaUserID
        ? DateTime.now().subtract(Duration(days: 30)).millisecondsSinceEpoch
        : 0;
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
          return Shimmer.fromColors(
            child: Container(
              decoration: ShapeDecoration(
                color: Colors.white.withAlpha(80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Container(
                height: 75,
                color: Colors.transparent,
              ),
            ),
            baseColor: Colors.black.withAlpha(50),
            highlightColor: Colors.white.withAlpha(50),
          );
          //LoadingIndicator();
        }
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            height: 75,
            child: Card(
              elevation: 0.5,
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
                              '${snapshot.data ?? 0} ${widget.isTimeBank ? ' ${S.of(context).raised}' : ' ${S.of(context).donated}'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : Text(
                          ' ${snapshot.data ?? 0} ${widget.isTimeBank ? ' ${S.of(context).items_collected}' : ' ${S.of(context).items_donated}'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                  Spacer(),
                  widget.userId == SevaCore.of(context).loggedInUser.sevaUserID
                      ? DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedItem,
                            onChanged: (value) {
                              switch (value) {
                                case 0:
                                  {
                                    setState(() {
                                      selectedItem = 0;
                                      isLifeTime = false;
                                      timeStamp = DateTime.now()
                                          .subtract(Duration(days: 30))
                                          .millisecondsSinceEpoch;
                                    });
                                  }
                                  break;
                                case 1:
                                  {
                                    setState(() {
                                      selectedItem = 1;
                                      isLifeTime = false;
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
                                      isLifeTime = false;
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
                        )
                      : Offstage(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
