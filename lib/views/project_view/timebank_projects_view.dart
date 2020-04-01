import 'package:flutter/material.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class TimeBankProjectsView extends StatefulWidget {
  final String timebankId;

  TimeBankProjectsView({this.timebankId});

  @override
  _TimeBankProjectsViewState createState() => _TimeBankProjectsViewState();
}

class _TimeBankProjectsViewState extends State<TimeBankProjectsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<ProjectModel>>(
        stream: FirestoreManager.getAllProjectListStream(
            timebankid: widget.timebankId),
        builder: (BuildContext context,
            AsyncSnapshot<List<ProjectModel>> requestListSnapshot) {
          if (requestListSnapshot.hasError) {
            return new Text('Error: ${requestListSnapshot.error}');
          }
          switch (requestListSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              List<ProjectModel> projectModelList = requestListSnapshot.data;

              if (projectModelList.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: Text('No Requests')),
                );
              }
              return Container();
            //  return formatListFrom(consolidatedList: projectModelList);
          }
        },
      ),
    );
  }
}
