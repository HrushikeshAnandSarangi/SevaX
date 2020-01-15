import 'package:flutter/material.dart';

import '../core.dart';

class SampleTimeSample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SampleTimeState();
  }
}

class SampleTimeState extends State<SampleTimeSample> {
  @override
  Widget build(BuildContext context) {
    print(
        "-----------------------------<<< ${SevaCore.of(context).loggedInUser}");

    return Text('ccwicubduibc');
  }
}
