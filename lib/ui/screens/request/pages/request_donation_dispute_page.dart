import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/request/bloc/request_donation_dispute_bloc.dart';
import 'package:sevaexchange/ui/screens/request/widgets/pledged_amount_card.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/donations/accept_modified_acknowlegement.dart';

import '../../../../flavor_config.dart';

enum _AckType { CASH, GOODS }
enum OperatingMode { CREATOR, USER }

class RequestDonationDisputePage extends StatefulWidget {
  final DonationModel model;
  // final Requestoe

  const RequestDonationDisputePage({
    Key key,
    this.model,
  }) : super(key: key);
  @override
  _RequestDonationDisputePageState createState() =>
      _RequestDonationDisputePageState();
}

class _RequestDonationDisputePageState
    extends State<RequestDonationDisputePage> {
  final RequestDonationDisputeBloc _bloc = RequestDonationDisputeBloc();
  _AckType ackType;
  OperatingMode operatingMode;

  ChatModeForDispute chatModeForDispute;

  @override
  void initState() {
    ackType = widget.model.donationType == RequestType.CASH
        ? _AckType.CASH
        : _AckType.GOODS;
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  void createMessage(
    isTimebankMessage,
    timebankId,
    communityId,
    sender,
    reciever,
  ) {
    createAndOpenChat(
      isTimebankMessage: isTimebankMessage,
      context: context,
      timebankId: timebankId,
      communityId: communityId,
      sender: sender,
      reciever: reciever,
      isFromRejectCompletion: false,
      onChatCreate: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Donations Received',
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
                      bloc: _bloc,
                      name: widget.model.donorDetails.name,
                      currency: '\$',
                      amount: widget.model.cashDetails.pledgedAmount.toString(),
                    )
                  : _GoodsFlow(bloc: _bloc),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  RaisedButton(
                    child: Text('Acknowledge'),
                    onPressed: () {
                      switch (ackType) {
                        case _AckType.CASH:
                          _bloc
                              .disputeCash(
                            pledgedAmount: widget
                                .model.cashDetails.pledgedAmount
                                .toDouble(),
                            operationMode: operatingMode,
                            donationId: widget.model.id,
                            donationModel: widget.model,
                            notificationId: widget.model.id,
                            requestMode: widget.model.donatedToTimebank
                                ? RequestMode.TIMEBANK_REQUEST
                                : RequestMode.PERSONAL_REQUEST,
                          )
                              .then(
                            (value) {
                              print(value);
                              if (value) {
                                Navigator.of(context).pop();
                              }
                            },
                          );
                          break;
                        case _AckType.GOODS:
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
                              print(value);
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
                    child: Text('Message'),
                    onPressed: () async {
                      operatingMode = OperatingMode.CREATOR;

                      switch (operatingMode) {
                        case OperatingMode.CREATOR:
                          if (widget.model.donatedToTimebank) {
                            chatModeForDispute =
                                ChatModeForDispute.TIMEBANK_TO_MEMBER;
                          } else {
                            chatModeForDispute =
                                ChatModeForDispute.MEMBER_TO_MEMBER;
                          }
                          break;

                        case OperatingMode.USER:
                          if (widget.model.donatedToTimebank) {
                            chatModeForDispute =
                                ChatModeForDispute.MEMBER_TO_TIMEBANK;
                          } else {
                            chatModeForDispute =
                                ChatModeForDispute.MEMBER_TO_MEMBER;
                          }
                          break;
                      }

                      switch (chatModeForDispute) {
                        case ChatModeForDispute.MEMBER_TO_MEMBER:
                          print("==========MEMBER_TO_MEMBER===============");
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
                          print("==========MEMBER_TO_TIMEBANK===============");
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
                          print("==========TIMEBANK_TO_MEMBER===============");
                          TimebankModel timebankModel = await getTimeBankForId(
                            timebankId: widget.model.timebankId,
                          );

                          var loggedInUser = SevaCore.of(context).loggedInUser;

                          await HandlerForModificationManager
                              .createChatForDispute(
                            communityId: loggedInUser.currentCommunity,
                            isTimebankMessage: true,
                            receiver: ParticipantInfo(
                              id: loggedInUser.sevaUserID,
                              name: loggedInUser.fullname,
                              photoUrl: loggedInUser.photoURL,
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
    this.name,
    this.amount,
    this.currency,
  })  : _bloc = bloc,
        super(key: key);

  final RequestDonationDisputeBloc _bloc;
  final String name;
  final String amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PledgedAmountCard(
          name: name,
          amount: amount,
          currency: currency,
        ),
        SizedBox(height: 40),
        Text(
          "Enter amount you have received",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        StreamBuilder<String>(
            stream: _bloc.cashAmount,
            builder: (context, snapshot) {
              return TextField(
                onChanged: _bloc.onAmountChanged,
                decoration: InputDecoration(
                  hintText: 'Amount',
                  hintStyle: TextStyle(fontSize: 12),
                ),
              );
            }),
        SizedBox(height: 30),
        Text(
          'I acknowledge that I have received amount',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Note: Check the amount you received and the transcation fees equals the user user donation.If it does not match please choose to message',
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
  })  : _bloc = bloc,
        super(key: key);

  final RequestDonationDisputeBloc _bloc;
  final Map<String, String> goods = {'1': 'Clothes', '2': 'Footwear'};

  @override
  Widget build(BuildContext context) {
    List<String> keys = List.from(goods.keys);
    return Column(
      children: [
        Text(
          'I acknowledge that i have received below',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20),
        StreamBuilder<Map<String, String>>(
          stream: _bloc.goodsRecieved,
          builder: (context, snapshot) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: goods.length,
              itemBuilder: (context, index) {
                String key = keys[index];
                return Row(
                  children: [
                    Checkbox(
                      activeColor: Colors.black,
                      checkColor: Colors.white,
                      value: snapshot.data?.containsKey(key) ?? false,
                      onChanged: (value) {
                        _bloc.toggleGoodsReceived(
                          key,
                          goods[key],
                        );
                      },
                    ),
                    SizedBox(width: 12),
                    Text('${goods[keys[index]]}')
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
