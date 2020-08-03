import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/utils.dart';

//bsnl@123

class NearbySettingsWidget extends StatefulWidget {
  final UserModel loggedInUser;
  NearbySettingsWidget(this.loggedInUser);

  @override
  State<StatefulWidget> createState() => _NearbySettingsWidgetState();

  static int evaluatemaxRadiusForMember(NearBySettings nearBySettings) {
    int DEFAULT_RADIUS_IN_MILES = 10;
    if (nearBySettings != null &&
        nearBySettings.radius != null &&
        nearBySettings.isMiles != null) {
      if (!nearBySettings.isMiles) {
        var milesEqvivalant = (nearBySettings.radius * 1.6093).toInt();
        return milesEqvivalant;
      }

      return nearBySettings.radius.toInt();
    }
    return DEFAULT_RADIUS_IN_MILES;
  }

  static int valueForSeekBar(NearBySettings nearBySettings) {
    print("------------------------- ");
    int DEFAULT_RADIUS_IN_MILES = 10;
    if (nearBySettings != null &&
        nearBySettings.radius != null &&
        nearBySettings.isMiles != null) {
      print("${nearBySettings.radius}======================");
      return nearBySettings.radius.toInt();
    }
    return DEFAULT_RADIUS_IN_MILES;
  }

  static int isInMiles(NearBySettings nearBySettings) {
    if (nearBySettings != null && nearBySettings.isMiles != null) {
      return nearBySettings.isMiles ? 1 : 2;
    }
    return 1;
  }
}

class _NearbySettingsWidgetState extends State<NearbySettingsWidget> {
  double rating;
  int selectedRadio;
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    rating =
        NearbySettingsWidget.valueForSeekBar(widget.loggedInUser.nearBySettings)
            .toDouble();
    selectedRadio =
        NearbySettingsWidget.isInMiles(widget.loggedInUser.nearBySettings);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          titleAndSubTitle(),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "10",
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  "100",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.height,
            child: CupertinoSlider(
              min: 10,
              max: 100,
              thumbColor: Theme.of(context).primaryColor,
              activeColor: Theme.of(context).primaryColor,
              value: rating,
              onChanged: (newRating) => {
                _debouncer.run(() => NearbySettingBloc.udpateNearbyRadius(
                      email: widget.loggedInUser.email,
                      radius: newRating.toInt(),
                    )),
                setState(() => rating = newRating)
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Radio(
                  activeColor: Theme.of(context).primaryColor,
                  value: 1,
                  groupValue: selectedRadio,
                  onChanged: (val) {
                    setSelectedRadio(val);
                    NearbySettingBloc.isMiles(
                      email: widget.loggedInUser.email,
                      val: true,
                    );
                  },
                ),
              ),
              Container(
                child: Text('Miles'),
              ),
              Container(
                child: Radio(
                  activeColor: Theme.of(context).primaryColor,
                  value: 2,
                  groupValue: selectedRadio,
                  onChanged: (val) {
                    setSelectedRadio(val);
                    NearbySettingBloc.isMiles(
                      email: widget.loggedInUser.email,
                      val: false,
                    );
                  },
                ),
              ),
              Container(
                child: Text('Kilometer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container titleAndSubTitle() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("What is Lorem Ipsum?"),
          SizedBox(
            height: 10,
          ),
          Text(
              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has"),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  void setSelectedRadio(int value) {
    setState(() {
      selectedRadio = value;
    });
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;
  Debouncer({this.milliseconds});
  run(VoidCallback action) {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class NearbySettingBloc {
  static isMiles({String email, bool val}) {
    Firestore.instance.collection('users').document(email).updateData({
      'nearbySettings.isMiles': val,
    });
  }

  static udpateNearbyRadius({
    String email,
    int radius,
  }) {
    Firestore.instance.collection('users').document(email).updateData({
      'nearbySettings.radius': radius,
    });
  }
}
