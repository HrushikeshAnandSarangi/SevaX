import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/views/exchange/widgets/request_enums.dart';
import 'package:sevaexchange/widgets/multi_select/flutter_multiselect.dart';

class ProjectSelection extends StatefulWidget {
  final RequestFormType? createType;
  final bool? admin;
  final List<ProjectModel>? projectModelList;
  final ProjectModel? selectedProject;
  final RequestModel? requestModel;
  final TimebankModel? timebankModel;
  final UserModel? userModel;
  final bool? createEvent;
  final VoidCallback? setcreateEventState;
  final Function(String projectId)? updateProjectIdCallback;

  const ProjectSelection({
    Key? key,
    this.createType,
    this.admin,
    this.projectModelList,
    this.selectedProject,
    this.requestModel,
    this.timebankModel,
    this.userModel,
    this.createEvent,
    this.setcreateEventState,
    this.updateProjectIdCallback,
  }) : super(key: key);

  @override
  State<ProjectSelection> createState() => _ProjectSelectionState();
}

class _ProjectSelectionState extends State<ProjectSelection> {
  @override
  Widget build(BuildContext context) {
    if (widget.projectModelList == null) {
      return const SizedBox.shrink();
    }

    final List<Map<String, dynamic>> list = [
      {"name": S.of(context).unassigned, "code": "None"}
    ];

    for (final project in widget.projectModelList!) {
      list.add({
        "name": project.name,
        "code": project.id,
        "timebankproject": project.mode == ProjectMode.timebankProject,
      });
    }

    return MultiSelect(
      timebankModel: widget.timebankModel ?? TimebankModel({}),
      userModel: widget.userModel ?? UserModel(),
      autovalidate: true,
      initialValue: [widget.selectedProject?.id ?? 'None'],
      titleText: Row(
        children: [
          Text(S.of(context).assign_to_project),
          const SizedBox(width: 10),
          Icon(
            Icons.arrow_drop_down_circle,
            color: Theme.of(context).primaryColor,
            size: 30.0,
          ),
          const SizedBox(width: 4),
          if (widget.createType == RequestFormType.CREATE &&
              widget.requestModel?.requestType ==
                  RequestType.ONE_TO_MANY_REQUEST)
            GestureDetector(
              onTap: () {
                setState(() {
                  final newState = !(widget.createEvent ?? false);
                  if (widget.requestModel != null) {
                    widget.requestModel!.projectId = '';
                  }
                  widget.setcreateEventState?.call();
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 1.8),
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 28,
                  color: (widget.createEvent ?? false)
                      ? Colors.green
                      : Colors.grey,
                ),
              ),
            ),
        ],
      ),
      maxLength: 1,
      hintText: S.of(context).tap_to_select,
      validator: (dynamic value) {
        if (value == null) {
          return S.of(context).assign_to_one_project;
        }
        return null;
      },
      errorText: S.of(context).assign_to_one_project,
      dataSource: list,
      admin: widget.admin ?? false,
      textField: 'name',
      valueField: 'code',
      filterable: true,
      required: true,
      titleTextColor: Colors.black,
      change: (value) {
        final selectedValue = value?[0];
        if (selectedValue != null && selectedValue != 'None') {
          if (widget.createType == RequestFormType.CREATE) {
            widget.requestModel?.projectId = selectedValue;
          } else {
            widget.updateProjectIdCallback?.call(selectedValue);
          }
        } else {
          if (widget.createType == RequestFormType.CREATE) {
            widget.requestModel?.projectId = '';
          } else {
            widget.updateProjectIdCallback?.call('None');
          }
        }
      },
      selectIcon: Icons.arrow_drop_down_circle,
      saveButtonColor: Theme.of(context).primaryColor,
      checkBoxColor: Theme.of(context).primaryColorDark,
      cancelButtonColor: Theme.of(context).primaryColorLight,
    );
  }
}
