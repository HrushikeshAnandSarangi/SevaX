import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/pending_tasks.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class NotAcceptedTaskList extends StatefulWidget {
  NotAcceptedTaskListState createState() => NotAcceptedTaskListState();
}

class NotAcceptedTaskListState extends State<NotAcceptedTaskList> {
  List<Widget> peningItems = [];
  //List<UserModel> userList = [];

  Stream<dynamic> requestStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    requestStream = PendingTasks.getPendingTasks(
      loggedInmemberId: SevaCore.of(context).loggedInUser.sevaUserID,
      loggedinMemberEmail: SevaCore.of(context).loggedInUser.email,
    );

    requestStream.listen(
      (list) {
        if (!mounted) return;
        peningItems = PendingTasks.classifyPendingTasks(
          pendingSink: list,
          context: context,
        );
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (peningItems.length == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 58.0),
        child: Text(
          S.of(context).there_are_currently_none,
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      itemCount: peningItems.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return peningItems[index];

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
        //         return CircleAvatar(
        //           backgroundImage:
        //               NetworkImage(user.photoURL ?? defaultUserImageURL),
        //         );
        //       },
        //     ),
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
        //         return Text('${user.fullname}');
        //       },
        //     ),
        //   ),
        // );
      },
    );
  }
}
