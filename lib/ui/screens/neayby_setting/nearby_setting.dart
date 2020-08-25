import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/utils.dart';

class NearbySettingsWidget extends StatefulWidget {
  final UserModel loggedInUser;
  NearbySettingsWidget(this.loggedInUser);

  @override
  State<StatefulWidget> createState() => _NearbySettingsWidgetState();

  static int evaluatemaxRadiusForMember(NearBySettings nearBySettings) {
    const int DEFAULT_RADIUS_IN_MILES = 10;
    if (nearBySettings != null &&
        nearBySettings.radius != null &&
        nearBySettings.isMiles != null) {
      if (!nearBySettings.isMiles) {
        var milesEqvivalant = (nearBySettings.radius ~/ 1.6093).toInt();
        return milesEqvivalant;
      }

      return nearBySettings.radius.toInt();
    }
    return DEFAULT_RADIUS_IN_MILES;
  }

  static int isInMiles(NearBySettings nearBySettings) {
    if (nearBySettings != null && nearBySettings.isMiles != null) {
      return nearBySettings.isMiles
          ? NearbySettingBloc.MILES_SELECTION
          : NearbySettingBloc.KILOMETERS_SELECTION;
    }
    return 1;
  }
}

class _NearbySettingsWidgetState extends State<NearbySettingsWidget> {
  double rating;
  int selectedRadio;
  final _debouncer = Debouncer(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    selectedRadio =
        NearbySettingsWidget.isInMiles(widget.loggedInUser.nearBySettings);
    rating = NearbySettingBloc.valueForSeekBar(
            widget.loggedInUser.nearBySettings, selectedRadio)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    // log(rating.toString() + "<<<<<<<<<<<<<<<<<");
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
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
                  selectedRadio == NearbySettingBloc.MILES_SELECTION
                      ? '10 M'
                      : '16 Kms',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  selectedRadio == NearbySettingBloc.MILES_SELECTION
                      ? '50 M'
                      : '80 Kms',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.height,
            child: CupertinoSlider(
              min: selectedRadio == NearbySettingBloc.MILES_SELECTION ? 10 : 16,
              max: selectedRadio == NearbySettingBloc.MILES_SELECTION ? 50 : 80,
              divisions:
                  selectedRadio == NearbySettingBloc.MILES_SELECTION ? 8 : 13,
              thumbColor: Theme.of(context).primaryColor,
              activeColor: Theme.of(context).primaryColor,
              value: rating,
              onChanged: (newRating) => {
                _debouncer.run(() => NearbySettingBloc.udpateNearbyRadius(
                      email: widget.loggedInUser.email,
                      radius: newRating.toInt(),
                    )),
                setState(() => rating = newRating),
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Radio(
                  activeColor: Theme.of(context).primaryColor,
                  value: NearbySettingBloc.MILES_SELECTION,
                  groupValue: selectedRadio,
                  onChanged: (val) async {
                    setSelectedRadio(val);
                    await NearbySettingBloc.isMiles(
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
                  value: NearbySettingBloc.KILOMETERS_SELECTION,
                  groupValue: selectedRadio,
                  onChanged: (val) async {
                    setSelectedRadio(val);
                    await NearbySettingBloc.isMiles(
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

  String appendDistanceUnit() {
    return " " +
        (selectedRadio == NearbySettingBloc.MILES_SELECTION ? 'M' : 'Kms');
  }

  Container titleAndSubTitle() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Distance that I am willing to travel",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                double.parse((rating).toStringAsFixed(2)).toString() +
                    appendDistanceUnit(),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
              "This indicates the distance that the user is willing to travel to complete a Request for a Timebank or participate in a Project"),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  void setSelectedRadio(int value) {
    log(value.toString() + "--------------------" + selectedRadio.toString());
    if (value == NearbySettingBloc.MILES_SELECTION) {
      rating = rating / 1.6;
    } else if (value == NearbySettingBloc.KILOMETERS_SELECTION) {
      rating = rating * 1.6;
    }
    NearbySettingBloc.udpateNearbyRadius(
      email: widget.loggedInUser.email,
      radius: rating.toInt(),
    );
    print(rating.toString() + "<<<<<<<<<<<<<<<");
    // selectedRadio = value;
    setState(() {
      selectedRadio = value;
    });
  }
}

class NearbySettingBloc {
  static const int MILES_SELECTION = 1;
  static const int KILOMETERS_SELECTION = 2;
  static int DEFAULT_RADIUS_IN_MILES = 10;
  static int DEFAULT_RADIUS_IN_KILOMETERS = 16;

  static final _debouncer = Debouncer(milliseconds: 800);

  static isMiles({String email, bool val}) async {
    _debouncer.run(() async {
      await Firestore.instance.collection('users').document(email).updateData({
        'nearbySettings.isMiles': val,
      });
    });
  }

  static int valueForSeekBar(NearBySettings nearBySettings, int distanceUnit) {
    if (nearBySettings != null &&
        nearBySettings.radius != null &&
        nearBySettings.isMiles != null) {
      return nearBySettings.radius.toInt();
    }
    return distanceUnit == MILES_SELECTION
        ? DEFAULT_RADIUS_IN_MILES
        : DEFAULT_RADIUS_IN_KILOMETERS;
  }

  static udpateNearbyRadius({
    String email,
    int radius,
  }) async {
    await Firestore.instance.collection('users').document(email).updateData({
      'nearbySettings.radius': radius,
    });
  }
}
