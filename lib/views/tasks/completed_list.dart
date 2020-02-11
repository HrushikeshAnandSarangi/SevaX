import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class CompletedListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            'Completed Tasks',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: CompletedList());
  }
}

// TODO: Fix the hacks

class CompletedList extends StatefulWidget {
  @override
  _CompletedListState createState() => _CompletedListState();
}

class _CompletedListState extends State<CompletedList> {
  List<RequestModel> requestList = [];
  //List<UserModel> userList = [];

  Stream<List<RequestModel>> requestStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    requestStream = FirestoreManager.getCompletedRequestStream(
        userEmail: SevaCore.of(context).loggedInUser.email,
        userId: SevaCore.of(context).loggedInUser.sevaUserID);
    requestStream.listen(
      (list) {
        if (!mounted) return;
        setState(() {
          requestList = list;
          return requestList;
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
    if (requestList.length == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 58.0),
        child: Text('You have not completed any tasks',
            textAlign: TextAlign.center),
      );
    }
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: requestList.length,
      itemBuilder: (context, index) {
        RequestModel model = requestList.elementAt(index);

        return Card(
          child: ListTile(
            title: Text(model.title),
            leading: FutureBuilder(
              future:
                  FirestoreManager.getUserForId(sevaUserId: model.sevaUserId),
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
                  Text('Seva Coins',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      )),
                ],
              );
            }(),
            subtitle: FutureBuilder(
              future:
                  FirestoreManager.getUserForId(sevaUserId: model.sevaUserId),
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
      },
    );
  }
}
