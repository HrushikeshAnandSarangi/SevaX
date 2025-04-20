import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/transaction_details/bloc/transaction_details_bloc.dart';
import 'package:sevaexchange/ui/screens/transaction_details/dialog/transaction_details_dialog.dart';
import 'package:sevaexchange/ui/screens/transaction_details/manager/transactions_details_handler.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

//  timebankModel = Provider.of<HomePageBaseBloc>(context, listen: false)
//         .getTimebankModelFromCurrentCommunity(widget.timebankId);
class TransactionDetailsView extends StatefulWidget {
  final String id;
  final String userId;
  final String userEmail;
  final String totalBalance;

  const TransactionDetailsView({
    Key? key,
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.totalBalance,
  }) : super(key: key);

  @override
  _TransactionDetailsViewState createState() => _TransactionDetailsViewState();
}

class _TransactionDetailsViewState extends State<TransactionDetailsView> {
  TransactionDetailsBloc _bloc = TransactionDetailsBloc();
  // double totalBalance = 0.0;
  RequestModel? requestModel;
  TimebankModel? timebankModel;
  CommunityModel? communityModel;
  TimebankModel? timebankModelNew;

  final TextStyle tableCellStyle = TextStyle(
    fontSize: 18,
  );

  final headerCellStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  // void loadTotalBalance(List<TransactionModel> transactions) {
  //   transactions.forEach((element) {
  //     totalBalance += element.credits;
  //   }
  //   );
  // }

  Future<void> onRowTap(TransactionModel transaction) async {
    // List<TransacationsTimelineModel> timelineData = [];
    // timelineData = _bloc.getRequestTimelineDocs(transaction.typeid);

    if (transaction.typeid != null) {
      logger.e('TypeID CHECK 1: ' + transaction.typeid.toString());
      try {
        requestModel = await FirestoreManager.getRequestFutureById(
            requestId: transaction.typeid!);
      } catch (e) {
        log('error fetching request model: ' + e.toString());
      }
      try {
        timebankModel = await FirestoreManager.getTimeBankForId(
            timebankId: transaction.timebankid!);
        communityModel =
            await FirestoreManager.getCommunityDetailsByCommunityId(
                communityId: transaction.communityId!);
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

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          S.of(context).review_earnings,
          style: TextStyle(fontSize: 18),
        ),
        elevation: 0.0,
      ),
      body: StreamBuilder<List<TransactionModel>>(
          stream: _bloc.data(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data == null) {
              return LoadingIndicator();
            }

            // loadTotalBalance(snapshot.data);

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
                          '${S.of(context).transations}',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 7),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: S.of(context).seva_credit_s,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9B9B9B),
                                ),
                              ),
                              TextSpan(
                                text: '\n${widget.totalBalance}',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<String>(
                          stream: _bloc.searchQueryStream,
                          builder: (context, snapshot) {
                            return SizedBox(
                              height: 40,
                              child: TextField(
                                onChanged: (query) =>
                                    _bloc.onSearchQueryChanged!.add(query),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Theme.of(context).primaryColor,
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
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                        child: getTitle("Name", "Comment", "Date", "Amount"),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) =>
                            InkWell(
                          onTap: () => onRowTap(snapshot.data![index]),
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
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                8,
                                        child: Text(
                                            SevaCore.of(context)
                                                .loggedInUser
                                                .fullname!,
                                            style: tableCellStyle)),
                                    SizedBox(width: 15),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        getTransactionTypeLabel(
                                                snapshot.data![index].type!,
                                                context)
                                            .toString(),
                                        style: tableCellStyle,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                          DateFormat('MMMM dd').format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                snapshot
                                                    .data![index].timestamp!),
                                          ),
                                          style: tableCellStyle),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "${snapshot.data![index].to == widget.id ? "+" : "-"}${snapshot.data![index].credits}",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: snapshot.data![index].to ==
                                                  widget.id
                                              ? Colors.green
                                              : Colors.black,
                                          fontSize: 16,
                                          // fontFamily: 'Europa',
                                        ),
                                      ),
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
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget getTitle(String title1, String title2, String title3, String title4) {
    return Column(
      children: [
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: getText(title1),
            ),
            Expanded(
              flex: 3,
              child: getText(title2),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: getText(title3),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: getText(title4),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget getText(String title) {
    final TextStyle style =
        TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Europa');
    return Text(
      title,
      style: style,
    );
  }
}
