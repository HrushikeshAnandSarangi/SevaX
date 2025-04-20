import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/transactions_timeline_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/transaction_details/manager/transactions_details_handler.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/ui/screens/transaction_details/transaction_pdf/transactions_pdf.dart';

class TransactionDetailsDialog extends StatefulWidget {
  final TransactionModel? transactionModel;
  final DonationModel? donationModel;
  final TimebankModel? timebankModel;
  final RequestModel? requestModel;
  final CommunityModel? communityModel;
  final String? loggedInEmail;
  final String? loggedInUserId;

  const TransactionDetailsDialog({
    Key? key,
    this.transactionModel,
    this.donationModel,
    this.timebankModel,
    this.requestModel,
    this.communityModel,
    required this.loggedInEmail,
    required this.loggedInUserId,
  }) : super(key: key);

  @override
  _TransactionDetailsDialogState createState() =>
      _TransactionDetailsDialogState();
}

class _TransactionDetailsDialogState extends State<TransactionDetailsDialog> {
  Stream<Object>? timelineStream;

  void initState() {
    super.initState();

    logger.e('USER ID: ' + widget.loggedInUserId.toString());

    timelineStream = FirestoreManager.getRequestTimelineDocs(
        transactionTypeId: widget.transactionModel != null
            ? widget.transactionModel!.typeid
            : widget.donationModel!.requestId,
        sevaUserID: widget.loggedInUserId!); //change to timebank id or userid
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: 380,
        height: 450,
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder<Object>(
                stream: timelineStream!,
                builder: (
                  context,
                  snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingIndicator();
                  }
                  if (!snapshot.hasData) {
                    logger.e('docs query check: ' + snapshot.data.toString());
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(S.of(context).error_loading_data),
                      ],
                    );
                  }

                  List<TransacationsTimelineModel> timelineDocs =
                      snapshot.data! as List<TransacationsTimelineModel>;
                  if (snapshot.hasData) {
                    return (timelineDocs.length == 0 || timelineDocs == null)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(S.of(context).no_timeline_found),
                            ],
                          )
                        : Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(30, 20, 20, 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 9,
                                        child: Text(
                                          widget.timebankModel?.name ?? '',
                                          //if it is a public request/offer we need to show other community
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4A4A4A),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        // width: 130,
                                        height: 25,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color(0xFFDBDBDB),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, right: 8),
                                          child: Text(
                                            widget.transactionModel != null
                                                ? (widget.transactionModel!
                                                            .to ==
                                                        widget.loggedInUserId
                                                    ? S.of(context).received
                                                    : S.of(context).sent_text)
                                                : (widget
                                                            .donationModel!
                                                            .receiverDetails!
                                                            .email ==
                                                        widget.loggedInEmail
                                                    ? S.of(context).received
                                                    : S.of(context).sent_text),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: Icon(Icons.cancel),
                                        color: Color(0xFF979797),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            S.of(context).trasaction_amount,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF9B9B9B),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            (widget.donationModel != null
                                                ? (widget.donationModel!
                                                            .donationType ==
                                                        RequestType.GOODS
                                                    ? widget
                                                            .donationModel!
                                                            .goodsDetails!
                                                            .donatedGoods!
                                                            .length
                                                            .toString() +
                                                        ' ' +
                                                        S
                                                            .of(context)
                                                            .item_s_text
                                                    : '\$' +
                                                        widget
                                                            .donationModel!
                                                            .cashDetails!
                                                            .pledgedAmount
                                                            .toString())
                                                : widget.transactionModel!
                                                        .credits
                                                        .toString() +
                                                    ' ' +
                                                    S.of(context).seva_credits),
                                            style: TextStyle(
                                              color: Color(0xFF4A4A4A),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              S.of(context).date,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF9B9B9B),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('MMMM dd @ h:mm a')
                                                  .format(
                                                DateTime.fromMillisecondsSinceEpoch(
                                                    widget.donationModel != null
                                                        ? (widget.donationModel!
                                                                .timestamp ??
                                                            0)
                                                        : (widget
                                                                .transactionModel!
                                                                .timestamp ??
                                                            0)),
                                              ),
                                              style: TextStyle(
                                                color: Color(0xFF4A4A4A),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    S.of(context).trasaction_details,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF9B9B9B).withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Flexible(
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          left: 2,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: VerticalDivider(
                                              thickness: 2,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 0,
                                              indent: 12,
                                              endIndent: 12,
                                            ),
                                          ),
                                        ),
                                        ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: timelineDocs.length,
                                          itemBuilder: (context, index) {
                                            return TitleRow(
                                                timelineDoc:
                                                    timelineDocs[index],
                                                requestType: widget
                                                        ?.donationModel
                                                        ?.donationType ??
                                                    null!);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 25),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          TransactionsPdf().transactionsPdf(
                                            context,
                                            widget.transactionModel!,
                                            widget.donationModel!,
                                            widget.requestModel!,
                                            widget.communityModel!,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          fixedSize: Size(130, 25),
                                          shape: StadiumBorder(),
                                        ),
                                        child: Text(S.of(context).download_pdf),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(S.of(context).error_loading_data),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TitleRow extends StatelessWidget {
  final TransacationsTimelineModel? timelineDoc;
  final RequestType? requestType;

  const TitleRow({
    Key? key,
    this.timelineDoc,
    this.requestType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.d("#TR ${timelineDoc!.toJson()}");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        // height: 20,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                DateFormat('MMMM dd @ h:mm a ').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            timelineDoc!.timestamp! * 1000)) +
                    '- ' +
                    getTimelineLabel(
                            // requestType,
                            timelineDoc!.type!,
                            context,
                            requestType!)
                        .toString(), //call handler function here to return string
                style: TextStyle(
                  color: Color(0xFF9B9B9B).withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
