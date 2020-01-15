import 'package:flutter/material.dart';

import 'package:sevaexchange/models/models.dart';
//import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class NotAcceptedTaskList extends StatefulWidget {
  NotAcceptedTaskListState createState() => NotAcceptedTaskListState();
}

class NotAcceptedTaskListState extends State<NotAcceptedTaskList> {
  List<RequestModel> requestList = [];
  //List<UserModel> userList = [];

  Stream<List<RequestModel>> requestStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    requestStream = FirestoreManager.getNotAcceptedRequestStream(
        userEmail: SevaCore.of(context).loggedInUser.email,
        userId: SevaCore.of(context).loggedInUser.sevaUserID);
    requestStream.listen(
      (list) {
        if (!mounted) return;
        setState(() {
          requestList = list;
          // RequestModel modelflag =

          //  requestList.sort((b, a) {
          //    return a.transactions.timestamp.compareTo(b.transactions.timestamp);
          //  }
          //  );
          return requestList;
        });
        // userList = [];
        // requestList.forEach(
        //   (request) async {
        //     UserModel user = await FirestoreManager.getUserForId(
        //       sevaUserId: request.sevaUserId,
        //     );
        //     if (!mounted) return;
        //     setState(() => userList.add(user));
        //   },
        // );
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
        padding: const EdgeInsets.only(top:58.0),
        child: Text('There are currenlty none',
            textAlign: TextAlign.center),
      );
    }
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        RequestModel model = requestList.elementAt(index);

        return Card(
          child: ListTile(
            title: Text(model.title),
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
                return CircleAvatar(
                  backgroundImage: NetworkImage(user.photoURL),
                );
              },
            ),

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
                return Text('${user.fullname}');
              },
            ),
          ),
        );
      },
      itemCount: requestList.length,
    );
  }
}
