import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';

class RequestAcceptedSpendingView extends StatefulWidget {
  final RequestModel requestModel;

  RequestAcceptedSpendingView({@required this.requestModel});

  @override
  _RequestAcceptedSpendingState createState() =>
      _RequestAcceptedSpendingState();
}

class _RequestAcceptedSpendingState extends State<RequestAcceptedSpendingView> {
  List<Widget> _avtars = [];

  @override
  Widget build(BuildContext context) {
    return listItems;
  }

  Widget get listItems {
    Widget localWidget;
    if (_avtars.length == 0) {
      getUserModel();
      localWidget = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      localWidget = ListView.builder(
          itemCount: _avtars.length,
          itemBuilder: (context, index) {
            return _avtars[index];
          });
    }
    return Scaffold(
      body: localWidget,
    );
  }

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
