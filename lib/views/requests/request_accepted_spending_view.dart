import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

import '../core.dart';

class RequestAcceptedSpendingView extends StatefulWidget {
  final RequestModel requestModel;

  RequestAcceptedSpendingView({@required this.requestModel});

  @override
  _RequestAcceptedSpendingState createState() =>
      _RequestAcceptedSpendingState();
}

//enum RequestModelTag { Completed, NotAccepted, Pending }
//
//class RequestModelType {
//  RequestModel requestModel;
//  RequestModelTag type;
//
//  RequestModelType(RequestModel _requestModel, RequestModelTag _type) {
//    requestModel = _requestModel;
//    type = _type;
//  }
//}

class _RequestAcceptedSpendingState extends State<RequestAcceptedSpendingView> {
  List<Widget> _avtars = [];
  bool noTransactionAvailable = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: listItems,
    );
    ;
  }

  Widget get listItems {
    if (widget.requestModel.transactions == null ||
        widget.requestModel.transactions.length == 0) {
      return getTotalSpending("0");
    } else if (_avtars.length == 0) {
      getUserModel();
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView.builder(
          itemCount: _avtars.length,
          itemBuilder: (context, index) {
            return _avtars[index];
          });
    }
  }

  Widget completedRequestWidget(RequestModel model) {
    return Card(
      child: ListTile(
        title: Text(model.title),
        leading: FutureBuilder(
          future: FirestoreManager.getUserForId(sevaUserId: model.sevaUserId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return CircleAvatar();
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircleAvatar();
            }
            UserModel user = snapshot.data;
            if (user == null) {
              return CircleAvatar(
                backgroundImage: NetworkImage(defaultUserImageURL),
              );
            }
            return CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL),
            );
          },
        ),
        trailing: () {
          TransactionModel transmodel =
              model.transactions.firstWhere((transaction) {
            return transaction.to ==
                SevaCore.of(context).loggedInUser.sevaUserID;
          });
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('${transmodel.credits}'),
              Text('Yang bucks',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  )),
            ],
          );
        }(),
        subtitle: FutureBuilder(
          future: FirestoreManager.getUserForId(sevaUserId: model.sevaUserId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('');
            }
            UserModel user = snapshot.data;
            if (user == null) {
              return Text('');
            }
            return Text('${user.fullname}');
          },
        ),
      ),
    );
  }

  Future getUserModel() async {
    var i = 0;
    var k = 0;
    var totalCredits = 0.0;
    List<Widget> _localAvtars = [];
    while (i < widget.requestModel.transactions.length) {
      var transaction = widget.requestModel.transactions[i];
      if (transaction != null && transaction.to != null) {
        getUserForId(sevaUserId: transaction.to).then((_userModel) {
          totalCredits = totalCredits + transaction.credits;
          print("All transactions:$transaction");
          Widget item = getSpendingResultView(
            context,
            _userModel,
            transaction,
          );
          _localAvtars.add(item);
          if (k == widget.requestModel.transactions.length - 1) {
            _avtars.add(getTotalSpending("$totalCredits"));
            _avtars.addAll(_localAvtars);
            setState(() {});
          }
          k++;
        });
      } else {
        _localAvtars.add(Offstage());
        if (k == widget.requestModel.transactions.length - 1) {
          _avtars.add(getTotalSpending("$totalCredits"));
          _avtars.addAll(_localAvtars);
          setState(() {});
        }
        k++;
      }
      i++;
    }
  }

  Widget getTotalSpending(String credits) {
    var spendingWidget = Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Total spendings',
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Europa',
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.monetization_on,
                size: 40,
                color: Colors.yellow,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                credits,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  fontFamily: 'Europa',
                  color: Colors.black,
                ),
              ),
            ],
          )
        ],
      ),
    );
    return Column(
      children: <Widget>[
        spendingWidget,
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget getSpendingResultView(BuildContext parentContext, UserModel usermodel,
      TransactionModel transactionModel) {
    print("Context bcsvdygdsjbd:$parentContext");
    return Container(
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipOval(
                child: Container(
                  height: 45,
                  width: 45,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'lib/assets/images/profile.png',
                    image: defaultUserImageURL != null
                        ? usermodel.photoURL
                        : defaultUserImageURL,
                  ),
                ),
              ),
              Container(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      usermodel.fullname,
                      style: Theme.of(parentContext).textTheme.subhead,
                    ),
                    Text(
                      DateFormat('MMMM dd, yyyy @ h:mm a').format(
                        getDateTimeAccToUserTimezone(
                            dateTime: DateTime.fromMillisecondsSinceEpoch(
                                widget.requestModel.postTimestamp),
                            timezoneAbb: usermodel.timezone),
                      ),
                      style:
                          TextStyle(color: Colors.grey, fontFamily: 'Europa'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8, 5, 8),
                    child: Icon(
                      Icons.monetization_on,
                      size: 25,
                      color: Colors.yellow,
                    ),
                  ),
                  Text(
                    transactionModel.credits.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Europa',
                    ),
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
