import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/transaction_details/bloc/transaction_details_bloc.dart';
import 'package:sevaexchange/ui/screens/transaction_details/dialog/transaction_details_dialog.dart';
import 'package:sevaexchange/ui/screens/transaction_details/manager/transactions_details_handler.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/donations/donation_bloc.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/widgets/loading_indicator.dart';

//  timebankModel = Provider.of<HomePageBaseBloc>(context, listen: false)
//         .getTimebankModelFromCurrentCommunity(widget.timebankId);

class DonationsDetailsView extends StatefulWidget {
  DonationsDetailsView({
    Key key,
    @required this.id,
    @required this.totalBalance,
    this.timebankModel,
    @required this.fromTimebank,
    @required this.isGoods,
  });

  final String id;
  final String totalBalance;
  final bool fromTimebank;
  final TimebankModel timebankModel;
  final bool isGoods;

  @override
  _DonationsDetailsViewState createState() => _DonationsDetailsViewState();
}

class _DonationsDetailsViewState extends State<DonationsDetailsView> {
  final DonationBloc _donationBloc = DonationBloc();
  double totalBalance = 0.0;
  RequestModel requestModel;
  TimebankModel timebankModel;
  CommunityModel communityModel;
  TimebankModel timebankModelNew;
  bool isLoading = false;

  final TextStyle tableCellStyle = TextStyle(
    fontSize: 18,
  );

  final headerCellStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  double loadTotalBalance(List<DonationModel> transactions) {
    if (widget.isGoods) {
      return transactions.fold(
            0.0,
            (sum, element) => sum + element.goodsDetails.donatedGoods.length,
          ) ??
          0;
    } else {
      return transactions.fold(
            0.0,
            (sum, element) => sum + element.cashDetails.pledgedAmount,
          ) ??
          0;
    }
  }

  Future<void> onRowTap(DonationModel donation) async {
    // List<TransacationsTimelineModel> timelineData = [];
    // timelineData = _bloc.getRequestTimelineDocs(transaction.typeid);
    showLoader;
    if (donation.requestId != null) {
      try {
        requestModel = await FirestoreManager.getRequestFutureById(
            requestId: donation.requestId);
      } catch (e) {
        log('error fetching request model: ' + e.toString());
      }
      try {
        timebankModel = await FirestoreManager.getTimeBankForId(
            timebankId: donation.timebankId);
        communityModel =
            await FirestoreManager.getCommunityDetailsByCommunityId(
                communityId: donation.communityId);
      } catch (e) {
        log('error fetching timebank and/or community model: ' + e.toString());
      }
    }

    hideLoader;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: EdgeInsets.zero,
        child: TransactionDetailsDialog(
          transactionModel: null,
          donationModel: donation,
          timebankModel: timebankModel,
          requestModel: requestModel,
          communityModel: communityModel,
          loggedInEmail: SevaCore.of(context).loggedInUser.email,
          loggedInUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        ),
      ),
    );
  }

  @override
  void initState() {
    // _bloc.init(
    //   widget.id,
    //   SevaCore.of(context).loggedInUser.sevaUserID,
    // );
    timebankModel = widget.timebankModel;

    if (widget.timebankModel == null) {
      FirestoreManager.getTimeBankForId(
        timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
      ).then(
        (model) => timebankModel = model,
      );
    }

    super.initState();
  }

  @override
  dispose() {
    // _bloc.dispose();
    _donationBloc.dispose();
    super.dispose();
  }

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
  );

  void get showLoader => setState(() => isLoading = true);
  void get hideLoader => setState(() => isLoading = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F8F8F8'),
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
        backgroundColor: HexColor('#F8F8F8'),
        elevation: 0.0,
      ),
      body: LoadingViewIndicator(
        isLoading: isLoading,
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: StreamBuilder<List<DonationModel>>(
              stream: FirestoreManager.getDonationList(
                  isGoods: widget.isGoods,
                  userId: SevaCore.of(context).loggedInUser.sevaUserID),
              key: ValueKey(SevaCore.of(context).loggedInUser.sevaUserID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.data == null) {
                  return LoadingIndicator();
                }

                totalBalance = loadTotalBalance(snapshot.data);

                TransactionDataRow _data = TransactionDataRow(
                    onRowTap,
                    snapshot.data,
                    context,
                    widget.timebankModel == null
                        ? timebankModel
                        : widget.timebankModel,
                    widget.fromTimebank,
                    widget.isGoods);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: PaginatedDataTable(
                          showCheckboxColumn: false,
                          header: Row(
                            children: [
                              Text(
                                S.of(context).transations,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(flex: 2),
                              SizedBox(width: 8),
                              Flexible(
                                child: StreamBuilder<String>(
                                  builder: (context, snapshot) {
                                    return SizedBox(
                                      height: 40,
                                      child: TextField(
                                        // onChanged: _donationBloc.onSearchQueryChanged,  //UPDATE AND ADD SEARCH
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.only(bottom: 8),
                                          border: border,
                                          enabledBorder: border,
                                          disabledBorder: border,
                                          focusedBorder: border,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: S.of(context).donations + "\n",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF9B9B9B),
                                      ),
                                    ),
                                    TextSpan(
                                      text: totalBalance.toStringAsFixed(2),
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
                              label: Text(S.of(context).name,
                                  style: headerCellStyle),
                            ),
                            DataColumn(
                                label: Text(
                                    S
                                        .of(context)
                                        .select_transaction_type_valid
                                        .substring(
                                            9,
                                            S
                                                .of(context)
                                                .select_transaction_type_valid
                                                .length)
                                        .sentenceCase(),
                                    style: headerCellStyle)),
                            DataColumn(
                                label: Text(S.of(context).date,
                                    style: headerCellStyle)),
                            DataColumn(
                              label: Text(S.of(context).amount,
                                  style: headerCellStyle),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}

class TransactionDataRow extends DataTableSource {
  final List<DonationModel> data;
  final BuildContext context;
  final TimebankModel timebankModel;
  final bool fromTimebank;
  final bool isGoods;
  TransactionDataRow(this.onRowTap, this.data, this.context, this.timebankModel,
      this.fromTimebank, this.isGoods);

  final ValueChanged<DonationModel> onRowTap;

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
                  data[index].donorSevaUserId.contains('-')
                      ? (timebankModel != null
                          ? timebankModel.photoUrl ?? defaultUserImageURL
                          : defaultUserImageURL)
                      : (SevaCore.of(context).loggedInUser != null
                          ? SevaCore.of(context).loggedInUser.photoURL ??
                              defaultUserImageURL
                          : defaultUserImageURL),
                ),
              ),
              SizedBox(width: 8),
              Text(
                  data[index].donorSevaUserId.contains('-')
                      ? (timebankModel != null
                          ? timebankModel.name ?? S.of(context).no_data
                          : S.of(context).error_loading_data)
                      : (SevaCore.of(context).loggedInUser != null
                          ? SevaCore.of(context).loggedInUser.fullname ??
                              S.of(context).no_data
                          : S.of(context).no_data),
                  style: tableCellStyle),
            ],
          ),
          onTap: () => onRowTap(data[index]),
        ),
        DataCell(
          Text(
              isGoods
                  ? S.of(context).goods_donation
                  : S.of(context).cash_donation,
              style: tableCellStyle),
          onTap: () => {},
        ),
        DataCell(
          Text(
              DateFormat('MMMM dd').format(
                  DateTime.fromMillisecondsSinceEpoch(data[index].timestamp)),
              style: tableCellStyle),
          onTap: () => onRowTap(data[index]),
        ),
        DataCell(
          Text(
            fromTimebank
                ? (data[index].donorSevaUserId == timebankModel.id
                        ? '-'
                        : '+') +
                    (isGoods
                        ? (data[index].goodsDetails?.donatedGoods != null
                                ? data[index]
                                    .goodsDetails
                                    .donatedGoods
                                    .length
                                    .toString()
                                : '0') +
                            ' ' +
                            S.of(context).item_s_text
                        : data[index].cashDetails.pledgedAmount.toString())
                : (data[index].donorSevaUserId ==
                            SevaCore.of(context).loggedInUser.sevaUserID
                        ? '-'
                        : '+') +
                    (isGoods
                        ? (data[index].goodsDetails?.donatedGoods != null
                                ? data[index]
                                    .goodsDetails
                                    .donatedGoods
                                    .length
                                    .toString()
                                : '0') +
                            ' ' +
                            S.of(context).item_s_text
                        : data[index].cashDetails.pledgedAmount.toString()),
            style: TextStyle(
                fontSize: 18,
                color: fromTimebank
                    ? data[index].donorSevaUserId == timebankModel.id
                        ? Colors.black
                        : Colors.green[400]
                    : data[index].donorSevaUserId ==
                            SevaCore.of(context).loggedInUser.sevaUserID
                        ? Colors.black
                        : Colors.green[400]),
          ),
          onTap: () => onRowTap(data[index]),
        ),
      ],
    );
  }
}
