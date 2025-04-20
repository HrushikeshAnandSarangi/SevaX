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
import 'package:sevaexchange/ui/screens/transaction_details/dialog/transaction_details_dialog.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
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
    Key? key,
    required this.id,
    required this.totalBalance,
    this.timebankModel,
    required this.fromTimebank,
    required this.isGoods,
  });

  final String id;
  final String totalBalance;
  final bool fromTimebank;
  final TimebankModel? timebankModel;
  final bool isGoods;

  @override
  _DonationsDetailsViewState createState() => _DonationsDetailsViewState();
}

class _DonationsDetailsViewState extends State<DonationsDetailsView> {
  final DonationBloc _donationBloc = DonationBloc();
  double totalBalance = 0.0;
  RequestModel? requestModel;
  TimebankModel? timebankModel;
  CommunityModel? communityModel;
  TimebankModel? timebankModelNew;
  bool isLoading = false;

  final TextStyle tableCellStyle = TextStyle(
    fontSize: 14,
  );

  final headerCellStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  double loadTotalBalance(List<DonationModel> transactions) {
    if (widget.isGoods) {
      return transactions.fold(
        0.0,
        (sum, element) =>
            sum + (element.goodsDetails!.donatedGoods?.length ?? 0),
      );
    } else {
      return transactions.fold(
        0.0,
        (sum, element) => sum + (element.cashDetails!.pledgedAmount ?? 0),
      );
    }
  }

  Future<void> onRowTap(DonationModel donation) async {
    setState(() => isLoading = true);
    if (donation.requestId != null) {
      try {
        requestModel = await FirestoreManager.getRequestFutureById(
            requestId: donation.requestId!);
      } catch (e) {
        log('error fetching request model: ' + e.toString());
      }
      try {
        timebankModel = await FirestoreManager.getTimeBankForId(
            timebankId: donation.timebankId!);
        communityModel =
            await FirestoreManager.getCommunityDetailsByCommunityId(
                communityId: donation.communityId!);
      } catch (e) {
        log('error fetching timebank and/or community model: ' + e.toString());
      }
    }

    setState(() => isLoading = false);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: EdgeInsets.zero,
        child: TransactionDetailsDialog(
          transactionModel: TransactionModel(
            fromEmail_Id: SevaCore.of(context).loggedInUser.email ?? '',
            toEmail_Id: donation.donorSevaUserId ?? '',
            communityId: communityModel?.id ?? '',
          ),
          donationModel: donation,
          timebankModel: timebankModel ?? TimebankModel(''),
          requestModel: requestModel ?? RequestModel(communityId: ''),
          communityModel: communityModel ?? CommunityModel(Map()),
          loggedInEmail: SevaCore.of(context).loggedInUser.email ?? '',
          loggedInUserId: SevaCore.of(context).loggedInUser.sevaUserID ?? '',
        ),
      ),
    );
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (widget.fromTimebank && widget.timebankModel != null) {
        _donationBloc.init(
            timebankId: widget.timebankModel!.id,
            userId: SevaCore.of(context).loggedInUser.sevaUserID!,
            isGoods: widget.isGoods);
      } else {
        _donationBloc.init(
            timebankId: widget.timebankModel!.id,
            userId: SevaCore.of(context).loggedInUser.sevaUserID!,
            isGoods: widget.isGoods);
      }
    });
    if (widget.timebankModel == null) {
      Future.delayed(Duration.zero, () {
        FirestoreManager.getTimeBankForId(
          timebankId: SevaCore.of(context).loggedInUser.currentTimebank!,
        ).then(
          (model) => timebankModel = model,
        );
      });
    } else {
      timebankModel = widget.timebankModel;
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

  void setLoading(bool value) => setState(() => isLoading = value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F8F8F8'),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        leadingWidth: 50.0,
        titleSpacing: 0.0,
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
        loadingIndicator:
            CircularProgressIndicator(), // Provide a default loading indicator
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<List<DonationModel>>(
              stream: _donationBloc.data(context, widget.isGoods),
              key: ValueKey(SevaCore.of(context).loggedInUser.sevaUserID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.data == null) {
                  return LoadingIndicator();
                }

                totalBalance = loadTotalBalance(snapshot.data!);

                return SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).transations,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
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
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: TextField(
                          onChanged: _donationBloc
                              .onSearchQueryChanged, //UPDATE AND ADD SEARCH
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).primaryColor,
                            ),
                            contentPadding: const EdgeInsets.only(bottom: 8),
                            border: border,
                            enabledBorder: border,
                            disabledBorder: border,
                            focusedBorder: border,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Column(
                        children: [
                          getTitle(
                              S.of(context).name,
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
                              S.of(context).date.replaceAll(':', ''),
                              S.of(context).amount),
                          ListView.separated(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              DonationModel model = snapshot.data![index];
                              return InkWell(
                                onTap: () => onRowTap(snapshot.data![index]),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, right: 5.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              model.donorSevaUserId!
                                                      .contains('-')
                                                  ? (timebankModel != null
                                                      ? timebankModel!
                                                              .photoUrl ??
                                                          defaultUserImageURL
                                                      : defaultUserImageURL)
                                                  : (SevaCore.of(context)
                                                              .loggedInUser !=
                                                          null
                                                      ? SevaCore.of(context)
                                                              .loggedInUser
                                                              .photoURL ??
                                                          defaultUserImageURL
                                                      : defaultUserImageURL),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                              model.donorSevaUserId!
                                                      .contains('-')
                                                  ? (timebankModel != null
                                                      ? timebankModel!.name ??
                                                          S.of(context).no_data
                                                      : S
                                                          .of(context)
                                                          .error_loading_data)
                                                  : (SevaCore.of(context)
                                                              .loggedInUser !=
                                                          null
                                                      ? SevaCore.of(context)
                                                              .loggedInUser
                                                              .fullname ??
                                                          S.of(context).no_data
                                                      : S.of(context).no_data),
                                              style: tableCellStyle),
                                          SizedBox(width: 15),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                                widget.isGoods
                                                    ? S
                                                        .of(context)
                                                        .goods_donation
                                                    : S
                                                        .of(context)
                                                        .cash_donation,
                                                style: tableCellStyle),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                                DateFormat('MMMM dd').format(
                                                    DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            model.timestamp!)),
                                                style: tableCellStyle),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              widget.fromTimebank
                                                  ? (model.donorSevaUserId ==
                                                              timebankModel!.id
                                                          ? '-'
                                                          : '+') +
                                                      (widget.isGoods
                                                          ? (model.goodsDetails?.donatedGoods != null
                                                                  ? model
                                                                      .goodsDetails!
                                                                      .donatedGoods!
                                                                      .length
                                                                      .toString()
                                                                  : '0') +
                                                              ' ' +
                                                              S
                                                                  .of(context)
                                                                  .item_s_text
                                                          : model.cashDetails!
                                                              .pledgedAmount
                                                              .toString())
                                                  : (widget.isGoods
                                                          ? ''
                                                          : model.donorSevaUserId ==
                                                                  SevaCore.of(context)
                                                                      .loggedInUser
                                                                      .sevaUserID
                                                              ? '-'
                                                              : '+') +
                                                      (widget.isGoods
                                                          ? (model.goodsDetails?.donatedGoods != null
                                                                  ? model
                                                                      .goodsDetails!
                                                                      .donatedGoods!
                                                                      .length
                                                                      .toString()
                                                                  : '0') +
                                                              ' ' +
                                                              S.of(context).item_s_text
                                                          : model.cashDetails!.pledgedAmount.toString()),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: widget.fromTimebank
                                                      ? model.donorSevaUserId ==
                                                              timebankModel!.id
                                                          ? Colors.black
                                                          : Colors.green[400]
                                                      : model.donorSevaUserId ==
                                                              SevaCore.of(
                                                                      context)
                                                                  .loggedInUser
                                                                  .sevaUserID
                                                          ? Colors.black
                                                          : Colors.green[400]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
        ),
      ),
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
              flex: 4,
              child: getText(title2),
            ),
            SizedBox(width: 18),
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
        TextStyle(color: Colors.black, fontSize: 15, fontFamily: 'Europa');
    return Text(
      title,
      style: style,
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
    fontSize: 16,
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
                  data[index].donorSevaUserId!.contains('-')
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
                  data[index].donorSevaUserId!.contains('-')
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
                  DateTime.fromMillisecondsSinceEpoch(data[index].timestamp!)),
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
                                    .goodsDetails!
                                    .donatedGoods!
                                    .length
                                    .toString()
                                : '0') +
                            ' ' +
                            S.of(context).item_s_text
                        : data[index].cashDetails!.pledgedAmount.toString())
                : (data[index].donorSevaUserId ==
                            SevaCore.of(context).loggedInUser.sevaUserID
                        ? '-'
                        : '+') +
                    (isGoods
                        ? (data[index].goodsDetails?.donatedGoods != null
                                ? data[index]
                                    .goodsDetails!
                                    .donatedGoods!
                                    .length
                                    .toString()
                                : '0') +
                            ' ' +
                            S.of(context).item_s_text
                        : data[index].cashDetails!.pledgedAmount.toString()),
            style: TextStyle(
                fontSize: 16,
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
