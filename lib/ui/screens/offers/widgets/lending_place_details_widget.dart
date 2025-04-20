import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/utils/utils.dart';

import '../../../../labels.dart';
import 'lending_place_card_widget.dart';

class LendingPlaceDetailsWidget extends StatelessWidget {
  final LendingModel lendingModel;

  LendingPlaceDetailsWidget({required this.lendingModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LendingPlaceCardWidget(
          lendingPlaceModel: lendingModel.lendingPlaceModel,
          hidden: true,
        ),
        SizedBox(
          height: 10,
        ),
        AmenitiesAndHouseRules(lendingModel: lendingModel)
      ],
    );
  }
}

class AmenitiesAndHouseRules extends StatefulWidget {
  final LendingModel lendingModel;

  AmenitiesAndHouseRules({required this.lendingModel});

  @override
  _AmenitiesAndHouseRulesState createState() => _AmenitiesAndHouseRulesState();
}

class _AmenitiesAndHouseRulesState extends State<AmenitiesAndHouseRules> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 6 / 1,
            crossAxisSpacing: 0.0,
            mainAxisSpacing: 5.0,
            physics: NeverScrollableScrollPhysics(),
            children: widget.lendingModel.lendingPlaceModel!.amenities!.values
                .map((title) => Row(
                      children: [
                        Container(
                            height: 20.0,
                            width: 20.0,
                            margin: EdgeInsets.only(right: 5),
                            child: Image.asset(getImageAssetIcon(title))),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: HexColor(
                                '#606670',
                              ),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ))
                .toList()),
        SizedBox(
          height: 10,
        ),
        Text(
          S.of(context).house_rules,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          widget.lendingModel.lendingPlaceModel!.houseRules ?? '',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }
}

String getImageAssetIcon(String title) {
  switch (title) {
    case 'Wardrobe':
      return AmenityAssetIcon.closet;
    case 'Dedicated Workspace':
      return AmenityAssetIcon.workspace;
    case 'Parking':
      return AmenityAssetIcon.parking;
    case 'Swimming Pool':
      return AmenityAssetIcon.swimming_pool;
    case 'Tea / Coffee Maker':
      return AmenityAssetIcon.coffee_machine;
    case 'Ironing Board':
      return AmenityAssetIcon.ironing_board;
    case 'Kitchen':
      return AmenityAssetIcon.kitchen;
    case 'Alarm Clock':
      return AmenityAssetIcon.alarm_clock;
    case 'AC':
      return AmenityAssetIcon.air_conditioner;
    case 'Electronic Safe / Locker':
      return AmenityAssetIcon.safe_locker;
    case 'Dental Kit':
      return AmenityAssetIcon.dental_kit;
    case 'BathTub':
      return AmenityAssetIcon.bath_tub;
    case 'Wifi':
      return AmenityAssetIcon.wifi;
    case 'Tv':
      return AmenityAssetIcon.television;
    case 'Shaving Kit':
      return AmenityAssetIcon.shaving_kit;
    case 'Mini Bar / Mini Fridge':
      return AmenityAssetIcon.mini_fridge;
    case 'Iron':
      return AmenityAssetIcon.iron;
    case 'Hangers':
      return AmenityAssetIcon.clothes_hanger;
    case 'Luggage Rack':
      return AmenityAssetIcon.luggage_rack;
    default:
      return AmenityAssetIcon.amenities;
  }
}
