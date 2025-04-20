import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';

class PledgedAmountCard extends StatelessWidget {
  final String? name;
  final String? currency;
  final String? amount;
  final String? title;
  const PledgedAmountCard({
    Key? key,
    this.title,
    this.name,
    this.currency,
    this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          padding: EdgeInsets.only(top: 25),
          child: Card(
            elevation: 5.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title!,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Text(
                  '$currency$amount',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: CircleAvatar(
            radius: 30,
            child: Icon(Icons.check, size: 30),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
