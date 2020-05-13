import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:timeago/timeago.dart' as timeago;

import '../models/models.dart';

class TransactionHistoryView extends StatelessWidget {
  final UserModel userModel;

  TransactionHistoryView({@required this.userModel});

  // TODO: Fix the hacks

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Earnings'),
      ),
      body: StreamBuilder<List<RequestModel>>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return listTileShimmer;
          }
          List<RequestModel> requestModelList = snapshot.data;
          return ListView.builder(
            itemBuilder: (context, index) {
              RequestModel requestModel = requestModelList[index];
//              TransactionModel transactionModel = requestModel.transaction;

//              String participantEmailId = transactionModel.from ==
//                      SevaCore.of(context).loggedInUser.email
//                  ? transactionModel.to
//                  : transactionModel.from;

              String participantEmailId = 'TODO';

              return Card(
                child: ListTile(
                  title: Text(requestModel.title ?? 'Failed'),
                  subtitle: Text(
                    'TODO' ??
                        timeago.format(
                          DateTime.fromMillisecondsSinceEpoch(1
//                        transactionModel.timestamp,
                              ),
                        ),
                  ),
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: StreamBuilder<UserModel>(
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data.photoURL ?? defaultUserImageURL),
                          radius: 32.0,
                        );
                      },
                      stream: FirestoreManager.getUserForEmailStream(
                          participantEmailId),
                    ),
                  ),
                  trailing: () {
                    String pointsText = '';
//                    if (transactionModel.from ==
//                        SevaCore.of(context).loggedInUser.email) {
//                      pointsText += '- ';
//                    } else {
//                      pointsText += '+ ';
//                    }
//                    pointsText += transactionModel.credits.toString();
                    pointsText = 'TODO';
                    return Text(
                      pointsText,
                      style: TextStyle(
//                        color: transactionModel.from ==
//                                SevaCore.of(context).loggedInUser.email
//                            ? Colors.red
//                            : Colors.green,
                          ),
                    );
                  }(),
                ),
              );
            },
            itemCount: requestModelList.length,
          );
        },
        stream: FirestoreManager.getTransactionsForUser(
            userId: userModel.sevaUserID),
      ),
    );
  }

  Widget get listTileShimmer {
    return Center(child: CircularProgressIndicator());
  }
}
