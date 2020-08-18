import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/request/bloc/request_donation_dispute_bloc.dart';

class RequestDonationDisputePage extends StatefulWidget {
  @override
  _RequestDonationDisputePageState createState() =>
      _RequestDonationDisputePageState();
}

class _RequestDonationDisputePageState
    extends State<RequestDonationDisputePage> {
  final RequestDonationDisputeBloc _bloc = RequestDonationDisputeBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Donations Received',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PledgedAmountCard(
              name: 'XYZ',
              amount: '10',
              currency: '\$',
            ),
            SizedBox(height: 40),
            Text(
              "Enter amount you have received",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            StreamBuilder<String>(
                stream: _bloc.cashAmount,
                builder: (context, snapshot) {
                  return TextField(
                    onChanged: _bloc.onAmountChanged,
                    decoration: InputDecoration(
                      hintText: 'Amount',
                      hintStyle: TextStyle(fontSize: 12),
                    ),
                  );
                }),
            SizedBox(height: 30),
            Text(
              'I acknowledge that I have received amount',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Note: Check the amount you received and the transcation fees equals the user user donation.If it does not match please choose to message',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                RaisedButton(
                  child: Text('Acknowledge'),
                  onPressed: () {},
                ),
                RaisedButton(
                  child: Text('Message'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PledgedAmountCard extends StatelessWidget {
  final String name;
  final String currency;
  final String amount;
  const PledgedAmountCard({
    Key key,
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
                  '$name pledged to donate',
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
