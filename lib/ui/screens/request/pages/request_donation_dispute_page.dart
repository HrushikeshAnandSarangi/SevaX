import 'package:flutter/material.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/request/bloc/request_donation_dispute_bloc.dart';
import 'package:sevaexchange/ui/screens/request/widgets/checkbox_with_text.dart';
import 'package:sevaexchange/ui/screens/request/widgets/pledged_amount_card.dart';

enum _AckType { CASH, GOODS }
enum _OperatingMode { CREATOR, USER }

class RequestDonationDisputePage extends StatefulWidget {
  final DonationModel model;

  const RequestDonationDisputePage({
    Key key,
    this.model,
  }) : super(key: key);
  @override
  _RequestDonationDisputePageState createState() =>
      _RequestDonationDisputePageState();
}

class _RequestDonationDisputePageState
    extends State<RequestDonationDisputePage> {
  final RequestDonationDisputeBloc _bloc = RequestDonationDisputeBloc();
  _AckType ackType;
  _OperatingMode operatingMode;
  @override
  void initState() {
    ackType = widget.model.donationType == RequestType.CASH
        ? _AckType.CASH
        : _AckType.GOODS;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ackType == _AckType.CASH
                  ? _CashFlow(
                      bloc: _bloc,
                      name: widget.model.donorDetails.name,
                      currency: '\$',
                      amount: widget.model.cashDetails.pledgedAmount.toString(),
                    )
                  : _GoodsFlow(bloc: _bloc),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  RaisedButton(
                    child: Text('Acknowledge'),
                    onPressed: () {
                      switch (ackType) {
                        case _AckType.CASH:
                          _bloc
                              .disputeCash(
                            widget.model.id,
                            widget.model.cashDetails.pledgedAmount.toDouble(),
                          )
                              .then(
                            (value) {
                              print(value);
                              if (value) {
                                Navigator.of(context).pop();
                              }
                            },
                          );
                          break;
                        case _AckType.GOODS:
                          break;
                      }
                    },
                  ),
                  SizedBox(width: 12),
                  RaisedButton(
                    child: Text('Message'),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashFlow extends StatelessWidget {
  const _CashFlow({
    Key key,
    @required RequestDonationDisputeBloc bloc,
    this.name,
    this.amount,
    this.currency,
  })  : _bloc = bloc,
        super(key: key);

  final RequestDonationDisputeBloc _bloc;
  final String name;
  final String amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PledgedAmountCard(
          name: name,
          amount: amount,
          currency: currency,
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
      ],
    );
  }
}

class _GoodsFlow extends StatelessWidget {
  _GoodsFlow({
    Key key,
    @required RequestDonationDisputeBloc bloc,
    // this.goods,
  })  : _bloc = bloc,
        super(key: key);

  final RequestDonationDisputeBloc _bloc;
  final Map<String, String> goods = {'1': 'Clothes', '2': 'Footwear'};

  @override
  Widget build(BuildContext context) {
    List<String> keys = List.from(goods.keys);
    return Column(
      children: [
        Text(
          'I acknowledge that i have received below',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20),
        StreamBuilder<Map<String, String>>(
          stream: _bloc.goodsRecieved,
          builder: (context, snapshot) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: goods.length,
              itemBuilder: (context, index) {
                String key = keys[index];
                return CheckboxWithText(
                  value: snapshot.data?.containsKey(key) ?? false,
                  onChanged: (value) {
                    _bloc.toggleGoodsReceived(
                      key,
                      goods[key],
                    );
                  },
                  text: goods[keys[index]],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
