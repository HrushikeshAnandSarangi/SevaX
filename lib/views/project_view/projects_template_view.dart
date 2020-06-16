import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Center(
              child: Text(
                  AppLocalizations.of(context).translate("shared", 'cancel'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Europa',
                  )),
            ),
          ),
        ),
        title: Text(
            AppLocalizations.of(context).translate("projects", 'new_project'),
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Europa',
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            onPressed: () => null,
            child: Text(
              AppLocalizations.of(context).translate("shared", 'next'),
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
            title: "Create new Project",
            value: 0,
            onChanged: (newValue) => setState(() => _groupValue = newValue),
          ),
          _optionRadioButton(
            title: "Create Project from Template",
            value: 1,
            onChanged: (newValue) => setState(() {
              _groupValue = newValue;
            }),
          ),
        ],
      ),
    );
  }

  Widget _optionRadioButton({String title, int value, Function onChanged}) {
    Color primaryColor = FlavorConfig.values.theme.primaryColor;
    return RadioListTile(
      value: value,
      groupValue: _groupValue,
      activeColor: primaryColor,
      onChanged: onChanged,
      title: Text(
        title,
        style: TextStyle(color: primaryColor),
      ),
    );
  }
}
