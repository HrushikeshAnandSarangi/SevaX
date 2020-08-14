import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/requests/donation_completed_page.dart';
import 'package:sevaexchange/views/requests/donation_participants_page.dart';
import 'package:sevaexchange/views/requests/donations/donation_accepted_bloc.dart';

class DonationAcceptedPage extends StatefulWidget {
  final RequestModel model;

  const DonationAcceptedPage({Key key, this.model}) : super(key: key);
  @override
  _DonationAcceptedPageState createState() => _DonationAcceptedPageState();
}

class _DonationAcceptedPageState extends State<DonationAcceptedPage> {
  final DonationAcceptedBloc _bloc = DonationAcceptedBloc();

  @override
  void initState() {
    _bloc.init('123');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _bloc,
      child: Scaffold(
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
                    DonationParticipantPage(),
                    DonationCompletedPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
