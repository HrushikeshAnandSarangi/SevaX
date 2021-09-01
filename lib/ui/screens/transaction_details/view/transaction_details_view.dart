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

  TransactionDetailsView({
    Key key,
    this.id,
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
        timebankModel = await FirestoreManager.getTimeBankForId(
            timebankId: transaction.timebankid);
        communityModel =
            await FirestoreManager.getCommunityDetailsByCommunityId(
                communityId: transaction.communityId);
      } catch (e) {
        log('error fetching request model: ' + e.toString());
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
        ),
      ),
    );
  }

  @override
  void initState() {
    _bloc.init(
      widget.id,
      SevaCore.of(context).loggedInUser.sevaUserID,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        leadingWidth: 130,
        titleSpacing: -40.0,
        title: Text(
          S.of(context).review_earnings,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.grey[350],
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: StreamBuilder<List<TransactionModel>>(
            stream: _bloc.transactionDetailsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null) {
                return LoadingIndicator();
              }
              TransactionDataRow _data =
                  TransactionDataRow(onRowTap, snapshot.data, context);
              loadTotalBalance(snapshot.data);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: PaginatedDataTable(
                        // onRowsPerPageChanged: (int value) {},
                        // onPageChanged: (_) {},
                        // availableRowsPerPage: [
                        //   10,
                        //   20,
                        //   30,
                        //   40,
                        //   50,
                        //   60,
                        //   70,
                        //   80,
                        //   90,
                        //   200
                        // ],

                        showCheckboxColumn: false,
                        header: Row(
                          children: [
                            Text(
                              'Transactions',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
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
                                    text: '\$ $totalBalance',
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
                        source: _data,
                        rowsPerPage: 9,
                        columns: [
                          DataColumn(
                              label: Text('Name', style: headerCellStyle)),
                          DataColumn(
                              label: Text('Status', style: headerCellStyle)),
                          DataColumn(
                              label: Text('Date', style: headerCellStyle)),
                          DataColumn(
                              label: Text('Status', style: headerCellStyle)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

class TransactionDataRow extends DataTableSource {
  final List<TransactionModel> data;
  final BuildContext context;
  TransactionDataRow(this.onRowTap, this.data, this.context);

  final ValueChanged<TransactionModel> onRowTap;

  final TextStyle tableCellStyle = TextStyle(
    fontSize: 18,
  );

  // Generate some made-up data

  bool get isRowCountApproximate => false;
  int get rowCount => data.length;
  int get selectedRowCount => 0;
  DataRow getRow(int index) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  SevaCore.of(context).loggedInUser.photoURL ??
                      defaultUserImageURL, //need to add condition if from or to
                ),
              ),
              SizedBox(width: 8),
              Text(SevaCore.of(context).loggedInUser.fullname,
                  style: tableCellStyle),
            ],
          ),
          onTap: () => onRowTap(data[index]),
        ),
        DataCell(
          Text(data[index].type, style: tableCellStyle),
          onTap: () => onRowTap(data[index]),
        ),
        DataCell(
          Text(
              DateFormat('MMMM dd').format(
                  DateTime.fromMillisecondsSinceEpoch(data[index].timestamp)),
              style: tableCellStyle),
          onTap: () => onRowTap(data[index]),
        ),
        DataCell(
          Text('\$${data[index].credits}', style: tableCellStyle),
          onTap: () => onRowTap(data[index]),
        ),
      ],
    );
  }
}
