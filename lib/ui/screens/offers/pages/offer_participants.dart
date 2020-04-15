import 'package:flutter/material.dart';
import 'package:sevaexchange/widgets/participant_card.dart';

class OfferParticipants extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey[300],
            child: Center(
              child: Text(
                "Ensure to recieve credits after the class is completed",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ),
          ...List.generate(
            10,
            (index) => ParticipantCard(
              name: "Andrew Wilson",
              onMessageTapped: () {},
            ),
          ).toList(),
        ],
      ),
    );
  }
}
