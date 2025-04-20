import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class ReviewEarningsPage extends StatelessWidget {
  final String? type;
  final String? timebankid;
  const ReviewEarningsPage({this.type, this.timebankid});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).review_earnings,
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: ReviewEarning(type: type!, timebankid: this.timebankid!));
  }
}

// TODO: Fix the hacks

class ReviewEarning extends StatefulWidget {
  final String? type;
  final String? timebankid;
  const ReviewEarning({this.type, this.timebankid});
  @override
  _ReviewEarningState createState() => _ReviewEarningState();
}

class _ReviewEarningState extends State<ReviewEarning> {
  List<TransactionModel> requestList = [];
  //List<UserModel> userList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.type == 'user') {
      FirestoreManager.getUsersCreditsDebitsStream(
              userEmail: SevaCore.of(context).loggedInUser.email!,
              userId: SevaCore.of(context).loggedInUser.sevaUserID!)
          .listen(
        (result) {
          if (!mounted) return;
          requestList = result;
          setState(() {});
        },
      );
    } else if (widget.type == 'timebank') {
      FirestoreManager.getTimebankCreditsDebitsStream(
              timebankid: widget.timebankid!,
              userId: SevaCore.of(context).loggedInUser.sevaUserID!)
          .listen(
        (result) {
          if (!mounted) return;
          requestList = result;
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
    if (requestList.length == 0) {
      return Center(
        child: Text(S.of(context).no_transactions_yet),
      );
    }
    return FutureBuilder<Object>(
      future: FirestoreManager.getUserForId(
          sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            S.of(context).general_stream_error,
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        UserModel userModel = snapshot.data as UserModel;
        String usertimezone = userModel.timezone!;
        return ListView.builder(
          itemBuilder: (context, index) {
            TransactionModel model = requestList.elementAt(index);

            return EarningListItem(
              model: model,
              usertimezone: usertimezone,
              viewtype: widget.type,
            );
          },
          itemCount: requestList.length,
        );
      },
    );
  }
}

class EarningListItem extends StatefulWidget {
  final TransactionModel? model;
  final viewtype;
  final usertimezone;
  const EarningListItem(
      {Key? key, this.model, this.usertimezone, this.viewtype})
      : super(key: key);
  @override
  _EarningListItemState createState() => _EarningListItemState();
}

class _EarningListItemState extends State<EarningListItem> {
  @override
  Widget build(BuildContext context) {
    if (widget.model!.from!.contains('-')) {
      return FutureBuilder<TimebankModel?>(
        future:
            FirestoreManager.getTimeBankForId(timebankId: widget.model!.from!),
        builder: (context, AsyncSnapshot<TimebankModel?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            debugPrint(widget.model!.from!);
            return Container();
          }
          return getListTile(
            snapshot.data!.name,
            snapshot.data!.photoUrl,
          );
        },
      );
    } else {
      return FutureBuilder(
        future: FirestoreManager.getUserForId(sevaUserId: widget.model!.from!),
        builder: (context, AsyncSnapshot<UserModel> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            return Container();
          }
          return getListTile(
            snapshot.data!.fullname!,
            snapshot.data!.photoURL ?? defaultUserImageURL,
          );
        },
      );
    }
  }

  Widget getListTile(String name, String image) {
    return Card(
      child: ListTile(
        leading: EarningImageItem(
          image: image,
        ),
        trailing: () {
          String plus = widget.model!.from == widget.model!.to
              ? '+'
              : widget.model!.debitCreditSymbol(
                  SevaCore.of(context).loggedInUser.sevaUserID,
                  widget.model!.timebankid,
                  widget.viewtype,
                );
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(plus + '${widget.model!.credits}',
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
        subtitle: EarningItem(
          name: name ?? '',
          timestamp: widget.model!.timestamp,
          usertimezone: widget.usertimezone,
        ),
      ),
    );
  }
}

class EarningItem extends StatelessWidget {
  final name;
  final timestamp;
  final usertimezone;
  EarningItem({this.name, this.timestamp, this.usertimezone});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 2,
        ),
        Text(
          '${name ?? ''}',
          textAlign: TextAlign.start,
        ),
        SizedBox(
          height: 2,
        ),
        Text(
          '${S.of(context).date} :  ' +
              DateFormat('MMMM dd, yyyy @ h:mm a',
                      Locale(getLangTag()).toLanguageTag())
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

class EarningImageItem extends StatelessWidget {
  final String? image;
  EarningImageItem({this.image});
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: NetworkImage(image ?? defaultUserImageURL),
    );
  }
}

String getTimeFormattedString(int timeInMilliseconds) {
  DateFormat dateFormat =
      DateFormat('d MMM h:m a ', Locale(getLangTag()).toLanguageTag());
  String dateOfTransaction = dateFormat.format(
    DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
  );
  return dateOfTransaction;
}
