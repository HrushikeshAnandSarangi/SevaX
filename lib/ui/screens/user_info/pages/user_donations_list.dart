import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class UserDonationList extends StatefulWidget {
  final String type;
  final String timebankid;
  final bool isGoods;
  const UserDonationList({this.type, this.timebankid, this.isGoods});
  @override
  _UserDonationListState createState() => _UserDonationListState();
}

class _UserDonationListState extends State<UserDonationList> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Donations',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: donationsList.length == 0
          ? Center(
              child: Text(S.of(context).no_transactions_yet),
            )
          : FutureBuilder<Object>(
              future: FirestoreManager.getUserForId(
                  sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    S.of(context).general_stream_error,
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                UserModel userModel = snapshot.data;
                String usertimezone = userModel.timezone;
                return ListView.builder(
                  itemBuilder: (context, index) {
                    DonationModel model = donationsList.elementAt(index);

                    return Container(
                      margin: EdgeInsets.all(1),
                      child: Card(
                        child: EarningListItem(
                            model: model,
                            isGoods: widget.isGoods,
                            usertimezone: usertimezone,
                            viewtype: widget.type),
                      ),
                    );
                  },
                  itemCount: donationsList.length,
                );
              }),
    );
  }
}

class EarningListItem extends StatelessWidget {
  final DonationModel model;
  final viewtype;
  final usertimezone;
  final bool isGoods;

  const EarningListItem(
      {Key key, this.model, this.usertimezone, this.viewtype, this.isGoods})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: viewtype == 'user'
            ? FirestoreManager.getTimeBankForId(timebankId: model.timebankId)
            : FirestoreManager.getUserForId(sevaUserId: model.donorSevaUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('');
          }
          return ListTile(
              leading: DonationImageItem(
                model: model,
                snapshot: snapshot,
                type: viewtype,
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  !isGoods
                      ? Text(
                          '\$' + '${model.cashDetails.pledgedAmount}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
                          '${model.goodsDetails.donatedGoods.length.toString()} Items',
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
                  requestName: model.requestTitle,
                  name: viewtype == 'user'
                      ? snapshot.data.name + " (Timebank)"
                      : snapshot.data.fullname == null
                          ? S.of(context).anonymous
                          : snapshot.data.fullname,
                  timestamp: model.timestamp,
                  usertimezone: usertimezone));
        });
  }
}

class DonationItem extends StatelessWidget {
  final name;
  final String requestName;
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
          requestName,
          textAlign: TextAlign.start,
        ),
        SizedBox(
          height: 2,
        ),
        Text(
          DateFormat(
                  'MMM dd, yyyy',
                  Locale(AppConfig.prefs.getString('language_code'))
                      .toLanguageTag())
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
  final String type;
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
