import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';

class DonationAcceptedPage extends StatelessWidget {
  final DonationModel model;

  const DonationAcceptedPage({Key key, this.model}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  child: Text(S.of(context).participants),
                ),
                Tab(
                  child: Text(S.of(context).completed),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Container(color: Colors.red),
                  Container(color: Colors.blue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
