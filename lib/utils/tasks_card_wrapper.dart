import 'package:flutter/material.dart';

class TasksCardWrapper extends StatelessWidget {
  final Widget taskCard;
  final int taskTimestamp;

  TasksCardWrapper({
    Key? key,
    required this.taskCard,
    required this.taskTimestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return taskCard;
  }
}
