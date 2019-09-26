import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';

class WorkshopView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TwoListsWorkshop();
}

class TwoListsWorkshop extends State<WorkshopView> {
  @override
  Widget build(BuildContext context) {
    var alphabits = ["A", "b", "c", "d", "e", "f"];

    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("Workshop"),
          ),
          body: Column(
            children: <Widget>[
              Container(
                height: double.minPositive,
                child: ListView(
                  children: alphabits.map((alphabit) {
                    return Text(alphabit);
                  }).toList(),
                ),
              ),
              Container(
                height: 100,
                child: ListView(
                  children: alphabits.map((alphabit) {
                    return Text(alphabit);
                  }).toList(),
                ),
              )
            ],
          )),
    );
  }
}

