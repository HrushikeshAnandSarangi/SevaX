import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';

class BorrowRequest extends StatefulWidget {
  final Widget addToProjectContainer;
  GeoFirePoint location;
  String selectedAddress;
  Widget categoryWidget;
  final Widget requestDescription;

  BorrowRequest({
    this.addToProjectContainer,
    this.requestDescription,
    this.selectedAddress,
    this.location,
    this.categoryWidget,
  });

  @override
  _BorrowRequestState createState() => _BorrowRequestState();
}

class _BorrowRequestState extends State<BorrowRequest> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      RepeatWidget(),
      SizedBox(height: 15),
      widget.requestDescription,
      SizedBox(height: 20),
      //Same hint for Room and Tools ?
      // Choose Category and Sub Category
      widget.categoryWidget,
      SizedBox(height: 20),
      widget.addToProjectContainer,

      SizedBox(height: 15),

      Text(
        S.of(context).city + '/' + S.of(context).state,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
      SizedBox(height: 10),

      Text(
        L.of(context).provide_address,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.grey,
        ),
      ),
      SizedBox(height: 10),

      Center(
        child: LocationPickerWidget(
          selectedAddress: widget.selectedAddress,
          location: widget.location,
          onChanged: (LocationDataModel dataModel) {
            log("received data model");
            setState(() {
              widget.location = dataModel.geoPoint;
              widget.selectedAddress = dataModel.location;
            });
          },
        ),
      )
    ]);
  }
}
