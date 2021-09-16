import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/transaction_details/bloc/transaction_details_bloc.dart';
import 'package:sevaexchange/ui/screens/transaction_details/dialog/transaction_details_dialog.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

import '../../../../labels.dart';

//  timebankModel = Provider.of<HomePageBaseBloc>(context, listen: false)
//         .getTimebankModelFromCurrentCommunity(widget.timebankId);
class TransactionDetailsView extends StatefulWidget {
  final String id;
  final String userId;
  final String userEmail;

  TransactionDetailsView({
    Key key,
    this.id,
    this.userId,
    this.userEmail,
  }) : super(key: key);

  @override
  _TransactionDetailsViewState createState() => _TransactionDetailsViewState();
}

class _TransactionDetailsViewState extends State<TransactionDetailsView> {
  TransactionDetailsBloc _bloc = TransactionDetailsBloc();
  double totalBalance = 0.0;
  RequestModel requestModel;
  TimebankModel timebankModel;
  CommunityModel communityModel;

  final TextStyle tableCellStyle = TextStyle(
    fontSize: 18,
  );

  final headerCellStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  void loadTotalBalance(List<TransactionModel> transactions) {
    transactions.forEach((element) {
      totalBalance += element.credits;
    });
  }

  Future<void> onRowTap(TransactionModel transaction) async {
    // List<TransacationsTimelineModel> timelineData = [];
    // timelineData = _bloc.getRequestTimelineDocs(transaction.typeid);

    if (transaction.typeid != null) {
      logger.e('TypeID CHECK 1: ' + transaction.typeid.toString());
      try {
        requestModel = await FirestoreManager.getRequestFutureById(
            requestId: transaction.typeid);
      } catch (e) {
        log('error fetching request model: ' + e.toString());
      }
      try {
        timebankModel = await FirestoreManager.getTimeBankForId(
            timebankId: transaction.timebankid);
        communityModel =
            await FirestoreManager.getCommunityDetailsByCommunityId(
                communityId: transaction.communityId);
      } catch (e) {
        log('error fetching timebank and/or community model: ' + e.toString());
      }
    }

    // logger.e('TRANSACTION MODEL CHECK 1: ' + transaction.toString());
    // logger.e('TIMEBANK MODEL CHECK 1: ' + widget.timebankModel.toString());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: EdgeInsets.zero,
        child: TransactionDetailsDialog(
          transactionModel: transaction,
          timebankModel: timebankModel,
          requestModel: requestModel,
          communityModel: communityModel,
          loggedInUserId: widget.userId,
          loggedInEmail: widget.userEmail,
        ),
      ),
    );
  }

  @override
  void initState() {
    _bloc.init(
      widget.id,
      widget.userId,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).review_earnings,
          style: TextStyle(fontSize: 18),
        ),
        elevation: 0.0,
      ),
      body: StreamBuilder<List<TransactionModel>>(
          stream: _bloc.transactionDetailsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data == null) {
              return LoadingIndicator();
            }

            loadTotalBalance(snapshot.data);

            final TextStyle tableCellStyle = TextStyle(
              fontSize: 14,
            );

            return SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transactions',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 7),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: L.of(context).account_balance,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9B9B9B),
                                ),
                              ),
                              TextSpan(
                                text: '\$ ${totalBalance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) =>
                            InkWell(
                          onTap: () => onRowTap(snapshot.data[index]),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        SevaCore.of(context)
                                                .loggedInUser
                                                .photoURL ??
                                            defaultUserImageURL,
                                        //need to add condition if from or to
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                        SevaCore.of(context)
                                            .loggedInUser
                                            .fullname,
                                        style: tableCellStyle),
                                    SizedBox(width: 15),
                                    Expanded(
                                      flex: 3,
                                      child: Text(snapshot.data[index].type,
                                          style: tableCellStyle),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                          DateFormat('MMMM dd').format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                snapshot.data[index].timestamp),
                                          ),
                                          style: tableCellStyle),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                          snapshot.data[index].credits
                                              .toString(),
                                          style: tableCellStyle),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
