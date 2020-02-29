import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlanStatusView extends StatefulWidget {
  @override
  _PlanStatusViewState createState() => _PlanStatusViewState();
}

class _PlanStatusViewState extends State<PlanStatusView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();

    print("1234567890");
  }

  void getData() async {
    print("123");
    var data = await Firestore.instance
        .collection("communities")
        .document("a2cafed3-d390-40ad-8466-4c9e9fcd5d93")
        .collection('transactions')
        .document('1_2020')
        .get();

//        .document("a2cafed3-d390-40ad-8466-4c9e9fcd5d93")
//        .collection("transactions")
//        .document("1_2020")
//        .get();

    print("dattt ${data.data['payment_failed']}");
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
