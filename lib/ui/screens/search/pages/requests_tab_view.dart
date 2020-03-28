import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/timebank/widgets/timebank_request_card.dart';

class RequestsTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return TimebankRequestCard(
          title: "Fake Credit Card Generator",
          subtitle: "Real Money",
          isApplied: index % 2 == 0,
          startTime: 165,
          endTime: 195,
        );
      },
    );
  }
}
