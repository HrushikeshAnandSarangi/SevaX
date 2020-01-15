// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

import '../core.dart';


class JoinSubTimeBankView extends StatefulWidget {
  final bool isPostJoin;

  JoinSubTimeBankView({@required this.isPostJoin});

  _JoinSubTimeBankViewState createState() => _JoinSubTimeBankViewState();
}

class _JoinSubTimeBankViewState extends State<JoinSubTimeBankView> {
  /*List<Map<String, dynamic>> litems = [
    {
      "url": "https://images.adsttc.com/media/images/5d67/9f09/284d/d1be/6000/0109/newsletter/02_ZQ.jpg?1567071993",
      "name": "Hosur-San Timebank",
      "location": "Bangalore, India",
      "memberCount": "6787 Members"
    },
    {
      "url": "https://cdn.britannica.com/15/152315-050-226AA671/twin-towers-skyline-Lower-Manhattan-World-Trade-September-11-2001.jpg",
      "name": "Hebbal Timebank",
      "location": "Bangalore, India",
      "memberCount": "2332 Members"
    },
    {
      "url": "https://cdn.britannica.com/15/152315-050-226AA671/twin-towers-skyline-Lower-Manhattan-World-Trade-September-11-2001.jpg",
      "name": "Hebbal Timebank",
      "location": "Bangalore, India",
      "memberCount": "2332 Members"
    }
  ];*/

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
//          leading: BackButton(color: Colors.black87),

            title: Text("Time Banks", style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: "Europa",
            )),
            centerTitle: true,

            actions: <Widget>[
              widget.isPostJoin ? FlatButton(
                child: Text("Continue", style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Europa",
                ),),
                textColor: Colors.lightBlue,
                onPressed: () {},
              ):Text(""),
            ]),
        body: getTimebanks(context: context)
    );
  }

  List<String> dropdownList = [];

  Widget getTimebanks({BuildContext context}) {
    Size size = MediaQuery
        .of(context)
        .size;

    List<TimebankModel> timebankList = [];
    return StreamBuilder<List<TimebankModel>>(
        stream: FirestoreManager.getSubTimebanksForUserStream(
          userId: SevaCore
              .of(context)
              .loggedInUser
              .sevaUserID,
        ),
        builder: (context, snapshot) {
          print(snapshot.data);
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          timebankList = snapshot.data;
          timebankList.forEach((t) {
            dropdownList.add(t.id);
          });

          // Navigator.pop(context);
          print("Umesh ${dropdownList.length}");

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
                child: Text(
                  "Join the timebank to contribute to the community for the change",
                ),
              ),
              ListView.builder(
                itemCount: timebankList.length,
                itemBuilder: (context, index) {
                  TimebankModel timebank = timebankList.elementAt(index);
                  print(timebank.children.toString());
                  return makeItem(timebank);
                },
                padding: const EdgeInsets.all(8),
              shrinkWrap: true,
              ),
            ],
          );
        });
  }

  Widget makeItem(TimebankModel timebank) {
    return Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // AspectRatio(
            //   aspectRatio: 3.3 / 2.3,
            //   child: CachedNetworkImage(
            //     imageUrl: timebank.photoUrl,
            //     fit: BoxFit.fitWidth,
            //     errorWidget: (context, url, error) =>
            //         Center(child: Text('No Image Avaialable')),
            //     placeholder: (conext, url) {
            //       return Center(
            //         child: CircularProgressIndicator(

            //         ),
            //       );
            //     },
            //   ),
            // ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 7,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        timebank.name,
                        style: TextStyle(
                          fontFamily: "Europa",
                          fontSize: 18,
                          color: Colors.black,
                        ),
//                                maxLines: 1,
                      ),
                      Text(
                        timebank.address + ' .' +
                            timebank.members.length.toString(),
                        style: TextStyle(
                            fontFamily: "Europa",
                            fontSize: 14,

                            color: Colors.grey
                        ),
                        maxLines: 1,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: RaisedButton(
                    elevation: 0,
                    shape: StadiumBorder(),
                    textColor: Colors.lightBlue,
                    child: const Text(
                        'Join',
                        style: TextStyle(fontSize: 14)
                    ),
                    onPressed: () {
                      print('Join btn clicked');
                    },
                  ),
                ),
              ],
            ),

          ],
        )
    );
  }
}
