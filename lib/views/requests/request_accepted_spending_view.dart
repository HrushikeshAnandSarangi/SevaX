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

enum RequestModelTag { Completed, NotAccepted, Pending }

class RequestModelType {
  RequestModel requestModel;
  RequestModelTag type;

  RequestModelType(RequestModel _requestModel, RequestModelTag _type) {
    requestModel = _requestModel;
    type = _type;
  }
}

class _RequestAcceptedSpendingState extends State<RequestAcceptedSpendingView> {
  List<Widget> _avtars = [];

  List<RequestModel> completedRequestList = [];
  Stream<List<RequestModel>> completedRequestStream;
  List<RequestModel> notAcceptedRequestList = [];
  Stream<List<RequestModel>> notAcceptedRequestStream;

  List<RequestModelType> finalCustomList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    completedRequestStream = FirestoreManager.getCompletedRequestStream(
        userEmail: SevaCore.of(context).loggedInUser.email,
        userId: SevaCore.of(context).loggedInUser.sevaUserID);
    completedRequestStream.listen(
      (list) {
        if (!mounted) return;
        setState(() {
          completedRequestList = list;
          return completedRequestList;
        });
      },
    );

    notAcceptedRequestStream = FirestoreManager.getNotAcceptedRequestStream(
        userEmail: SevaCore.of(context).loggedInUser.email,
        userId: SevaCore.of(context).loggedInUser.sevaUserID);
    notAcceptedRequestStream.listen(
      (list) {
        if (!mounted) return;
        setState(() {
          notAcceptedRequestList = list;
          return notAcceptedRequestList;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    finalCustomList = [];
    if (completedRequestList.length > 0) {
      for (var i = 0; i < completedRequestList.length; i++) {
        finalCustomList.add(RequestModelType(
            completedRequestList[i], RequestModelTag.Completed));
      }
    }
    if (notAcceptedRequestList.length > 0) {
      for (var i = 0; i < notAcceptedRequestList.length; i++) {
        finalCustomList.add(RequestModelType(
            notAcceptedRequestList[i], RequestModelTag.NotAccepted));
      }
    }
    return listItems;
  }

  Widget get listItems {
    Widget body;
    if (finalCustomList.length == 0) {
      body = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      body = ListView.builder(
          itemCount: finalCustomList.length,
          itemBuilder: (context, index) {
            if (finalCustomList[index].type == RequestModelTag.Completed) {
              return completedRequestWidget(
                  finalCustomList[index].requestModel);
            } else {
//              return Offstage();
              return completedRequestWidget(
                  finalCustomList[index].requestModel);
            }
          });
    }
    return Scaffold(
      body: body,
    );
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

//  Widget get listItems {
//    Widget localWidget;
//    if (_avtars.length == 0) {
//      getUserModel();
//      localWidget = Center(
//        child: CircularProgressIndicator(),
//      );
//    } else {
//      localWidget = ListView.builder(
//          itemCount: _avtars.length,
//          itemBuilder: (context, index) {
//            return _avtars[index];
//          });
//    }
//    return Scaffold(
//      body: localWidget,
//    );
//  }

  Future getUserModel() async {
    var i = 0;
    var k = 0;
    List<Widget> _localAvtars = [];
    while (i < widget.requestModel.transactions.length) {
      var transaction = widget.requestModel.transactions[i];
      if (transaction != null) {
        getUserForId(sevaUserId: transaction.to).then((_userModel) {
          print("Index $k:${_userModel.fullname}");
          var item = getSpendingResultView(
            context,
            _userModel,
            transaction,
          );
          _localAvtars.add(item);
          k++;
          print("Index $k:${_userModel.fullname}");
          if (k == widget.requestModel.transactions.length) {
            _avtars.add(getTotalSpending());
            _avtars.addAll(_localAvtars);
            setState(() {});
          }
        });
      } else {
        k++;
        if (k == widget.requestModel.transactions.length) {
          setState(() {
            if (_avtars.length == 0) {
              _avtars.add(getTotalSpending());
            }
          });
        }
      }
      i++;
    }
  }

  Widget getTotalSpending() {
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
                '2,591',
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
