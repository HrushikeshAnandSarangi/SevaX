import 'package:flutter/material.dart';
import 'package:sevaexchange/views/notifications/notifications_view.dart';

import 'package:sevaexchange/views/tasks/my_tasks_list.dart';

class ActivityView extends StatefulWidget {
  final TabController controller;

  ActivityView(this.controller);

  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: widget.controller,
        children: [
          NotificationsView(),
          MyTasksList(),
        ],
      ),
    );
  }
}
