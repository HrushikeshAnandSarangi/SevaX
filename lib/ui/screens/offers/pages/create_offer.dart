import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/offers/pages/individual_offer.dart';
import 'package:sevaexchange/ui/screens/offers/pages/one_to_many_offer.dart';

class CreateOffer extends StatefulWidget {
  final String timebankId;

  const CreateOffer({Key key, this.timebankId}) : super(key: key);
  @override
  _CreateOfferState createState() => _CreateOfferState();
}

class _CreateOfferState extends State<CreateOffer> {
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Create Offer',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: getSwitchForGroupOffer(),
          ),
          Expanded(
            child: IndexedStack(
              index: currentPage,
              children: <Widget>[
                IndividualOffer(
                  timebankId: widget.timebankId,
                ),
                OneToManyOffer(
                  timebankId: widget.timebankId,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getSwitchForGroupOffer() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      width: double.infinity,
      child: CupertinoSegmentedControl<int>(
        selectedColor: Theme.of(context).primaryColor,
        children: logoWidgets,
        borderColor: Colors.grey,

        padding: EdgeInsets.only(left: 0.0, right: 0),
        groupValue: currentPage,
        onValueChanged: (int val) {
          print(val);
          if (val != currentPage) {
            setState(() {
              currentPage = val;
            });
          }
        },
        //groupValue: sharedValue,
      ),
    );
  }

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text(
      'Individual offer',
      style: TextStyle(fontSize: 15.0),
    ),
    1: Text(
      'One to many',
      style: TextStyle(fontSize: 15.0),
    ),
  };
}
