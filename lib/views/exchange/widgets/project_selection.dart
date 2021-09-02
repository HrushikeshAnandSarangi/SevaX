import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/views/exchange/widgets/request_enums.dart';
import 'package:sevaexchange/widgets/multi_select/flutter_multiselect.dart';

// ignore: must_be_immutable
class ProjectSelection extends StatefulWidget {
  final RequestFormType createType;
  final bool admin;
  final List<ProjectModel> projectModelList;
  final ProjectModel selectedProject;
  RequestModel requestModel;
  TimebankModel timebankModel;
  UserModel userModel;
  bool createEvent;
  VoidCallback setcreateEventState;
  Function(String projectId) updateProjectIdCallback;

  ProjectSelection({
    Key key,
    this.requestModel,
    this.admin,
    this.projectModelList,
    this.selectedProject,
    this.timebankModel,
    this.userModel,
    this.createEvent,
    this.setcreateEventState,
    this.updateProjectIdCallback,
    this.createType,
  }) : super(key: key);

  @override
  ProjectSelectionState createState() => ProjectSelectionState();
}

class ProjectSelectionState extends State<ProjectSelection> {
  @override
  Widget build(BuildContext context) {
    if (widget.projectModelList == null) {
      return Container();
    }
    List<dynamic> list = [
      {"name": S.of(context).unassigned, "code": "None"}
    ];
    for (var i = 0; i < widget.projectModelList.length; i++) {
      list.add({
        "name": widget.projectModelList[i].name,
        "code": widget.projectModelList[i].id,
        "timebankproject": widget.projectModelList[i].mode == ProjectMode.TIMEBANK_PROJECT,
      });
    }
    return MultiSelect(
      timebankModel: widget.timebankModel,
      userModel: widget.userModel,
      autovalidate: true,
      initialValue: [widget.selectedProject != null ? widget.selectedProject.id : 'None'],
      titleText: Row(
        children: [
          Text(S.of(context).assign_to_project),
          SizedBox(
            width: 10,
          ),
          Icon(
            Icons.arrow_drop_down_circle,
            color: Theme.of(context).primaryColor,
            size: 30.0,
          ),
          SizedBox(width: 4),
          (widget.createType == RequestFormType.CREATE &&
                  widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST)
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.createEvent = !widget.createEvent;
                      widget.requestModel.projectId = '';
                      log('projectId1:  ' + widget.requestModel.projectId.toString());
                      log('createEvent1:  ' + widget.createEvent.toString());
                    });
                    widget.setcreateEventState();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1.8),
                    child: Icon(Icons.add_circle_outline_rounded,
                        size: 28, color: widget.createEvent ? Colors.green : Colors.grey),
                  ),
                )
              : Container()
        ],
      ),
      maxLength: 1,
      // optional
      hintText: S.of(context).tap_to_select,
      validator: (dynamic value) {
        if (value == null) {
          return S.of(context).assign_to_one_project;
        }
        return null;
      },
      errorText: S.of(context).assign_to_one_project,
      dataSource: list,
      admin: widget.admin,
      textField: 'name',
      valueField: 'code',
      filterable: true,
      required: true,
      titleTextColor: Colors.black,
      change: (value) {
        if (value != null && value[0] != 'None') {
          widget.createType == RequestFormType.CREATE
              ? widget.requestModel.projectId = value[0]
              : widget.updateProjectIdCallback(value[0]);
        } else {
          widget.createType == RequestFormType.CREATE
              ? widget.requestModel.projectId = ''
              : widget.updateProjectIdCallback('None');
        }
      },
      selectIcon: Icons.arrow_drop_down_circle,
      saveButtonColor: Theme.of(context).primaryColor,
      checkBoxColor: Theme.of(context).primaryColorDark,
      cancelButtonColor: Theme.of(context).primaryColorLight,
    );
  }
}
