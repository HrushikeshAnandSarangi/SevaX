import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/request/bloc/request_donation_dispute_bloc.dart';
import 'package:sevaexchange/ui/screens/request/widgets/checkbox_with_text.dart';
import 'package:sevaexchange/ui/screens/request/widgets/pledged_amount_card.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/donations/accept_modified_acknowlegement.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';

import '../../../../flavor_config.dart';

enum _AckType { CASH, GOODS }
enum OperatingMode { CREATOR, USER }

class RequestDonationDisputePage extends StatefulWidget {
  final DonationModel model;
  final String notificationId;

  const RequestDonationDisputePage({
    Key key,
    @required this.model,
    this.notificationId,
  }) : super(key: key);
  @override
  _RequestDonationDisputePageState createState() =>
      _RequestDonationDisputePageState();
}

class _RequestDonationDisputePageState
    extends State<RequestDonationDisputePage> {
  final RequestDonationDisputeBloc _bloc = RequestDonationDisputeBloc();
  int AMOUNT_NOT_DEFINED = 0;
  _AckType ackType;
  OperatingMode operatingMode;
  final _key = GlobalKey<ScaffoldState>();
  ChatModeForDispute chatModeForDispute;
  TimebankModel timebankModel;
  ProgressDialog progressDialog;
  final TextStyle titleStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );
  final TextStyle subTitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.black,
  );
  void showProgress(String message) {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    progressDialog.style(
      progressWidget: Container(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      ),
      message: message,
    );
    progressDialog.show();
  }

  void hideProgress() {
    progressDialog.hide();
  }

  @override
  void initState() {
    ackType = widget.model.donationType == RequestType.CASH
        ? _AckType.CASH
        : _AckType.GOODS;
    super.initState();
    FirestoreManager.getTimeBankForId(timebankId: widget.model.timebankId)
        .then((value) {
      setState(() {
        timebankModel = value;
      });
    });
    widget.model.goodsDetails.donatedGoods;
    _bloc.initGoodsReceived(widget.model.goodsDetails.donatedGoods);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    operatingMode = widget.model.donorSevaUserId ==
            SevaCore.of(context).loggedInUser.sevaUserID
        ? OperatingMode.USER
        : OperatingMode.CREATOR;
    var name = widget.model.donorDetails.name;
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text(
          widget.model.donationStatus == DonationStatus.REQUESTED
              ? S.of(context).donate
              : operatingMode == OperatingMode.USER
                  ? S.of(context).donations_requested
                  : S.of(context).donations_received,
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
                      to: widget.model.cashDetails.pledgedAmount != null
                          ? widget.model.donationAssociatedTimebankDetails
                              .timebankTitle
                          : widget.model.donorDetails.name,
                      title: widget.model.cashDetails.pledgedAmount != null
                          ? '$name ${S.of(context).pledged_to_donate}'
                          : '$name ${S.of(context).requested.toLowerCase()}',
                      status: widget.model.donationStatus,
                      requestMode: widget.model.donatedToTimebank
                          ? RequestMode.TIMEBANK_REQUEST
                          : RequestMode.PERSONAL_REQUEST,
                      timebankName: widget.model
                          .donationAssociatedTimebankDetails.timebankTitle,
                      creatorName: SevaCore.of(context).loggedInUser.fullname,
                      operatingMode: operatingMode,
                      bloc: _bloc,
                      name: name,
                      currency: '\$',
                      amount: widget.model.cashDetails.pledgedAmount != null
                          ? widget.model.cashDetails.pledgedAmount.toString()
                          : widget.model.cashDetails.cashDetails.amountRaised
                              .toString(),
                      minAmount: widget.model.minimumAmount.toString(),
                    )
                  : _GoodsFlow(
                      status: widget.model.donationStatus,
                      operatingMode: operatingMode,
                      bloc: _bloc,
                      comments: widget.model.goodsDetails.comments,
                      // goods: Map<String, String>.from(
                      //   widget.model.goodsDetails.donatedGoods,
                      // ),
                      requiredGoods: widget.model.goodsDetails.requiredGoods,
                    ),
              widget.model.donationStatus == DonationStatus.REQUESTED &&
                      widget.model.donationType == RequestType.GOODS
                  ? CustomListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Colors.black54,
                      ),
                      title: Text(
                        S.of(context).offer_to_sent_at,
                        style: titleStyle,
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        widget.model.goodsDetails.toAddress,
                        style: subTitleStyle,
                        maxLines: 1,
                      ),
                    )
                  : Container(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  RaisedButton(
                    child: Text(
                        widget.model.donationStatus == DonationStatus.REQUESTED
                            ? S.of(context).donate
                            : S.of(context).acknowledge),
                    onPressed: () {
                      if (widget.model.donationStatus ==
                          DonationStatus.REQUESTED) {
                        // for the offers.
                        widget.model.goodsDetails.donatedGoods =
                            _bloc.getgoodsRecieved();
                      }
                      var amount =
                          widget.model.cashDetails.pledgedAmount == null
                              ? AMOUNT_NOT_DEFINED
                              : widget.model.cashDetails.pledgedAmount;
                      switch (ackType) {
                        case _AckType.CASH:
                          // null will happen for widget.model.cashDetails.pledgedAmount when its a offer
                          _bloc
                              .validateAmount(
                                  minmumAmount: widget.model.minimumAmount ?? 0)
                              .then((value) {
                            if (value) {
                              FocusScope.of(context).unfocus();
                              showProgress(S.of(context).please_wait);
                              _bloc
                                  .disputeCash(
                                pledgedAmount: amount.toDouble(),
                                operationMode: operatingMode,
                                donationId: widget.model.id,
                                donationModel: widget.model,
                                notificationId: widget.model.notificationId,
                                requestMode: widget.model.donatedToTimebank
                                    ? RequestMode.TIMEBANK_REQUEST
                                    : RequestMode.PERSONAL_REQUEST,
                              )
                                  .then(
                                (value) {
                                  hideProgress();
                                  if (value) {
                                    Navigator.of(context).pop();
                                  } else {
                                    _key.currentState.hideCurrentSnackBar();
                                    _key.currentState.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          S.of(context).general_stream_error +
                                              ' ' +
                                              S.of(context).try_later +
                                              '.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                          });
                          break;
                        case _AckType.GOODS:
                          log("Donated Goods" +
                              widget.model.goodsDetails.donatedGoods
                                  .toString());
                          showProgress(S.of(context).please_wait);

                          _bloc
                              .disputeGoods(
                            donatedGoods:
                                widget.model.goodsDetails.donatedGoods,
                            donationId: widget.model.id,
                            donationModel: widget.model,
                            notificationId: widget.model.notificationId,
                            operationMode: operatingMode,
                            requestMode: widget.model.donatedToTimebank
                                ? RequestMode.TIMEBANK_REQUEST
                                : RequestMode.PERSONAL_REQUEST,
                          )
                              .then(
                            (value) {
                              hideProgress();
                              if (value) {
                                Navigator.of(context).pop();
                              }
                            },
                          );
                          break;
                      }
                    },
                  ),
                  SizedBox(width: 12),
                  RaisedButton(
                    child: Text(S.of(context).message),
                    onPressed: () async {
                      var operatingModel = getOperatingMode(
                        operatingMode,
                        widget.model.donatedToTimebank,
                      );

                      switch (operatingModel) {
                        case ChatModeForDispute.MEMBER_TO_MEMBER:
                          UserModel fundRaiserDetails =
                              await FirestoreManager.getUserForId(
                            sevaUserId: widget.model.donatedTo,
                          );
                          var loggedInUser = SevaCore.of(context).loggedInUser;

                          await HandlerForModificationManager
                              .createChatForDispute(
                            sender: ParticipantInfo(
                              id: loggedInUser.sevaUserID,
                              name: loggedInUser.fullname,
                              photoUrl: loggedInUser.photoURL,
                              type: ChatType.TYPE_PERSONAL,
                            ),
                            receiver: ParticipantInfo(
                              id: fundRaiserDetails.sevaUserID,
                              name: fundRaiserDetails.fullname,
                              photoUrl: fundRaiserDetails.photoURL,
                              type: ChatType.TYPE_PERSONAL,
                            ),
                            context: context,
                            timeBankId: widget.model.timebankId,
                            isTimebankMessage: false,
                            communityId: loggedInUser.currentCommunity,
                          );
                          break;

                        case ChatModeForDispute.MEMBER_TO_TIMEBANK:
                          TimebankModel timebankModel = await getTimeBankForId(
                            timebankId: widget.model.timebankId,
                          );
                          var loggedInUser = SevaCore.of(context).loggedInUser;
                          await HandlerForModificationManager
                              .createChatForDispute(
                            communityId: loggedInUser.currentCommunity,
                            sender: ParticipantInfo(
                              id: loggedInUser.sevaUserID,
                              name: loggedInUser.fullname,
                              photoUrl: loggedInUser.photoURL,
                              type: ChatType.TYPE_PERSONAL,
                            ),
                            receiver: ParticipantInfo(
                              id: timebankModel.id,
                              type: timebankModel.parentTimebankId ==
                                      FlavorConfig.values
                                          .timebankId //check if timebank is primary timebank
                                  ? ChatType.TYPE_TIMEBANK
                                  : ChatType.TYPE_GROUP,
                              name: timebankModel.name,
                              photoUrl: timebankModel.photoUrl,
                            ),
                            context: context,
                            timeBankId: widget.model.timebankId,
                            isTimebankMessage: true,
                          );
                          break;

                        case ChatModeForDispute.TIMEBANK_TO_MEMBER:
                          TimebankModel timebankModel = await getTimeBankForId(
                            timebankId: widget.model.timebankId,
                          );

                          var loggedInUser = SevaCore.of(context).loggedInUser;

                          await HandlerForModificationManager
                              .createChatForDispute(
                            communityId: loggedInUser.currentCommunity,
                            isTimebankMessage: true,
                            receiver: ParticipantInfo(
                              id: widget.model.donorSevaUserId,
                              name: widget.model.donorDetails.name,
                              photoUrl: widget.model.donorDetails.photoUrl,
                              type: ChatType.TYPE_PERSONAL,
                            ),
                            sender: ParticipantInfo(
                              id: timebankModel.id,
                              type: timebankModel.parentTimebankId ==
                                      FlavorConfig.values
                                          .timebankId //check if timebank is primary timebank
                                  ? ChatType.TYPE_TIMEBANK
                                  : ChatType.TYPE_GROUP,
                              name: timebankModel.name,
                              photoUrl: timebankModel.photoUrl,
                            ),
                            context: context,
                            timeBankId: widget.model.timebankId,
                          );
                          break;
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ChatModeForDispute getOperatingMode(
    OperatingMode operatingMode,
    bool donatedToTimebank,
  ) {
    switch (operatingMode) {
      case OperatingMode.CREATOR:
        if (donatedToTimebank)
          return ChatModeForDispute.TIMEBANK_TO_MEMBER;
        else
          return ChatModeForDispute.MEMBER_TO_MEMBER;

        break;

      case OperatingMode.USER:
        if (donatedToTimebank)
          return ChatModeForDispute.MEMBER_TO_TIMEBANK;
        else
          return ChatModeForDispute.MEMBER_TO_MEMBER;
    }
  }
}

enum ChatModeForDispute {
  MEMBER_TO_MEMBER,
  MEMBER_TO_TIMEBANK,
  TIMEBANK_TO_MEMBER,
}

class _CashFlow extends StatelessWidget {
  const _CashFlow({
    Key key,
    @required RequestDonationDisputeBloc bloc,
    this.title,
    this.to,
    this.status,
    this.name,
    this.amount,
    this.currency,
    this.operatingMode,
    this.timebankName,
    this.creatorName,
    this.requestMode,
    this.minAmount,
  })  : _bloc = bloc,
        super(key: key);
  final to;
  final title;
  final status;
  final RequestDonationDisputeBloc _bloc;
  final String name;
  final String amount;
  final String minAmount;
  final String currency;
  final String timebankName;
  final String creatorName;
  final RequestMode requestMode;
  final OperatingMode operatingMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PledgedAmountCard(
          title: title,
          name: name,
          amount: amount,
          currency: currency,
        ),
        SizedBox(height: 40),
        Text(
          operatingMode == OperatingMode.CREATOR
              ? "${S.of(context).amount_received_from} ${name}"
              : S.of(context).amount_pledged,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        StreamBuilder<String>(
            stream: _bloc.cashAmount,
            builder: (context, snapshot) {
              return TextField(
                onChanged: _bloc.onAmountChanged,
                decoration: InputDecoration(
                  errorText: snapshot.error == 'min'
                      ? S.of(context).minmum_amount + ' ' + minAmount
                      : snapshot.error == 'amount1'
                          ? S.of(context).enter_valid_amount
                          : null,
                  hintText: S.of(context).amount,
                  hintStyle: TextStyle(fontSize: 12),
                ),
              );
            }),
        SizedBox(height: 30),
        Text(
          operatingMode == OperatingMode.CREATOR
              ? '${S.of(context).i_received_amount} \$${amount}'
              : S.of(context).i_pledged_amount,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Text(
          operatingMode == OperatingMode.CREATOR
              ? '${S.of(context).acknowledge_desc_one} $name. ${S.of(context).acknowledge_desc_two} $name'
              : '${S.of(context).acknowledge_desc_donor_one} $to ${S.of(context).acknowledge_desc_donor_two}',
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
    this.status,
    this.requiredGoods,
    this.operatingMode,
    this.comments,
  })  : _bloc = bloc,
        super(key: key);
  final status;
  final RequestDonationDisputeBloc _bloc;
  // final Map<String, String> goods;
  final Map<String, String> requiredGoods;
  final OperatingMode operatingMode;
  final String comments;

  @override
  Widget build(BuildContext context) {
    List<String> keys = List.from(requiredGoods.keys);
    return Column(
      children: [
        Text(
          status == DonationStatus.REQUESTED
              ? S.of(context).request_goods_offer
              : operatingMode == OperatingMode.CREATOR
                  ? S.of(context).acknowledge_received
                  : S.of(context).acknowledge_donated,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 8),
        comments != null
            ? Text(
                comments ?? '',
                style: TextStyle(fontSize: 16),
              )
            : Offstage(),
        SizedBox(height: 20),
        StreamBuilder<Map<String, String>>(
          stream: _bloc.goodsRecieved,
          builder: (context, snapshot) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: requiredGoods.length,
              itemBuilder: (context, index) {
                String key = keys[index];
                return CheckboxWithText(
                  value: snapshot.data?.containsKey(key) ?? false,
                  onChanged: (value) {
                    _bloc.toggleGoodsReceived(
                      key,
                      requiredGoods[key],
                    );
                  },
                  text: requiredGoods[keys[index]],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
