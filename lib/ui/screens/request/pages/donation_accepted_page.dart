import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/request/bloc/donation_accepted_bloc.dart';
import 'package:sevaexchange/ui/screens/request/pages/donation_completed_page.dart';
import 'package:sevaexchange/ui/screens/request/pages/donation_participants_page.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

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
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(
                    child: Text(
                      S.of(context).participants,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tab(
                    child: Text(
                      S.of(context).completed,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    DonationParticipantPage(
                      requestModel: widget.model,
                    ),
                    DonationCompletedPage(
                      requestModel: widget.model,
                    ),
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
