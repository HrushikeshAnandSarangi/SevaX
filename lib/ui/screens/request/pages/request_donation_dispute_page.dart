import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/request/bloc/request_donation_dispute_bloc.dart';
import 'package:sevaexchange/ui/screens/request/widgets/checkbox_with_text.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/donations/accept_modified_acknowlegement.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../flavor_config.dart';

enum _AckType { CASH, GOODS }

enum OperatingMode { CREATOR, USER }

String enteredReceivedAmount = '';

class RequestDonationDisputePage extends StatefulWidget {
  final DonationModel model;
  final String notificationId;
  final double convertedAmount;
  final String currency;
  final double convertedAmountRaised;

  const RequestDonationDisputePage({
    Key? key,
    required this.model,
    required this.notificationId,
    required this.convertedAmount,
    required this.currency,
    required this.convertedAmountRaised,
  }) : super(key: key);

  @override
  _RequestDonationDisputePageState createState() =>
      _RequestDonationDisputePageState();
}

class _RequestDonationDisputePageState
    extends State<RequestDonationDisputePage> {
  final RequestDonationDisputeBloc _bloc = RequestDonationDisputeBloc();
  int? AMOUNT_NOT_DEFINED = null;
  late _AckType ackType;
  late OperatingMode operatingMode;
  final _key = GlobalKey<ScaffoldState>();
  late ChatModeForDispute chatModeForDispute;
  late TimebankModel timebankModel;
  late ProgressDialog progressDialog;

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
      type: ProgressDialogType.normal,
      isDismissible: false,
    );
    progressDialog.style(
      progressWidget: Container(
        padding: EdgeInsets.all(8.0),
        child: LoadingIndicator(),
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
    FirestoreManager.getTimeBankForId(timebankId: widget.model.timebankId!)
        .then((value) {
      setState(() {
        timebankModel = value!;
      });
    });
    _bloc.initGoodsReceived(widget.model.goodsDetails!.donatedGoods!);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  void actionExecute(_key) async {
    if (widget.model.donationType == RequestType.CASH &&
        (double.tryParse(enteredReceivedAmount) ?? 0) <= 0) {
      showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(S.of(context).enter_valid_amount),
            actions: <Widget>[
              CustomTextButton(
                child: Text(
                  S.of(context).ok,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      var handleCallBackDisputeCash = ((value) {
        // print('Inside CallBackDisputeCash');
        progressDialog.hide();
        // hideProgress();
        if (value) {
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${S.of(context).general_stream_error}."),
            ),
          );
        }
      });

      ProgressDialog progressDialogNew = ProgressDialog(
        context,
        type: ProgressDialogType.normal,
        isDismissible: false,
      );
      progressDialogNew.style(
        progressWidget: Container(
          padding: EdgeInsets.all(8.0),
          child: LoadingIndicator(),
        ),
        message: S.of(context).please_wait,
      );

      var amount = widget.model.cashDetails!.pledgedAmount == null
          ? AMOUNT_NOT_DEFINED
          : widget.model.minimumAmount;
      switch (ackType) {
        case _AckType.CASH:
          // print('Inside, switch');
          // null will happen for widget.model.cashDetails.pledgedAmount when its a offer
          // requests flow (if is written for clarity sake if we handle this logic at pledgedAmount Itself if is not nessasary (recommendation rename pledgeAmount to amount)
          if (widget.model.requestIdType == 'offer' &&
              widget.model.donationStatus == DonationStatus.PLEDGED) {
//          id = widget.notificationId;
            amount = 0;
          }

          if (widget.model.cashDetails!.pledgedAmount != null) {
            bool validatorRes = await _bloc.validateAmount(
                minmumAmount: amount == AMOUNT_NOT_DEFINED ? 0 : amount);

            if (validatorRes) {
              logger.i(
                  "$validatorRes inside acknowledege if blockkkkkkkkkkkkkkkkkkkkk");

              FocusScope.of(context).unfocus();
              // if (widget.model.minimumAmount != null &&
              //     int.parse(_bloc.cashAmoutVal) >= widget.model.minimumAmount) {
              progressDialogNew.show();
              // }
              // showProgress(S.of(context).please_wait);
              bool disputeRes = await _bloc.disputeCash(
                pledgedAmount:
                    widget.model.cashDetails!.pledgedAmount!.toDouble(),
                operationMode: operatingMode,
                donationId: widget.model.id,
                donationModel: widget.model,
                notificationId: widget.model.notificationId,
                requestMode: widget.model.donatedToTimebank!
                    ? RequestMode.TIMEBANK_REQUEST
                    : RequestMode.PERSONAL_REQUEST,
              );
              logger.i(
                  "$disputeRes inside acknowledege if blockkkkkkkkkkkkkkkkkkkkk");
              progressDialogNew.hide();
              if (disputeRes) {
                Navigator.of(context).pop();
              } else {
                progressDialogNew.hide();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                if (widget.model.minimumAmount != null &&
                    int.parse(_bloc.cashAmoutVal) <
                        widget.model.minimumAmount!) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            S.of(context).amount_lessthan_donation_amount)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("${S.of(context).general_stream_error}.")),
                  );
                }
              }
            }
          } else {
            log("Inside Else part =================================");
            // offers flow initial requested flow and pledged later its works same as requests.

            _bloc
                .validateAmount(
                    minmumAmount: widget
                        .model.cashDetails!.cashDetails!.amountRaised!
                        .toInt())
                .then((value) {
              if (value) {
                FocusScope.of(context).unfocus();
                showProgress(S.of(context).please_wait);
                // amountRaised is used for requested amount before donor pledges the amount
                _bloc
                    .callDonateOfferCreatorPledge(
                      pledgedAmount: widget.convertedAmountRaised,
                      operationMode: operatingMode,
                      donationId: widget.model.id,
                      donationModel: widget.model,
                      notificationId: widget.model.notificationId,
                      requestMode: widget.model.donatedToTimebank!
                          ? RequestMode.TIMEBANK_REQUEST
                          : RequestMode.PERSONAL_REQUEST,
                    )
                    .then(handleCallBackDisputeCash);
              }
              logger.e("#AFTER ${widget.model.donationStatus}");
            }).catchError((onError) {
              log("Inside ERROR PART $onError");
            });
          }
          break;
        case _AckType.GOODS:
          if (_bloc.goodsRecievedVal.length == 0) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              action: SnackBarAction(
                label: S.of(context).dismiss,
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              ),
              content: Text("${S.of(context).add_goods_donate_empty}."),
            ));
            return;
          }
          progressDialogNew.show();

          if (widget.model.donationStatus == DonationStatus.REQUESTED &&
              widget.model.requestIdType == 'offer') {
            // for the offers.
            widget.model.donationStatus = DonationStatus.PLEDGED;
          }
          _bloc
              .disputeGoods(
            donatedGoods: widget.model.goodsDetails!.donatedGoods,
            donationId: widget.model.id,
            donationModel: widget.model,
            notificationId: widget.model.notificationId,
            operationMode: operatingMode,
            requestMode: widget.model.donatedToTimebank!
                ? RequestMode.TIMEBANK_REQUEST
                : RequestMode.PERSONAL_REQUEST,
          )
              .then((value) {
            if (value) {
              progressDialogNew.hide();
              Navigator.of(context).pop();
            }
          }).catchError((onError) {
            progressDialogNew.hide();
            logger.i(onError);
          });
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    operatingMode = widget.model.donorSevaUserId ==
            SevaCore.of(context).loggedInUser.sevaUserID
        ? OperatingMode.USER
        : OperatingMode.CREATOR;
    var name;
    var toWhom;
    if (widget.model.requestIdType == 'offer' &&
        widget.model.donationStatus == DonationStatus.REQUESTED) {
      name = widget.model.receiverDetails!.name;
    } else {
      name = widget.model.donorDetails!.name;
      toWhom = operatingMode == OperatingMode.USER
          ? widget.model.receiverDetails!.name
          : widget.model.donorDetails!.name;
    }
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
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
                      model: widget.model,
                      scaffoldKey: _key,
                      to: widget.model.cashDetails!.pledgedAmount != null
                          ? widget.model.requestIdType == 'offer'
                              ? toWhom
                              : widget.model.donationAssociatedTimebankDetails!
                                  .timebankTitle
                          : name,
                      title: widget.model.cashDetails!.pledgedAmount != null
                          ? '$name ${S.of(context).pledged_to_donate}'
                          : '$name ${S.of(context).requested.toLowerCase()}',
                      status: widget.model.donationStatus,
                      requestMode: widget.model.donatedToTimebank!
                          ? RequestMode.TIMEBANK_REQUEST
                          : RequestMode.PERSONAL_REQUEST,
                      timebankName: widget.model
                          .donationAssociatedTimebankDetails!.timebankTitle!,
                      creatorName: SevaCore.of(context).loggedInUser.fullname!,
                      operatingMode: operatingMode,
                      bloc: _bloc,
                      name: name,
                      currency: '${widget.currency}',
                      amount: widget.model.cashDetails!.pledgedAmount != null
                          ? widget.convertedAmount.toString()
                          : widget.convertedAmountRaised.toString(),
                      minAmount: widget.model.cashDetails!.pledgedAmount != null
                          ? widget.model.minimumAmount.toString()
                          : widget.model.cashDetails!.cashDetails!.amountRaised
                              .toString(),
                      others: widget.model.cashDetails!.cashDetails!.others!,
                    )
                  : _GoodsFlow(
                      status: widget.model.donationStatus,
                      operatingMode: operatingMode,
                      bloc: _bloc,
                      comments: widget.model.goodsDetails!.comments!,
                      // goods: Map<String, String>.from(
                      //   widget.model.goodsDetails.donatedGoods,
                      // ),
                      requiredGoods: widget.model.goodsDetails!.requiredGoods!,
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
                        widget.model.goodsDetails!.toAddress ?? '',
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
                  CustomElevatedButton(
                    child: Text(
                        widget.model.donationStatus == DonationStatus.REQUESTED
                            ? S.of(context).donate
                            : S.of(context).acknowledge),
                    onPressed: () => actionExecute(_key),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    elevation: 2.0,
                  ),
                  SizedBox(width: 12),
                  CustomElevatedButton(
                    child: Text(S.of(context).message),
                    color: Colors.orange,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    elevation: 2.0,
                    onPressed: () async {
                      var a = getOperatingMode(
                        operatingMode,
                        widget.model.donatedToTimebank!,
                      );

                      logger.wtf(widget.model.toMap());
                      switch (a) {
                        case ChatModeForDispute.MEMBER_TO_MEMBER:
                          var loggedInUser = SevaCore.of(context).loggedInUser;
                          String recieverId = widget.model.donorSevaUserId ==
                                  loggedInUser.sevaUserID
                              ? widget.model.donatedTo!
                              : widget.model.donorSevaUserId!;

                          UserModel fundRaiserDetails =
                              await FirestoreManager.getUserForId(
                            sevaUserId:
                                recieverId != null && !recieverId.contains('-')
                                    ? recieverId
                                    : widget.model.donatedTo!,
                          );
                          logger.wtf(widget.model.donorDetails!.communityId !=
                              widget.model.receiverDetails!.communityId);

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
                            timeBankId: widget.model.timebankId!,
                            isTimebankMessage: false,
                            communityId: loggedInUser.currentCommunity!,
                            entityId: widget.model.id!,
                            showToCommunities: widget.model.requestIdType ==
                                    'offer'
                                ? [
                                    widget.model.donorDetails!.communityId!,
                                    widget.model.receiverDetails!.communityId!,
                                  ]
                                : [
                                    widget.model.donorDetails!.communityId!,
                                    timebankModel.communityId
                                  ],
                            interCommunity: widget.model.requestIdType ==
                                    'offer'
                                ? widget.model.donorDetails!.communityId !=
                                    widget.model.receiverDetails!.communityId
                                : widget.model.donorDetails!.communityId !=
                                    timebankModel.communityId,
                          );
                          break;

                        case ChatModeForDispute.MEMBER_TO_TIMEBANK:
                          TimebankModel timebankModel = (await getTimeBankForId(
                            timebankId: widget.model.timebankId!,
                          ))!;
                          var loggedInUser = SevaCore.of(context).loggedInUser;

                          await HandlerForModificationManager
                              .createChatForDispute(
                            entityId: widget.model.id!,
                            showToCommunities: widget.model.requestIdType ==
                                    'offer'
                                ? [
                                    widget.model.donorDetails!.communityId!,
                                    widget.model.receiverDetails!.communityId!,
                                  ]
                                : [
                                    widget.model.donorDetails!.communityId!,
                                    timebankModel.communityId
                                  ],
                            interCommunity: widget.model.requestIdType ==
                                    'offer'
                                ? widget.model.donorDetails!.communityId !=
                                    widget.model.receiverDetails!.communityId
                                : widget.model.donorDetails!.communityId !=
                                    timebankModel.communityId,
                            communityId: loggedInUser.currentCommunity!,
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
                            timeBankId: widget.model.timebankId!,
                            isTimebankMessage: true,
                          );
                          break;

                        case ChatModeForDispute.TIMEBANK_TO_MEMBER:
                          TimebankModel timebankModel = (await getTimeBankForId(
                            timebankId: widget.model.timebankId!,
                          ))!;

                          var loggedInUser = SevaCore.of(context).loggedInUser;

                          await HandlerForModificationManager
                              .createChatForDispute(
                            communityId: loggedInUser.currentCommunity!,
                            isTimebankMessage: true,
                            receiver: ParticipantInfo(
                              id: widget.model.donorSevaUserId,
                              name: widget.model.donorDetails!.name,
                              photoUrl: widget.model.donorDetails!.photoUrl,
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
                            timeBankId: widget.model.timebankId!,
                            entityId: widget.model.id!,
                            showToCommunities: widget.model.requestIdType ==
                                    'offer'
                                ? [
                                    widget.model.donorDetails!.communityId!,
                                    widget.model.receiverDetails!.communityId!,
                                  ]
                                : [
                                    widget.model.donorDetails!.communityId!,
                                    timebankModel.communityId
                                  ],
                            interCommunity: widget.model.requestIdType ==
                                    'offer'
                                ? widget.model.donorDetails!.communityId !=
                                    widget.model.receiverDetails!.communityId
                                : widget.model.donorDetails!.communityId !=
                                    timebankModel.communityId,
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
    Key? key,
    required RequestDonationDisputeBloc bloc,
    this.model,
    this.scaffoldKey,
    this.title,
    this.to,
    this.status,
    required this.name,
    required this.amount,
    required this.currency,
    required this.operatingMode,
    required this.timebankName,
    required this.creatorName,
    required this.requestMode,
    required this.minAmount,
    required this.others,
  })  : _bloc = bloc,
        super(key: key);
  final model;
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
  final String others;
  final RequestMode requestMode;
  final OperatingMode operatingMode;
  final scaffoldKey;

  Widget getACHDetails(BuildContext context, data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "${S.of(context).account_no} : " + data.achdetails.account_number,
        ),
        Text(
          "${S.of(context).bank_address} : " + data.achdetails.bank_address,
        ),
        Text(
          "${S.of(context).bank_name} : " + data.achdetails.bank_name,
        ),
        Text(
          "${S.of(context).routing_number} : " + data.achdetails.routing_number,
        ),
      ],
    );
  }

  String modeOfPayment(BuildContext context) {
    if (model != null &&
        model.cashDetails != null &&
        model.cashDetails.cashDetails != null &&
        model.donationType == RequestType.CASH) {
      switch (model.cashDetails.cashDetails.paymentType) {
        case RequestPaymentType.ACH:
          return S.of(context).request_paymenttype_ach;
        case RequestPaymentType.ZELLEPAY:
          return S.of(context).request_paymenttype_zellepay;
        case RequestPaymentType.PAYPAL:
          return S.of(context).request_paymenttype_paypal;
        case RequestPaymentType.VENMO:
          return S.of(context).request_paymenttype_venmo;
        case RequestPaymentType.SWIFT:
          return S.of(context).request_paymenttype_swift;
        case RequestPaymentType.OTHER:
          return S.of(context).other;
        default:
          return "";
      }
    }
    return "";
  }

  getDonationLink(BuildContext context) {
    if (model != null &&
        model.cashDetails != null &&
        model.cashDetails.cashDetails != null &&
        model.donationType == RequestType.CASH) {
      switch (model.cashDetails.cashDetails.paymentType) {
        case RequestPaymentType.ACH:
          return getACHDetails(context, model.cashDetails.cashDetails);
          break;
        case RequestPaymentType.ZELLEPAY:
          return model.cashDetails.cashDetails.zelleId;
        case RequestPaymentType.PAYPAL:
          return model.cashDetails.cashDetails.paypalId ?? '';
        case RequestPaymentType.VENMO:
          return model.cashDetails.cashDetails.venmoId ?? '';
        case RequestPaymentType.SWIFT:
          return model.cashDetails.cashDetails.swiftId ?? '';
        case RequestPaymentType.OTHER:
          return "${model.cashDetails.cashDetails.others ?? ''} ${model.cashDetails.cashDetails.other_details ?? ''}";

        default:
          return "Link not registered!";
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    void showScaffold(context, String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    }

    Widget offerDonatePaymentDetails() {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${S.of(context).donation_description_one + ' $name:' + ' $amount' + S.of(context).donation_description_three}',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              S.of(context).payment_link_description,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.normal),
            ),
            SizedBox(
              height: 10,
            ),
            HideWidget(
              hide: others == null,
              child: Text(
                'Other Details',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              secondChild: SizedBox.shrink(),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              others ?? '',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              S.of(context).request_payment_description +
                  ': ' +
                  modeOfPayment(context),
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            model.cashDetails.cashDetails.paymentType == RequestPaymentType.ACH
                ? getDonationLink(context)
                : InkWell(
                    onLongPress: () {
                      Clipboard.setData(
                          ClipboardData(text: model.donationInstructionLink));
                      showScaffold(context, S.of(context).copied_to_clipboard);
                    },
                    onTap: () async {
                      String link = getDonationLink(context);
                      if (await canLaunch(link)) {
                        await launch(link);
                      } else {
                        showScaffold(context, 'Could not launch');
                      }
                    },
                    child: Text(
                      getDonationLink(context) ?? '',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
            SizedBox(
              height: 20,
            ),
          ]));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 25,
          child: Icon(Icons.check, size: 30),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        SizedBox(height: 10),
        Text(
          '$title',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Text(
          '$currency $amount',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(
          height: 20,
        ),
        model.requestIdType == 'offer' &&
                model.donationStatus == DonationStatus.REQUESTED
            ? offerDonatePaymentDetails()
            : Text(''),
        Divider(
          thickness: 1,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          operatingMode == OperatingMode.CREATOR
              ? "${S.of(context).amount_received_from} ${name}"
              : S.of(context).amount_pledged,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey),
        ),
        SizedBox(
          height: 10,
        ),
        StreamBuilder<String>(
            stream: _bloc.cashAmount,
            builder: (context, snapshot) {
              return TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                  ],
                  onChanged: (val) {
                    _bloc.onAmountChanged(val);
                    enteredReceivedAmount = val;
                  },
                  decoration: InputDecoration(
                    prefixIconConstraints: BoxConstraints(maxWidth: 50.0),
                    prefixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          currency,
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                    errorText: snapshot.error == 'min'
                        ? S.of(context).minmum_amount + ' ' + minAmount
                        : snapshot.error == 'amount1'
                            ? S.of(context).enter_valid_amount
                            : null,
                    hintText: S.of(context).amount,
                    hintStyle: TextStyle(fontSize: 12),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return S.of(context).add_amount_donate_empty;
                    } else if (double.parse(value!) <= 0) {
                      return S.of(context).minmum_amount + ' ${currency} 1';
                    } else {
                      return null;
                    }
                  });
            }),
        SizedBox(height: 30),
        Text(
          operatingMode == OperatingMode.CREATOR
              ? '${S.of(context).i_received_amount} $currency ${amount}'
              : S.of(context).i_pledged_amount,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Text(
          operatingMode == OperatingMode.CREATOR
              ? '${S.of(context).acknowledge_desc_one} ${name}. ${S.of(context).acknowledge_desc_two} ${name}'
              : '${S.of(context).acknowledge_desc_donor_one} ${to} ${S.of(context).acknowledge_desc_donor_two}',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _GoodsFlow extends StatelessWidget {
  const _GoodsFlow({
    Key? key,
    required RequestDonationDisputeBloc bloc,
    // this.goods,
    this.status,
    required this.requiredGoods,
    required this.operatingMode,
    required this.comments,
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
        CircleAvatar(
          radius: 25,
          child: Icon(Icons.check, size: 30),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        SizedBox(height: 10),
        Text(
          status == DonationStatus.REQUESTED &&
                  operatingMode == OperatingMode.CREATOR
              ? S.of(context).request_goods_offer.replaceAll("  ", " ")
              : operatingMode == OperatingMode.CREATOR
                  ? S.of(context).acknowledge_received
                  : S.of(context).acknowledge_donated,
          style: TextStyle(
              fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        comments != null
            ? Text(
                comments ?? '',
                style: TextStyle(fontSize: 16, color: Colors.black),
              )
            : Offstage(),
        SizedBox(height: 20),
        StreamBuilder<Map<String, String>>(
          stream: _bloc.goodsRecieved,
          builder: (context, snapshot) {
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: requiredGoods.length,
              itemBuilder: (context, index) {
                String key = keys[index];
                return CheckboxWithText(
                  value: snapshot.data?.containsKey(key) ?? false,
                  onChanged: (value) {
                    _bloc.toggleGoodsReceived(
                      key,
                      requiredGoods[key]!,
                    );
                  },
                  text: requiredGoods[keys[index]].toString(),
                );
              },
            );
          },
        ),
        Text(
          S.of(context).donation_dispute_info,
          style: TextStyle(color: Colors.grey, fontSize: 11),
        )
      ],
    );
  }
}
