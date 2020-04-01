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

//              if (projectModelList.length == 0) {
//                return Padding(
//                  padding: const EdgeInsets.all(16.0),
//                  child: Center(child: Text('No Projects')),
//                );
//              }
              return requestCards(projectModelList);
            //  return formatListFrom(consolidatedList: projectModelList);
          }
        },
      ),
    );
  }

  Widget getSpacerItem(Widget item) {
    return Row(
      children: <Widget>[
        item,
        Spacer(),
      ],
    );
  }

  Widget requestCards(List<ProjectModel> projectlist) {
    var count = 100;
    return Column(
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: 200.0,
            child: ListView.builder(
                itemCount: 1,
                itemBuilder: (_context, index) {
                  return index < projectlist.length - 1
                      ? getListTile(projectlist[index])
                      : SizedBox(
                          height: 50,
                        );
                }),
          ),
        ),
      ],
    );
  }

  BoxDecoration get containerDecorationR {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(2),
            spreadRadius: 6,
            offset: Offset(0, 3),
            blurRadius: 6)
      ],
      color: Colors.white,
    );
  }

  Widget getListTile(ProjectModel projectModel) {
    return Container(
      decoration: containerDecorationR,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          FlatButton.icon(
                            icon: Icon(
                              Icons.add_location,
                              color: Theme.of(context).primaryColor,
                            ),
                            label: Container(
                              width: MediaQuery.of(context).size.width - 170,
                              child: Text(
                                "Manchester",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Text(
                        'an hour ago',
                        style: TextStyle(
                          color: Colors.black38,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 10, left: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(5),
                        height: 40,
                        width: 40,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://icon-library.net/images/user-icon-image/user-icon-image-21.jpg',
                          ),
                          minRadius: 40.0,
                        ),
                      ),
                      Container(
                        child: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              getSpacerItem(
                                Text(
                                  'Experienced Designer',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              getSpacerItem(
                                Text(
                                  '17 Jan 10:00 AM - 17 Jan 11:00 PM',
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              getSpacerItem(
                                Flexible(
                                  flex: 10,
                                  child: Text(
                                    'Design Principal - Electronic and Communication Design',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
//                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
