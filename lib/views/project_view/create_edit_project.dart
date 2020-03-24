import 'package:flutter/material.dart';
import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';

class CreateEditProject extends StatefulWidget {
  final bool isCreateProject;

  CreateEditProject({this.isCreateProject});

  @override
  _CreateEditProjectState createState() => _CreateEditProjectState();
}

class _CreateEditProjectState extends State<CreateEditProject> {
  final _formKey = GlobalKey<FormState>();
  String communityImageError = '';
  TextEditingController searchTextController = new TextEditingController();
  String errTxt;
  ProjectModel projectModel = ProjectModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          'Create Project',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: createProjectForm,
      ),
    );
  }

  Widget get createProjectForm {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  children: <Widget>[
                    widget.isCreateProject
                        ? TimebankAvatar()
                        : TimebankAvatar(
                            photoUrl: defaultCameraImageURL,
                          ),
                    Text(''),
                    Text(
                      'Project Logo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      communityImageError,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            headingText('Project Name'),
            TextFormField(
              controller: searchTextController,
              onChanged: (value) {
                //  enteredName = value;
                print("name ------ $value");
                //communityModel.name = value;
                //timebankModel.name = value;
              },
              decoration: InputDecoration(
                errorText: errTxt,
                hintText: "Ex: Pets-in-town, Citizen collab",
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 1,
              //initialValue: snapshot.data.community.name ?? '',

              onSaved: (value) {
                //  enteredName = value;
              },
              // onSaved: (value) => enteredName = value,
              validator: (value) {
//                      if (value.isEmpty) {
//                        return 'Timebank name cannot be empty';
//                      } else if (communityFound) {
//                        return 'Timebank name already exist';
//                      } else {
//                        enteredName = value;
//                        snapshot.data.community.updateValueByKey('name', value);
//                        createEditCommunityBloc.onChange(snapshot.data);
//                      }

                return null;
              },
            ),
            headingText('Mission Statement'),
            TextFormField(
              decoration: InputDecoration(
                hintText:
                    'Ex: A bit more about your project which will help to associate with',
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              //  initialValue: timebankModel.missionStatement,
              onChanged: (value) {
//                      timebankModel.missionStatement = value;
//                      communityModel.about = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Tell us more about your project.';
                }
//                      snapshot.data.community.updateValueByKey('about', value);
//
//                      snapshot.data.timebank
//                          .updateValueByKey('missionStatement', value);
//                      createEditCommunityBloc.onChange(snapshot.data);
                return null;
              },
            ),
            Padding(
              padding: EdgeInsets.all(8),
            ),
            headingText('Email'),
            TextFormField(
              style: textStyle,
              cursorColor: Colors.black54,
              validator: _validateEmailId,
              onSaved: null,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                labelText: 'example@example.com',
                labelStyle: textStyle,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
            ),
            headingText('Phone Number'),
            TextFormField(
              style: textStyle,
              cursorColor: Colors.black54,
              validator: _validateEmailId,
              onSaved: null,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54),
                ),
                labelText: '+1 123456789',
                labelStyle: textStyle,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );
  }

  Widget headingText(String name) {
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  String _validateEmailId(String value) {
    RegExp emailPattern = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (value.isEmpty) return 'Enter email';
    if (!emailPattern.hasMatch(value)) return 'Email is not valid';
    return null;
  }

  TextStyle get textStyle {
    return TextStyle(
      color: Colors.black54,
    );
  }
}
