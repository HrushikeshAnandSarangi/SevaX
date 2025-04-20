import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/request/pages/goods_display_page.dart';
import 'package:sevaexchange/ui/screens/transaction_details/dialog/transaction_details_dialog.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class GoodsAndAmountDonationsList extends StatefulWidget {
  final String? type;
  final String? timebankid;
  final bool? isGoods;
  const GoodsAndAmountDonationsList({this.type, this.timebankid, this.isGoods});
  @override
  _GoodsAndAmountDonationsState createState() =>
      _GoodsAndAmountDonationsState();
}

class _GoodsAndAmountDonationsState extends State<GoodsAndAmountDonationsList> {
  List<DonationModel> donationsList = [];
  //List<UserModel> userList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.type == 'user') {
      FirestoreManager.getDonationList(
              isGoods: widget.isGoods,
              userId: SevaCore.of(context).loggedInUser.sevaUserID)
          .listen(
        (result) {
          if (!mounted) return;
          donationsList = result;
          setState(() {});
        },
      );
    } else if (widget.type == 'timebank') {
      FirestoreManager.getDonationList(
        timebankId: widget.timebankid,
        isGoods: widget.isGoods,
      ).listen(
        (result) {
          if (!mounted) return;
          donationsList = result;
          setState(() {});
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext mainContext) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${S.of(mainContext).donations}',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: donationsList.length == 0
          ? Center(
              child: Text(S.of(mainContext).no_donation_yet),
            )
          : FutureBuilder<Object>(
              future: FirestoreManager.getUserForId(
                  sevaUserId:
                      SevaCore.of(mainContext).loggedInUser.sevaUserID!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    S.of(context).general_stream_error,
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingIndicator();
                }
                UserModel userModel = snapshot.data! as UserModel;
                String usertimezone = userModel.timezone!;
                return ListView.builder(
                  itemBuilder: (context, index) {
                    DonationModel model = donationsList.elementAt(index);

                    return Container(
                      margin: EdgeInsets.all(1),
                      child: Card(
                        child: DonationListItem(
                            model: model,
                            isGoods: widget.isGoods!,
                            usertimezone: usertimezone,
                            viewtype: widget.type,
                            mainContext: mainContext),
                      ),
                    );
                  },
                  itemCount: donationsList.length,
                );
              }),
    );
  }
}

class DonationListItem extends StatelessWidget {
  final DonationModel? model;
  final String? viewtype;
  final String? usertimezone;
  final bool? isGoods;
  final BuildContext? mainContext;

  const DonationListItem(
      {Key? key,
      this.model,
      this.usertimezone,
      this.viewtype,
      this.isGoods,
      this.mainContext})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: viewtype == 'user'
            ? FirestoreManager.getTimeBankForId(timebankId: model!.timebankId!)
            : FirestoreManager.getUserForId(
                sevaUserId: model!.donorSevaUserId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('');
          }
          return ListTile(
              onTap: () async {
                RequestModel? requestModel;
                TimebankModel timebankModel = TimebankModel({});
                CommunityModel communityModel = CommunityModel({});
                try {
                  requestModel = await FirestoreManager.getRequestFutureById(
                      requestId: model!.requestId!);
                } catch (error) {
                  logger.e('ERROR FETCHING MODELS FOR TRANSACTIONS: ' +
                      error.toString());
                }
                try {
                  timebankModel = (await FirestoreManager.getTimeBankForId(
                      timebankId: model!.timebankId!))!;
                  logger.e('TIMEBANK MODEL MONEY DIALOG: ' +
                      timebankModel.name.toString());
                  communityModel =
                      await FirestoreManager.getCommunityDetailsByCommunityId(
                          communityId: model!.communityId!);
                } catch (e) {
                  logger.e('error fetching timebank and/or community model: ' +
                      e.toString());
                }

                Future.delayed(Duration(milliseconds: 500), () {
                  isGoods!
                      ? showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            insetPadding: EdgeInsets.zero,
                            child: TransactionDetailsDialog(
                              transactionModel: TransactionModel(
                                fromEmail_Id: SevaCore.of(mainContext!)
                                    .loggedInUser
                                    .email!,
                                toEmail_Id: SevaCore.of(mainContext!)
                                    .loggedInUser
                                    .email!,
                                communityId: communityModel.id,
                              ),
                              donationModel: model!,
                              timebankModel: timebankModel,
                              requestModel: requestModel!,
                              communityModel: communityModel!,
                              loggedInUserId: SevaCore.of(mainContext!)
                                  .loggedInUser
                                  .sevaUserID!,
                              loggedInEmail:
                                  SevaCore.of(mainContext!).loggedInUser.email!,
                            ),
                          ),
                        )
                      // Navigator.of(context).push(
                      //     MaterialPageRoute(
                      //       builder: (context) => GoodsDisplayPage(
                      //         label: S.of(context).donations_received,
                      //         name: model.donorDetails.name ?? '',
                      //         photoUrl: model.donorDetails.photoUrl,
                      //         goods:
                      //             model.goodsDetails?.donatedGoods != null
                      //                 ? List<String>.from(
                      //                     model.goodsDetails.donatedGoods
                      //                         .values,
                      //                   )
                      //                 : [],
                      //         message: model.goodsDetails.comments ??
                      //             S.of(context).donated +
                      //                 ' ' +
                      //                 S.of(context).goods.toLowerCase(),
                      //       ),
                      //     ),
                      //   )
                      //(previous code above)

                      : showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            insetPadding: EdgeInsets.zero,
                            child: TransactionDetailsDialog(
                              transactionModel: TransactionModel(
                                  fromEmail_Id: '',
                                  toEmail_Id: '',
                                  communityId: ''),
                              donationModel: model!,
                              timebankModel: timebankModel,
                              requestModel: requestModel!,
                              communityModel: communityModel,
                              loggedInUserId: SevaCore.of(mainContext!)
                                  .loggedInUser
                                  .sevaUserID!,
                              loggedInEmail:
                                  SevaCore.of(mainContext!).loggedInUser.email!,
                            ),
                          ),
                        );
                  //null  (previous code)
                });
              },
              leading: DonationImageItem(
                model: model,
                snapshot: snapshot,
                type: viewtype!,
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  !isGoods!
                      ? Text(
                          '\$' +
                              '${model!.cashDetails!.pledgedAmount ?? 0.toString()}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
                          '${model!.goodsDetails?.donatedGoods != null ? model!.goodsDetails!.donatedGoods!.values.length.toString() : 0.toString()} ${S.of(context).items}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
//                  Text(
//                    S.of(context).seva_credits,
//                    style: TextStyle(
//                      fontSize: 10,
//                      fontWeight: FontWeight.w600,
//                      letterSpacing: -0.2,
//                    ),
//                  ),
                ],
              ),
              subtitle: DonationItem(
                  requestName: model!.requestTitle!,
                  name: viewtype == 'user'
                      ? (snapshot.data as TimebankModel).name +
                          " (${S.of(context).timebank})"
                      : ((snapshot.data as UserModel).fullname ??
                          S.of(context).anonymous),
                  timestamp: model!.timestamp!,
                  usertimezone: usertimezone));
        });
  }
}

class DonationItem extends StatelessWidget {
  final name;
  final String? requestName;
  final timestamp;
  final usertimezone;
  DonationItem(
      {this.name, this.timestamp, this.usertimezone, this.requestName});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 2,
        ),
        Text(
          '${name}',
          textAlign: TextAlign.start,
        ),
        Text(
          requestName!,
          textAlign: TextAlign.start,
        ),
        SizedBox(
          height: 2,
        ),
        Text(
          DateFormat('MMM dd, yyyy', Locale(getLangTag()).toLanguageTag())
              .format(
            getDateTimeAccToUserTimezone(
                dateTime: DateTime.fromMillisecondsSinceEpoch(timestamp),
                timezoneAbb: usertimezone),
          ),
          textAlign: TextAlign.start,
        ),
        SizedBox(
          height: 2,
        ),
      ],
    );
  }
}

class DonationImageItem extends StatelessWidget {
  final model;
  final snapshot;
  final String? type;
  DonationImageItem({this.model, this.snapshot, this.type});
  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      return CircleAvatar();
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircleAvatar();
    }
    if (type == 'timebank') {
      UserModel user = snapshot.data;
      //Fallback in case the condition anyhow
      if (user == null)
        return CircleAvatar(
          backgroundImage: NetworkImage(defaultUserImageURL),
        );

      return CircleAvatar(
        backgroundImage: NetworkImage(user.photoURL ?? defaultUserImageURL),
      );
    } else {
      TimebankModel timebanktemp = snapshot.data;
      return CircleAvatar(
        backgroundImage:
            NetworkImage(timebanktemp.photoUrl ?? defaultUserImageURL),
      );
    }
  }
}
