import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/explore_distance_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/strings.dart';
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
      if (nearBySettings.isMiles!) {
        var kmEq = (nearBySettings.radius! * 1.6093).toInt();
        return kmEq;
      }

      return nearBySettings.radius!.toInt();
    }
    return DEFAULT_RADIUS_IN_MILES;
  }

  static int isInMiles(NearBySettings nearBySettings) {
    if (nearBySettings != null && nearBySettings.isMiles != null) {
      return nearBySettings.isMiles!
          ? NearbySettingBloc.MILES_SELECTION
          : NearbySettingBloc.KILOMETERS_SELECTION;
    }
    return 1;
  }
}

class _NearbySettingsWidgetState extends State<NearbySettingsWidget> {
  double? rating;
  int? selectedRadio;
  final _debouncer = Debouncer(milliseconds: 700);
  static const double minKM = 3;
  static const double maxKM = 160;
  static const double minMi = 2;
  static const double maxMi = 100;

  @override
  void initState() {
    super.initState();
    if (widget.loggedInUser?.nearBySettings == null) {
      widget.loggedInUser?.nearBySettings = NearBySettings()
        ..isMiles = true
        ..radius = 10;
    }

    selectedRadio =
        NearbySettingsWidget.isInMiles(widget.loggedInUser.nearBySettings!);
    rating = NearbySettingBloc.valueForSeekBar(
            widget.loggedInUser.nearBySettings!,
            selectedRadio ?? NearbySettingBloc.MILES_SELECTION)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            double value = rating ?? 0.0;
            bool isKm = NearbySettingBloc.KILOMETERS_SELECTION == selectedRadio;

            // if (isKm) {
            //   value = value / 1.609;
            // }
            Navigator.of(context).pop(ExploreDistanceModel(
                (rating ?? 0).toInt(), isKm ? DistancType.km : DistancType.mi));
          },
        ),
        title: Text(
          Strings.filters,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Container(
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
                        ? '$minMi ${Strings.mi}'
                        : '$minKM ${Strings.kms}',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    selectedRadio == NearbySettingBloc.MILES_SELECTION
                        ? '$maxMi ${Strings.mi}'
                        : '$maxKM ${Strings.kms}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.height,
              child: CupertinoSlider(
                min: selectedRadio == NearbySettingBloc.MILES_SELECTION
                    ? minMi
                    : minKM,
                max: selectedRadio == NearbySettingBloc.MILES_SELECTION
                    ? maxMi
                    : maxKM,
                // divisions:
                //     selectedRadio == NearbySettingBloc.MILES_SELECTION ? 8 : 13,
                thumbColor: Theme.of(context).primaryColor,
                activeColor: Theme.of(context).primaryColor,
                value: rating ?? 0.0,
                onChanged: (newRating) {
                  _debouncer.run(() => NearbySettingBloc.udpateNearbyRadius(
                      email: widget.loggedInUser.email!,
                      radius: newRating.toInt(),
                      selectedRadioVal:
                          selectedRadio ?? NearbySettingBloc.MILES_SELECTION));
                  setState(() => rating = newRating);
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
                      setSelectedRadio(val as int);
                      await NearbySettingBloc.isMiles(
                        email: widget.loggedInUser.email!,
                        val: true,
                      );
                    },
                  ),
                ),
                Container(
                  child: Text(S.of(context).miles),
                ),
                Container(
                  child: Radio(
                    activeColor: Theme.of(context).primaryColor,
                    value: NearbySettingBloc.KILOMETERS_SELECTION,
                    groupValue: selectedRadio,
                    onChanged: (val) async {
                      setSelectedRadio(val as int);
                      await NearbySettingBloc.isMiles(
                        email: widget.loggedInUser.email!,
                        val: false,
                      );
                    },
                  ),
                ),
                Container(
                  child: Text(S.of(context).kilometers),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String appendDistanceUnit() {
    return " " +
        (selectedRadio == NearbySettingBloc.MILES_SELECTION ? 'M' : 'Kms');
  }

  Container titleAndSubTitle() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).nearby_settings_title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Theme.of(context).colorScheme.secondary),
                child: Text(
                  double.parse((rating ?? 0.0).toStringAsFixed(2)).toString() +
                      appendDistanceUnit(),
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            S.of(context).nearby_settings_content,
            style: TextStyle(fontSize: 14.0),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  void setSelectedRadio(int value) {
    if (value == NearbySettingBloc.MILES_SELECTION) {
      rating = (rating ?? 0) / 1.6;
      //// rating = rating >= minMi && rating <= maxMi ? rating : minMi;
      // rating = rating >= minMi && rating <= maxMi
      //     ? rating
      //     : rating < minMi
      //         ? minMi
      //         : maxMi;
    } else if (value == NearbySettingBloc.KILOMETERS_SELECTION) {
      rating = (rating ?? 0) * 1.6;
      //// rating = rating >= minKM && rating <= maxKM ? rating : minKM;
      // rating = rating >= minKM && rating <= maxKM
      //     ? rating
      //     : rating < minKM
      //         ? minKM
      //         : maxKM;
    }
    NearbySettingBloc.udpateNearbyRadius(
      email: widget.loggedInUser.email!,
      radius: (rating ?? 0).toInt(),
      selectedRadioVal: value,
    );

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

  static isMiles({required String email, required bool val}) async {
    _debouncer.run(() async {
      await CollectionRef.users.doc(email).update({
        'nearbySettings.isMiles': val,
      });
    });
  }

  static int valueForSeekBar(NearBySettings nearBySettings, int distanceUnit) {
    if (nearBySettings.radius != null && nearBySettings.isMiles != null) {
      return nearBySettings.radius!.toInt();
    }
    return distanceUnit == MILES_SELECTION
        ? DEFAULT_RADIUS_IN_MILES
        : DEFAULT_RADIUS_IN_KILOMETERS;
  }

  static udpateNearbyRadius({
    required String email,
    required int radius,
    required int selectedRadioVal,
  }) async {
    await CollectionRef.users.doc(email).update({
      'nearbySettings.radius': radius,
      'nearbySettings.isMiles':
          selectedRadioVal == NearbySettingBloc.MILES_SELECTION ? true : false,
    });
  }
}
