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

// TODO: Fix the hacks

class UserDonationList extends StatefulWidget {
  final String type;
  final String timebankid;
  const UserDonationList({this.type, this.timebankid});
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
              userId: SevaCore.of(context).loggedInUser.sevaUserID)
          .listen(
        (result) {
          if (!mounted) return;
          donationsList = result;
          setState(() {});
        },
      );
    } else if (widget.type == 'timebank') {
      print('came here timebank id' + widget.timebankid.toString());
      FirestoreManager.getDonationList(timebankId: widget.timebankid).listen(
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
    if (donationsList.length == 0) {
      return Center(
        child: Text(S.of(context).no_transactions_yet),
      );
    }
    return FutureBuilder<Object>(
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
                      usertimezone: usertimezone,
                      viewtype: widget.type),
                ),
              );
            },
            itemCount: donationsList.length,
          );
        });
  }
}

class EarningListItem extends StatefulWidget {
  final model;
  final viewtype;
  final usertimezone;
  const EarningListItem({Key key, this.model, this.usertimezone, this.viewtype})
      : super(key: key);
  @override
  _EarningListItemState createState() => _EarningListItemState();
}

class _EarningListItemState extends State<EarningListItem> {
  @override
  Widget build(BuildContext context) {
    var type = (widget.model.type != 'REQUEST_CREATION_TIMEBANK_FILL_CREDITS' &&
            widget.model.type != 'RequestMode.TIMEBANK_REQUEST' &&
            widget.model.from != widget.model.timebankid)
        ? 'user'
        : 'timebank';
    return FutureBuilder(
        future: type == 'user'
            ? FirestoreManager.getUserForId(sevaUserId: widget.model.from)
            : FirestoreManager.getTimeBankForId(timebankId: widget.model.from),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('');
          }
          return ListTile(
              leading:
                  DonationImageItem(model: widget.model, snapshot: snapshot),
              trailing: () {
                String plus = widget.model.debitCreditSymbol(
                    SevaCore.of(context).loggedInUser.sevaUserID,
                    widget.model.timebankid,
                    widget.viewtype);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(plus + '${widget.model.credits}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        )),
                    Text(S.of(context).seva_credits,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        )),
                  ],
                );
              }(),
              subtitle: DonationItem(
                  name: type == 'user'
                      ? snapshot.data.fullname == null
                          ? S.of(context).anonymous
                          : widget.model.type == "USER_PAYLOAN_TOTIMEBANK"
                              ? snapshot.data.fullname + ' - Loan Repayment'
                              : snapshot.data.fullname
                      : widget.model.type == "ADMIN_DONATE_TOUSER"
                          ? snapshot.data.name + " (Timebank) Loan"
                          : snapshot.data.name + " (Timebank)",
                  timestamp: widget.model.timestamp,
                  usertimezone: widget.usertimezone));
        });
  }
}

class DonationItem extends StatelessWidget {
  final name;
  final timestamp;
  final usertimezone;
  DonationItem({this.name, this.timestamp, this.usertimezone});
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
        SizedBox(
          height: 2,
        ),
        Text(
          '${S.of(context).date} :  ' +
              DateFormat(
                      'MMMM dd, yyyy @ h:mm a',
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
    if (model.type != 'REQUEST_CREATION_TIMEBANK_FILL_CREDITS' &&
        model.type != 'RequestMode.TIMEBANK_REQUEST' &&
        model.from != model.timebankid) {
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

String getTimeFormattedString(int timeInMilliseconds) {
  DateFormat dateFormat = DateFormat('d MMM h:m a ',
      Locale(AppConfig.prefs.getString('language_code')).toLanguageTag());
  String dateOfTransaction = dateFormat.format(
    DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
  );
  return dateOfTransaction;
}
