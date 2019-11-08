import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:sevaexchange/views/timebanks/timebank_view.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
import 'package:sevaexchange/views/timebanks/waiting_admin_accept.dart';

class TimeBankList extends StatelessWidget {
  final String timebankid;
  final String title;
  TimeBankList({@required this.timebankid, @required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //automaticallyImplyLeading: false,
          title: Text(
            FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                ? 'Yang Gangs' //Chapters
                : title,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName));
              },
            )
          ],
        ),
        floatingActionButton: Visibility(
          visible: !UserData.shared.isFromLogin,
          child: FloatingActionButton.extended(
            label: Text(FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                ? 'Create Yang Gang'
                : 'Create Branch'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimebankCreate(
                    timebankId: timebankid,
                  ),
                ),
              );
            },
            foregroundColor: FlavorConfig.values.buttonTextColor,
            icon: Icon(
              Icons.add,
            ),
          ),
        ),
        body: getSubTimebanks(timebankid));
  }

  Widget getSubTimebanks(String timebankId) {
    return StreamBuilder<List<TimebankModel>>(
      stream: getChildTimebanks(
        timebankId: timebankId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        List<TimebankModel> reportedList = snapshot.data;
        return Container(
          child: getDataScrollView(
            context,
            reportedList,
          ),
        );
      },
    );
  }

  Widget getDataScrollView(
    BuildContext context,
    List<TimebankModel> reportedList,
  ) {
    return getContent(context, reportedList);
  }

  void _showDialog(BuildContext context, String name) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Request to join"),
          content: new Text("Do you want to join $name timebank?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Join"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => WaitingView(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  ImageProvider _getImage(TimebankModel model) {
    if (model.photoUrl == null) {
      return AssetImage('lib/assets/images/profile.png');
    } else {
      return NetworkImage(model.photoUrl);
    }
  }

  Widget getContent(BuildContext context, List<TimebankModel> timebankList) {
    return Column(
      children: <Widget>[
        ...timebankList.map((model) {
          return model.id != FlavorConfig.values.timebankId
              ? GestureDetector(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: CircleAvatar(
                              minRadius: 32.0,
                              backgroundColor: Colors.grey,
                              backgroundImage: _getImage(model),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Container(
                            child: Text(
                              model.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    // _showDialog(context,model.name);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (routeContext) {
                          return TimebankView(timebankId: model.id);
                        },
                      ),
                    );
                  },
                )
              : Offstage();
        })
      ],
    );
  }
}

//         return ListView.builder(
//           itemCount: rootTB.children.length,
//           itemBuilder: (BuildContext listContext, int i) {
//             String childTimebankId = rootTB.children.elementAt(i);
//             return StreamBuilder<Object>(
//               stream: getTimebankModelStream(timebankId: childTimebankId),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError)
//                   return new Container(); //Text('Error: ${snapshot.error}');
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Offstage();
//                 }
//                 TimebankModel model = snapshot.data;
//                 return model.id != FlavorConfig.values.timebankId
//                     ? GestureDetector(
//                         child: Card(
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Row(
//                               children: <Widget>[
//                                 Container(
//                                   child: CircleAvatar(
//                                     minRadius: 32.0,
//                                     backgroundColor: Colors.grey,
//                                     backgroundImage: _getImage(model),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 8,
//                                 ),
//                                 Container(
//                                   child: Text(
//                                     model.name,
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 18.0,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                         onTap: () {
//                           // _showDialog(context,model.name);
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (routeContext) {
//                                 return TimebankView(timebankId: model.id);
//                               },
//                             ),
//                           );
//                         },
//                       )
//                     : Offstage();
//               },
//             );
//           },
//         );
//       }
//     },
//   ),
// ),
