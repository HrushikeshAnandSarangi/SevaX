import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/data_managers/completed_tasks.dart';
import 'package:sevaexchange/utils/tasks_card_wrapper.dart';
import 'package:sevaexchange/views/core.dart';

// TODO: Fix the hacks

class CompletedList extends StatefulWidget {
  @override
  _CompletedListState createState() => _CompletedListState();
}

class _CompletedListState extends State<CompletedList> {
  List<TasksCardWrapper> completedTasks = [];

  Stream<Object>? requestStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    requestStream = CompletedTasks.getCompletedTasks(
      loggedinMemberEmail: SevaCore.of(context).loggedInUser.email,
      loggedInmemberId: SevaCore.of(context).loggedInUser.sevaUserID,
    );
    requestStream?.listen(
      (list) {
        if (!mounted) return;
        setState(() {
          completedTasks = CompletedTasks.classifyCompletedTasks(
                  completedSink: list as List<dynamic>, context: context)
              .cast<TasksCardWrapper>();
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
    if (completedTasks.length == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 58.0),
        child:
            Text(S.of(context).no_completed_task, textAlign: TextAlign.center),
      );
    }
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: completedTasks.length,
      itemBuilder: (context, index) {
        return completedTasks[index];

        // RequestModel model =
        //     requestList.elementAt(requestList.length - index - 1);

        // TransactionModel transmodel;

        // if (model.transactions.length > 0) {
        //   transmodel = model.transactions.firstWhere((transaction) {
        //     return transaction.to ==
        //         SevaCore.of(context).loggedInUser.sevaUserID;
        //   });
        // }

        // return Card(
        //   child: ListTile(
        //     title: Text(model.title),
        //     leading: FutureBuilder(
        //       future:
        //           FirestoreManager.getUserForId(sevaUserId: model.sevaUserId),
        //       builder: (context, snapshot) {
        //         if (snapshot.hasError) {
        //           return CircleAvatar();
        //         }
        //         if (snapshot.connectionState == ConnectionState.waiting) {
        //           return CircleAvatar();
        //         }
        //         UserModel user = snapshot.data;
        //         if (user == null) {
        //           return CircleAvatar(
        //             backgroundImage: NetworkImage(defaultUserImageURL),
        //           );
        //         }
        //         return CircleAvatar(
        //           backgroundImage:
        //               NetworkImage(user.photoURL ?? defaultUserImageURL),
        //         );
        //       },
        //     ),
        //     trailing: () {
        //      transmodel == null
        //           ? Text('0')
        //           : Column(
        //            mainAxisSize: MainAxisSize.min,
        //            crossAxisAlignment: CrossAxisAlignment.center,
        //            children: <Widget>[
        //              Text('${transmodel.credits}'),
        //              Text(S.of(context).seva_credits,
        //                  style: TextStyle(
        //                    fontSize: 9,
        //                    fontWeight: FontWeight.w600,
        //                    letterSpacing: -0.2,
        //                  )),
        //            ],
        //             );
        //     }(),
        //     subtitle: FutureBuilder(
        //       future:
        //           FirestoreManager.getUserForId(sevaUserId: model.sevaUserId),
        //       builder: (context, snapshot) {
        //         if (snapshot.hasError) {
        //           return Text('');
        //         }
        //         if (snapshot.connectionState == ConnectionState.waiting) {
        //           return Text('');
        //         }
        //         UserModel user = snapshot.data;
        //         if (user == null) {
        //           return Text('');
        //         }
        //         return Text('${user.fullname}');
        //       },
        //     ),
        //   ),
        // );
      },
    );
  }
}
