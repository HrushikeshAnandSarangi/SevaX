// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

import '../core.dart';


class JoinSubTimeBankView extends StatefulWidget {
  _JoinSubTimeBankViewState createState() => _JoinSubTimeBankViewState();


}

class _JoinSubTimeBankViewState extends State<JoinSubTimeBankView> {
  List<JoinRequestModel>  _joinRequestModels;
  bool isDataLoaded=false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async{
    createEditCommunityBloc.getChildTimeBanks();

    getFutureUserRequest(userID: SevaCore.of(context).loggedInUser.sevaUserID).then((newList){
      if(newList!=null ){
        print('User request ${newList}');

      }
    });

  }

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
              FlatButton(
                child: Text("Continue", style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Europa",
                ),),
                textColor: Colors.lightBlue,
                onPressed: () {},
              )
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
    return StreamBuilder<CommunityCreateEditController>(
        stream: createEditCommunityBloc.createEditCommunity,
        builder: (context, snapshot) {
          print(snapshot.data);
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          timebankList = snapshot.data.timebanks;
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
            AspectRatio(
              aspectRatio: 3.3 / 2.3,
              child: CachedNetworkImage(
                imageUrl: timebank.photoUrl,
                fit: BoxFit.fitWidth,
                errorWidget: (context, url, error) =>
                    Center(child: Text('No Image Avaialable')),
                placeholder: (conext, url) {
                  return Center(
                    child: CircularProgressIndicator(

                    ),
                  );
                },
              ),
            ),
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
