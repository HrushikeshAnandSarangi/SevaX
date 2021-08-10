import 'package:flutter/material.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/utils/utils.dart';

import '../../../../labels.dart';
import 'lending_place_card_widget.dart';

class LendingPlaceDetailsWidget extends StatefulWidget {
  final LendingModel lendingModel;

  LendingPlaceDetailsWidget({@required this.lendingModel});

  @override
  _LendingPlaceDetailsWidgetState createState() =>
      _LendingPlaceDetailsWidgetState();
}

class _LendingPlaceDetailsWidgetState extends State<LendingPlaceDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LendingPlaceCardWidget(
          lendingPlaceModel: widget.lendingModel.lendingPlaceModel,
          hidden: true,
        ),
        SizedBox(
          height: 10,
        ),
        GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 6 / 1,
            crossAxisSpacing: 0.0,
            mainAxisSpacing: 0.2,
            physics: NeverScrollableScrollPhysics(),
            children: widget.lendingModel.lendingPlaceModel.amenities.values
                .map((title) => Text(
                      title,
                      style: TextStyle(
                        color: HexColor(
                          '#606670',
                        ),
                        fontSize: 14,
                      ),
                    ))
                .toList()),
        SizedBox(
          height: 10,
        ),
        Text(
          L.of(context).house_rules,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          widget.lendingModel.lendingPlaceModel.houseRules ?? '',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }
}
