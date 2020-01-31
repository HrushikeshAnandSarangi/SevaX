

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../core.dart';

class InvitedUsersView extends StatefulWidget{

  final String timebankId;
  final RequestModel requestModel;
  final String sevaUserId;

  InvitedUsersView({@required this.timebankId, this.requestModel, this.sevaUserId});

  @override
  _InvitedUsersViewState createState() {
    // TODO: implement createState
    return _InvitedUsersViewState();
  }

}

class _InvitedUsersViewState extends State<InvitedUsersView> {
  var validItems;
  bool isAdmin =false;
  final _firestore = Firestore.instance;
  List<UserModel> favoriteUsers;
  bool shouldInvite = true;
  TimeBankModelSingleton timebank = TimeBankModelSingleton();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeBankBloc.setInvitedUsersData(widget.requestModel.id);
    setState(() {

    });

    if(timebank.model.admins.contains(widget.sevaUserId)){
      isAdmin =true;
    }

    if(isAdmin){
      //   print('admin is true ');
      _firestore
          .collection("users")
          .where(
        'favoriteByTimeBank',
        arrayContains: timebank.model.id,
      )
          .getDocuments()
          .then(
            (QuerySnapshot querysnapshot) {
              if (favoriteUsers == null) favoriteUsers = List();

              querysnapshot.documents.forEach(
                (DocumentSnapshot user) => favoriteUsers.add(
              UserModel.fromMap(
                user.data,
              ),
            ),
          );
          setState(() {});
        },
      );
    }else{
      //    print('admin is false ');
      _firestore
          .collection("users")

          .where(
        'favoriteByMember',
        arrayContains: widget.sevaUserId,
      )
          .getDocuments()
          .then(
            (QuerySnapshot querysnapshot) {
              if (favoriteUsers == null) favoriteUsers = List();

              querysnapshot.documents.forEach(
                (DocumentSnapshot user) => favoriteUsers.add(
              UserModel.fromMap(
                user.data,
              ),
            ),
          );
         setState(() {});
        },
      );

    }



  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timeBankBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  StreamBuilder<TimebankController>(
//      stream: SearchManager.searchForUserWithTimebankId( // TODO : replace function here
//          queryString: "", validItems: validItems),
      stream: timeBankBloc.timebankController,
      builder: (context, AsyncSnapshot<TimebankController> snapshot) {

        if (snapshot.hasError) {
          Text(snapshot.error.toString());
        }


        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              height: 48,
              width: 48,
              child: CircularProgressIndicator(),
            ),
          );
        }
        List<UserModel> userList = snapshot.data.invitedUsersForRequest;


        if (userList.length == 0) {
          return getEmptyWidget('Users', 'No user found');
        }



        return ListView.builder(
            shrinkWrap: true,
            itemCount: userList.length,
            itemBuilder: (context,index){

              bool isfavorite = false;

              UserModel user = userList.elementAt(index);


              if(favoriteUsers != null){


                favoriteUsers.forEach((f){

                  if (f.sevaUserID == user.sevaUserID){
                    //  print("found a match for ${f.fullname}   --  ${user.sevaUserID}");
                    isfavorite = true;
                  }

                });

                return RequestCardWidget(
                  userModel: user,
                  requestModel: widget.requestModel,
                  timebankModel: timebank.model,
                  isFavorite: isfavorite,
                  cameFromInvitedUsersPage: true,
                );


              } else{


                return RequestCardWidget(
                  userModel: user,
                  requestModel: widget.requestModel,
                  timebankModel: timebank.model,
                  isFavorite: false,
                  cameFromInvitedUsersPage: true,

                );
              }

            });
        //return

        /*ListView(



        children: <Widget>[
           // Text('Users'),
            ...userList.map((data)=>


                RequestCardWidget(userModel: data,
                  requestModel: widget.requestModel,
                  isFavorite: true,
                  cameFromInvitedUsersPage: true,
                  timebankModel: timebank.model,)).toList()


          ],
        );*/
      },
    );
  }


 /* Widget makeUserWidget({UserModel  userModel, RequestModel requestModel,BuildContext context}) {


    return Container(
        margin: EdgeInsets.fromLTRB(30, 20, 25, 10),
        child: Stack(
            children: <Widget>[
              getUserCard(context: context,userModel: userModel,requestModel: requestModel),
              getUserThumbnail(userModel.photoURL),
            ]
        )
    );
  }

  Widget getUserThumbnail(String photoURL) {
    return Container(
        margin: EdgeInsets.only(top: 20, right: 15),
        width: 60.0,
        height: 60.0,
        decoration: BoxDecoration(
            shape: BoxShape.circle,


            image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(
                    photoURL)
            )
        ));
  }

  Widget getUserCard( {BuildContext context, UserModel userModel,RequestModel requestModel}) {
    bool isBookMarked = false;

    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Container(
        height: 200,
        width: 500,
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: new BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: new Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(userModel.fullname, style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),),
                  ),
//              Spacer(),
                  InkWell(

                    onTap: () {
                      if(isBookMarked){
                        removeFromFavoriteList(context, userModel, timebank.model);

                      }else{
                        addToFavoriteList(context,userModel,timebank.model);

                      }

                      setState(() {
                        isBookMarked = !isBookMarked;
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        isBookMarked ?

                        Icon(
                          Icons.bookmark, color: Colors.redAccent,
                          size: 35,
                        ) : Icon(
                          Icons.bookmark,
                          color: Colors.grey,
                          size: 35,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
//              SmoothStarRating(
//                  allowHalfRating: true,
//                  onRatingChanged: (v) {
////                    rating = v;
////                    setState(() {});
//                  },
//                  starCount: 5,
//                  rating: 3.5,
//                  size: 20.0,
//                  filledIconData: Icons.star,
//                  halfFilledIconData: Icons.star_half,
//                  defaultIconData: Icons.star_border,
//                  color: Colors.orangeAccent,
//                  borderColor: Colors.orangeAccent,
//                  spacing: 1.0
//              ),
              SizedBox(
                  height: 10
              ),
              Expanded(
                child: Text(
                  userModel.bio,
                  maxLines: 3,
                  style: TextStyle(color: Colors.black, fontSize: 12,),),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    *//*  decoration: BoxDecoration(

                        boxShadow: [BoxShadow(
                            color: Colors.indigo[50],
                            blurRadius: 1,
                            offset: Offset(0.0, 0.50)
                        )]
                    ),*//*
                    height: 40,
                    padding: EdgeInsets.only(bottom: 10),
                    child: RaisedButton(
                        shape: StadiumBorder(),
                        color: Colors.indigo,
                        textColor: Colors.white,
                        elevation: 5,
                        onPressed:(){

                        },
                        child:Text(
                            'Invited',
                            style: TextStyle(fontSize: 14)
                        )

                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }




  Future<void> addToFavoriteList(BuildContext context, UserModel userModel, TimebankModel timebankModel) async {

    await Firestore.instance
        .collection('users')
        .document(userModel.email)
        .updateData({ isAdmin ? 'favoriteByTimeBank' : 'favoriteByMember'
        : FieldValue.arrayUnion([isAdmin ? timebankModel.id : SevaCore.of(context).loggedInUser.sevaUserID])
    });


  }

  Future<void> removeFromFavoriteList(BuildContext context, UserModel userModel, TimebankModel timebankModel) async {

    await Firestore.instance
        .collection('users')
        .document(userModel.email)
        .updateData({ isAdmin ? 'favoriteByTimeBank' : 'favoriteByMember' :
    FieldValue.arrayRemove([isAdmin ? timebankModel.id : SevaCore.of(context).loggedInUser.sevaUserID])
    });


  }
*/
  Widget getEmptyWidget(String title, String notFoundValue) {
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

  TextStyle get sectionTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.grey,
    );
  }

}