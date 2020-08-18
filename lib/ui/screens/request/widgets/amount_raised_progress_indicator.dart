import 'package:flutter/material.dart';

class AmountRaisedProgressIndicator extends StatelessWidget {
  const AmountRaisedProgressIndicator({
    Key key,
    @required this.totalAmountRaised,
    @required this.targetAmount,
  }) : super(key: key);

  final int totalAmountRaised;
  final int targetAmount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.show_chart, color: Colors.grey),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total amount raised',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                  minHeight: 16,
                  value: totalAmountRaised / targetAmount,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${totalAmountRaised}\$'),
                  Text('$targetAmount\$'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
