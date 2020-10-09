import 'package:flutter/material.dart';

import 'package:sevaexchange/views/tasks/my_tasks_list.dart';
import 'package:sevaexchange/views/tasks/completed_list.dart';

import '../core.dart';

class TasksPage extends StatefulWidget {
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(child: Text('PENDING')),
              Tab(child: Text('COMPLETED')),
            ],
          ),
          title: Text('My Tasks'),
          centerTitle: false,
        ),
        body: TabBarView(
          children: [
            MyTaskList(
              email: SevaCore.of(context).loggedInUser.email,
              sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
            ),
            CompletedList(),
          ],
        ),
      ),
    );
  }
}
