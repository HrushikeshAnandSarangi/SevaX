// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/home_dashboard.dart';
import 'package:sevaexchange/views/timebanks/timebank_view_latest.dart';

import '../core.dart';


class JoinSubTimeBankView extends StatefulWidget {
  final String seveUserId;

  JoinSubTimeBankView(this.seveUserId);

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
    _joinRequestModels= await getFutureUserRequest(userID: widget.seveUserId);
      isDataLoaded=true;
      setState(() {

      });
      //print('User request ${}');


       // print('User request ${newList}');



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
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Home_DashBoard()));
                },
              )
            ]),
        body: isDataLoaded?  SingleChildScrollView(
            child: getTimebanks(context: context),
        ):Center(child: CircularProgressIndicator()),
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
          print("data ${dropdownList.length}");

          if(snapshot.data != null){
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
                  child: Text(
                    "Join the timebank to contribute to the community for the change",
                  ),
                ),
                ListView.separated(
                  itemCount: timebankList.length,
                  physics: NeverScrollableScrollPhysics(),

                  itemBuilder: (context, index) {
                    TimebankModel timebank = timebankList.elementAt(index);
                    String status=compareTimeBanks(_joinRequestModels,timebank);
                    print(timebank.children.toString());
                    return makeItem(timebank,status);
                  },
                  padding: const EdgeInsets.all(8),
                  shrinkWrap: true,
                  separatorBuilder: (context,index){
                    return Divider(
                      indent: 10,
                      endIndent: 10,
                      color: Colors.grey,

                    );
                  },
                ),
              ],
            );
          }
          return CircularProgressIndicator();
        });
  }

  Widget makeItem(TimebankModel timebank, String status) {
    return InkWell(
      onTap: (){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => TimeBankAboutView.of(timebankModel:timebank,userId: widget.seveUserId)));
      },
      child: Padding(
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
                      child: Text(
                          status,
                          style: TextStyle(fontSize: 14)
                      ),
                      onPressed: status=='Join'?() {
                        print('Join btn clicked');
                      }:null,
                    ),
                  ),
                ],
              ),

            ],
          )
      ),
    );
  }

  String compareTimeBanks(List<JoinRequestModel> joinRequestModels, TimebankModel timebank) {

    for(int i=0;i<joinRequestModels.length;i++){


      if(joinRequestModels[i].entityId==timebank.id && joinRequestModels[i].accepted==true){
        return 'Joined';
      }

      if(joinRequestModels[i].entityId==timebank.id && joinRequestModels[i].operationTaken==false){
        return 'Requested';
      }
      if(joinRequestModels[i].entityId==timebank.id && joinRequestModels[i].operationTaken==true && joinRequestModels[i].accepted==false){
        return 'Rejected';
      }

      return 'Join';

    }
  }
}
