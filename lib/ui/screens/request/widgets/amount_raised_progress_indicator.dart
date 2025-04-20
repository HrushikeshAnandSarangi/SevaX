import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';

class AmountRaisedProgressIndicator extends StatelessWidget {
  const AmountRaisedProgressIndicator({
    Key? key,
    required this.totalAmountRaised,
    required this.targetAmount,
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
                S.of(context).total_amount_raised,
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
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.5),
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
