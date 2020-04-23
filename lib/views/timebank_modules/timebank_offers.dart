import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/offers/offer_list_items.dart';
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';

import '../../ui/screens/offers/pages/create_offer.dart' as prefix0;

class OffersModule extends StatefulWidget {
  final String communityId;
  final String timebankId;
  final TimebankModel timebankModel;
  OffersModule.of({this.timebankId, this.timebankModel, this.communityId});
  @override
  OffersState createState() => OffersState();
}

class OffersState extends State<OffersModule> {
  String timebankId;
  _setORValue() {
    globals.orCreateSelector = 1;
  }

  bool isNearme = false;
  int sharedValue = 0;
  @override
  Widget build(BuildContext context) {
    _setORValue();
    timebankId = widget.timebankModel.id;
    return Column(
      children: <Widget>[
        Offstage(
          offstage: false,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 12),
                child: Row(
                  children: <Widget>[
                    Text(
                      'My Offers',
                      style: (TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      )),
                    ),
                    TransactionLimitCheck(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => prefix0.CreateOffer(
                                timebankId: timebankId,
                                // communityId: widget.communityId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 10,
                            child: Image.asset("lib/assets/images/add.png"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              Expanded(
                child: Container(),
              ),
              Container(
                width: 120,
                child: CupertinoSegmentedControl<int>(
                  selectedColor: Theme.of(context).primaryColor,
                  children: logoWidgets,
                  borderColor: Colors.grey,
                  padding: EdgeInsets.only(left: 5.0, right: 5.0),
                  groupValue: sharedValue,
                  onValueChanged: (int val) {
                    print(val);
                    if (val != sharedValue) {
                      setState(() {
                        if (isNearme == true)
                          isNearme = false;
                        else
                          isNearme = true;
                      });
                      setState(() {
                        sharedValue = val;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 5),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.white,
          height: 0,
        ),
        isNearme == true
            ? NearOfferListItems(
                parentContext: context,
                timebankId: timebankId,
              )
            : OfferListItems(
                parentContext: context,
                timebankId: timebankId,
              )
      ],
    );
  }

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text(
      'All',
      style: TextStyle(fontSize: 10.0),
    ),
    1: Text(
      'Near Me',
      style: TextStyle(fontSize: 10.0),
    ),
  };
}
