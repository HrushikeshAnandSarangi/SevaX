import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/project_template_model.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/project_view/create_edit_project.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class ProjectTemplateView extends StatefulWidget {
  final bool isCreateProject;
  final String timebankId;
  final String projectId;

  ProjectTemplateView({this.isCreateProject, this.timebankId, this.projectId});

  @override
  _ProjectTemplateViewState createState() => _ProjectTemplateViewState();
}

class _ProjectTemplateViewState extends State<ProjectTemplateView> {
  int _groupValue = 0;
  TextEditingController searchTextController = TextEditingController();
  final _textUpdates = StreamController<String>();
  Color primaryColor = FlavorConfig.values.theme.primaryColor;
  int value;
  ProjectTemplateModel selectedProjectTemplate;
  bool isProjectTemplateSelected = false;
  final _debouncer = Debouncer(milliseconds: 400);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///getTemplate();
    searchTextController.addListener(() {
      _debouncer.run(() {
        if (searchTextController.text.isEmpty) {
          setState(() {});
        } else {
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Center(
              child: Text(S.of(context).cancel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Europa',
                  )),
            ),
          ),
        ),
        title: Text(
          S.of(context).new_project,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Europa',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          CustomTextButton(
            onPressed: () {
              if (isProjectTemplateSelected &&
                  selectedProjectTemplate == null) {
                _showTemplateAlertMessage(context);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEditProject(
                      timebankId: widget.timebankId,
                      isCreateProject: true,
                      projectId: '',
                      projectTemplateModel: isProjectTemplateSelected
                          ? selectedProjectTemplate
                          : null,
                    ),
                  ),
                );
              }
            },
            child: Text(
              S.of(context).next,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Europa',
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _optionRadioButton(
            title: S.of(context).create_new_project,
            value: 0,
            onChanged: (newValue) => setState(() {
              _groupValue = newValue;
              isProjectTemplateSelected = false;
            }),
          ),
          _optionRadioButton(
            title: S.of(context).create_project_from_template,
            value: 1,
            onChanged: (newValue) => setState(() {
              _groupValue = newValue;
              isProjectTemplateSelected = true;
            }),
          ),
          TransactionsMatrixCheck(
            comingFrom: ComingFrom.Projects,
            upgradeDetails: AppConfig.upgradePlanBannerModel.project_templates,
            transaction_matrix_type: "project_templates",
            child: searchFieldWidget(),
          ),
          buildTemplateWidget(),
        ],
      ),
    );
  }

  Widget buildTemplateWidget() {
    if (searchTextController.text.trim().isEmpty) {
      return Container();
    } else if (searchTextController.text.trim().length < 3) {
      return getEmptyWidget(
          S.of(context).validation_error_search_min_characters);
    } else {
      return StreamBuilder<List<ProjectTemplateModel>>(
        stream: SearchManager.searchProjectTemplate(
            queryString: searchTextController.text),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Text(snapshot.error.toString());
          }
          if (snapshot.data == null) {
            return getEmptyWidget(S.of(context).no_templates_found);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                height: 25,
                width: 25,
                child: LoadingIndicator(),
              ),
            );
          }

          List<ProjectTemplateModel> projectTemplateList = snapshot.data;

          if (projectTemplateList.length == 0) {
            return getEmptyWidget(S.of(context).no_templates_found);
          }
          return Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: projectTemplateList.length,
              itemBuilder: (context, index) {
                ProjectTemplateModel projectTemplateModel =
                    projectTemplateList[index];
                return RadioListTile(
                  value: index,
                  groupValue: value,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (ind) => setState(() {
                    value = ind;
                    selectedProjectTemplate = projectTemplateList[ind];
                  }),
                  title: Text(projectTemplateModel.templateName),
                );
              },
            ),
          );
        },
      );
    }
  }

  Widget getEmptyWidget(String notFoundValue) {
    return Center(
      child: Text(
        notFoundValue,
        overflow: TextOverflow.ellipsis,
        style: sectionHeadingStyle,
      ),
    );
  }

  TextStyle get sectionHeadingStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12.5,
      color: Colors.black,
    );
  }

  Widget searchFieldWidget() {
    if (_groupValue == 0) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: TextFormField(
        controller: searchTextController,
        decoration: InputDecoration(
          isDense: true,

          // labelText: "Enter Email",
          hintText: S.of(context).search_template_hint,
          fillColor: Colors.white,

          alignLabelWithHint: true,
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: Colors.grey,
          ),
          contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 10.0),

          suffixIcon: Offstage(
            offstage: searchTextController.text.length == 0,
            child: IconButton(
              splashColor: Colors.transparent,
              icon: Icon(
                Icons.clear,
                color: Colors.black54,
              ),
              onPressed: () {
                //searchTextController.clear();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  searchTextController.clear();
                  if (selectedProjectTemplate != null) {
                    selectedProjectTemplate = null;
                  }
                });
              },
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
        ),
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(fontSize: 16.0),
        inputFormatters: [
          LengthLimitingTextInputFormatter(50),
        ],
      ),
    );
  }

  Widget _optionRadioButton({String title, int value, Function onChanged}) {
    return RadioListTile(
      value: value,
      groupValue: _groupValue,
      activeColor: Theme.of(context).primaryColor,
      onChanged: onChanged,
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }

  void _showTemplateAlertMessage(BuildContext mContext) {
    // flutter defined function
    showDialog(
      context: mContext,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(S.of(context).template_alert),
          content: Text(S.of(context).select_template),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            CustomTextButton(
              shape: StadiumBorder(),
              color: Theme.of(context).accentColor,
              textColor: Colors.white,
              child: Text(S.of(context).close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
