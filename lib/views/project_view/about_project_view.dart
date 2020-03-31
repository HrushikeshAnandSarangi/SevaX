import 'package:flutter/material.dart';
import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class AboutProjectView extends StatefulWidget {
  final String projectId;

  AboutProjectView({this.projectId});

  @override
  _AboutProjectViewState createState() => _AboutProjectViewState();
}

class _AboutProjectViewState extends State<AboutProjectView> {
  ProjectModel projectModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirestoreManager.getProjectFutureById(
            projectId: '52827441-9a8b-4207-b28a-5aa1ef30d659')
        .then((onValue) {
      projectModel = onValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Column(
                      children: <Widget>[
                        TimebankAvatar(
                              photoUrl: projectModel.photoUrl,
                            ) ??
                            TimebankAvatar(
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
                      ],
                    ),
                  ),
                ),
                headingText('Title'),
                Text(projectModel.name ?? ""),
                headingText('Mission Statement'),
                Text(projectModel.description ?? ""),
                headingText('Organised By'),
                Text(projectModel.emailId ?? ""),
              ],
            ),
            FlatButton(
              onPressed: () {
                print('pressed');
              },
              child: Text('Edit'),
            )
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
}
