import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class ReviewEarningsPage extends StatelessWidget {
  final String type;
  final String timebankid;
  const ReviewEarningsPage({this.type, this.timebankid});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Review Earnings',
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: ReviewEarning(type: type, timebankid: this.timebankid));
  }
}

// TODO: Fix the hacks

class ReviewEarning extends StatefulWidget {
  final String type;
  final String timebankid;
  const ReviewEarning({this.type, this.timebankid});
  @override
  _ReviewEarningState createState() => _ReviewEarningState();
}

String getTimeFormattedString(int timeInMilliseconds) {
  DateFormat dateFormat = DateFormat('d MMM h:m a ');
  String dateOfTransaction = dateFormat.format(
    DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
  );
  return dateOfTransaction;
}

class _ReviewEarningState extends State<ReviewEarning> {
  List<TransactionModel> requestList = [];
  //List<UserModel> userList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.type == 'user') {
      FirestoreManager.getUsersCreditsDebitsStream(
              userEmail: SevaCore.of(context).loggedInUser.email,
              userId: SevaCore.of(context).loggedInUser.sevaUserID)
          .listen(
        (result) {
          if (!mounted) return;
          requestList = result;
          setState(() {});
        },
      );
    } else if (widget.type == 'timebank') {
      print('came here timebank id' + widget.timebankid.toString());
      FirestoreManager.getTimebankCreditsDebitsStream(
              timebankid: widget.timebankid,
              userId: SevaCore.of(context).loggedInUser.sevaUserID)
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
        child: Text('You do not have any transaction yet'),
      );
    }
    return FutureBuilder<Object>(
        future: FirestoreManager.getUserForId(
            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          UserModel userModel = snapshot.data;
          String usertimezone = userModel.timezone;
          return ListView.builder(
            itemBuilder: (context, index) {
              TransactionModel model = requestList.elementAt(index);

              return Container(
                margin: EdgeInsets.all(1),
                child: Card(
                  child: ListTile(
//                    title: Text(model.title),
                    // leading: () {
                    //   if (index + 1 > userList.length) {
                    //     return CircleAvatar(
                    //       backgroundColor: Colors.grey,
                    //     );
                    //   }
                    //   UserModel user = userList[index];
                    //   return CircleAvatar(
                    //     backgroundImage: NetworkImage(user.photoURL),
                    //   );
                    // }(),
                    leading: FutureBuilder(
                      future: model.type == 'user'
                          ? FirestoreManager.getUserForId(
                              sevaUserId: model.from)
                          : FirestoreManager.getTimeBankForId(
                              timebankId: model.from),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return CircleAvatar();
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircleAvatar();
                        }
                        if (model.type == 'user') {
                          UserModel user = snapshot.data;
                          return CircleAvatar(
                            backgroundImage: NetworkImage(user.photoURL),
                          );
                        } else {
                          TimebankModel timebanktemp = snapshot.data;
                          return CircleAvatar(
                            backgroundImage:
                                NetworkImage(timebanktemp.photoUrl),
                          );
                        }
                      },
                    ),
                    trailing: () {
                      //   List<TransactionModel> transactions =
                      //         model.transactions.map((t) => t).toList();
                      //  num transaction = transactions.
//                      TransactionModel transmodel =
//                          model.transactions.firstWhere((transaction) {
//                        return transaction.to ==
//                            SevaCore.of(context).loggedInUser.sevaUserID;
//                      });
                      String plus = model.type == 'RequestMode.PERSONAL_REQUEST'
                          ? model.from ==
                                  SevaCore.of(context).loggedInUser.sevaUserID
                              ? "-"
                              : "+"
                          : model.type == 'RequestMode.TIMEBANK_REQUEST'
                              ? model.from == model.timebankid ? "-" : "+"
                              : model.from ==
                                      SevaCore.of(context)
                                          .loggedInUser
                                          .sevaUserID
                                  ? "-"
                                  : "+";
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(plus + '${model.credits}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              )),
                          Text('Seva Credits',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              )),
                        ],
                      );
                    }(),
                    subtitle: FutureBuilder(
                      future:
                          FirestoreManager.getUserForId(sevaUserId: model.from),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('');
                        }
//                        TransactionModel transmodel =
//                            model.transactions.firstWhere((transaction) {
//                          return transaction.to ==
//                              SevaCore.of(context).loggedInUser.sevaUserID;
//                        });
                        UserModel user = snapshot.data;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              '${user.fullname}',
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              'Date:  ' +
                                  DateFormat('MMMM dd, yyyy @ h:mm a').format(
                                    getDateTimeAccToUserTimezone(
                                        dateTime:
                                            DateTime.fromMillisecondsSinceEpoch(
                                                model.timestamp),
                                        timezoneAbb: usertimezone),
                                  ),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(
                              height: 2,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            itemCount: requestList.length,
          );
        });
  }
}
