import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/messages/chatview.dart';

// import 'package:sevaexchange/views/core.dart';

class TimeBankAboutView extends StatefulWidget {
  final TimebankModel timebankModel;
  final String email;
  final userId;
  TimeBankAboutView.of({this.timebankModel, this.email,this.userId});

  @override
  _TimeBankAboutViewState createState() => _TimeBankAboutViewState();
}

class _TimeBankAboutViewState extends State<TimeBankAboutView> {
  String text =
      "We provide full-cycle services in the areas of App development, web-based enterprise solutions, web application and portal development, We combine our solid business domain experience, technical expertise, profound knowledge of latest industry trends and quality-driven delivery model to offer progressive, end-to-end mobile and web solutions.Single app for all user-types: Teachers, Students & Parent Teachers can take attendance, students can view timetables, parents can view attendance, principal and admins can send messages & announcements, etc. using the same app,Though the traditional login mechanism with the username and password is preferred by the majority of users; the One Time Password (OTP) login via SMS and Emails is favored by all the app users. We have incorporated both of them in the school mobile app to choose the one that suits you the best.";
  bool descTextShowFlag = false;
  bool isUserJoined=false;
  String loggedInUser;
  UserModelListMoreStatus userModels;
  UserModel user;
  bool isDataLoaded=false;
  bool isAdminLoaded=false;

  @override
  void initState() {
    super.initState();
    getData(); // TODO: implement initState

  }

  void getData()async{
    user=await  FirestoreManager.getUserForId(sevaUserId: widget.timebankModel.admins[0]);
     isAdminLoaded=true;

    if(widget.timebankModel.members.contains(widget.userId)){
      isUserJoined=true;
      userModels= await FirestoreManager.getUsersForAdminsCoordinatorsMembersTimebankIdUmesh(
          widget.timebankModel.id, 1,  widget.email);
       isDataLoaded=true;

    }


    setState(() {

    });

  //  print('Time Bank${userModels.userModelList[0].photoURL}');
    //print('User Admin  ${user.fullname.toString()}');

  }

  @override
  Widget build(BuildContext context) {
    var futures = <Future>[];

    widget.timebankModel.members.forEach((member) {
      futures.add(getUserForId(sevaUserId: member));
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Center(
              child: CachedNetworkImage(

                imageUrl:widget.timebankModel.photoUrl,
                fit: BoxFit.fitWidth,
                errorWidget: (context, url, error) =>
                     Text('No Image Avaialable'),
                placeholder: (conext, url) {
                  return CircularProgressIndicator();
                },
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 10, top: 10),
              child: RichText(
                text:
                    TextSpan(style: TextStyle(color: Colors.black), children: [
                  TextSpan(
                    text: 'Part of',
                    style: TextStyle(fontSize: 16, fontFamily: 'Europa'),
                  ),
                  TextSpan(
                    text: " Seva Exchange Time Bank",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa'),
                  )
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                widget.timebankModel.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            isUserJoined
                ? Container(
                    height: 40,
                    child: GestureDetector(
                      child: FutureBuilder(
                          future: Future.wait(futures),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                margin: EdgeInsets.only(left: 15),
                                child: Text("Getting volunteers..."),
                              );
                            }

                            if (widget.timebankModel.members.length == 0) {
                              return Container(
                                margin: EdgeInsets.only(left: 15),
                                child: Text("No Volunteers joined yet."),
                              );
                            }

                            List<String> memberPhotoUrlList = [];
                            for (var i = 0;
                                i < widget.timebankModel.members.length;
                                i++) {
                              UserModel userModel = snapshot.data[i];
                              if (userModel != null) {

                                userModel.photoURL != null
                                    ? memberPhotoUrlList.add(userModel.photoURL)
                                    : print("Userimage not yet set");
                              }
                            }

                            return ListView(
                              padding: EdgeInsets.only(left: 15),
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                ...memberPhotoUrlList.map((photoUrl) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.5),
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: CachedNetworkImageProvider(
                                              photoUrl,
                                            ),
                                          )),
                                    ),
                                  );
                                }).toList()
                              ],
                            );
                          }),
                    ),
                  )
                : Container(),

            isUserJoined&&isDataLoaded?

          Container(
            height: 40,
            child: GestureDetector(
              onTap: (){
                print('listview clicked');
              },
              child: ListView.builder(
                padding: EdgeInsets.only(left: 20),
                scrollDirection: Axis.horizontal,

                itemCount: 8,
                itemBuilder: (context,index){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          image: DecorationImage(fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  userModels.userModelList[index].photoURL,

                              ),
                          )
                      ),

                    ),
                  );
                },


              ),
            ),
          ):Container(

          ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 20),
              child: Text(
                widget.timebankModel.members.length.toString() + ' Volunteers',
                style: TextStyle(
                  fontFamily: 'Europa',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.timebankModel.address,
                style: TextStyle(
                  fontFamily: 'Europa',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
              child: Text(
                'About us',
                style: TextStyle(
                  fontFamily: 'Europa',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.timebankModel.missionStatement,
                      style: TextStyle(
                        fontFamily: 'Europa',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      maxLines: descTextShowFlag ? null : 2,
                      textAlign: TextAlign.start),
                  InkWell(
                    onTap: () {
                      setState(() {
                        descTextShowFlag = !descTextShowFlag;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        descTextShowFlag
                            ? Text(
                                "Read Less",
                                style: TextStyle(
                                  fontFamily: 'Europa',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlueAccent,
                                ),
                              )
                            : Text(
                                "Read More",
                                style: TextStyle(
                                  fontFamily: 'Europa',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlueAccent,
                                ),
                              )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Divider(
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Organizers',
                style: TextStyle(
                  fontFamily: 'Europa',
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),



            Padding(
              padding: const EdgeInsets.all(20.0),

              child: Row(
                children: <Widget>[

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      isAdminLoaded?

                      RichText(
                        text: TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: user.fullname??'',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Europa'),
                              ),
                              TextSpan(
                                text: '  and Others',
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'Europa'),
                              ),
                            ]),
                      ):Container(
                        child:
                        Center(child: CircularProgressIndicator()),
                      ),
                      FlatButton(
                        onPressed: () {
                          startChat(user.email,widget.email,context);
                        //  print('Clicked');
                        },
                        child: Text(
                          'Message',
                          style: TextStyle(
                            fontFamily: 'Europa',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  isAdminLoaded?
                  Container(
                    height: 60,
                    width: 60,

                    decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        image: DecorationImage(fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(user.photoURL)
                    ),

                  )
                  ):Container(

                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void startChat(String email, String loggedUserEmail, BuildContext context) async {
  if (email == loggedUserEmail) {
    return null;
  } else  {
    List users = [
      email,
      loggedUserEmail
    ];
    print("Listing users");
    users.sort();
    ChatModel model = ChatModel();
    model.user1 = users[0];
    model.user2 = users[1];
    print("Model1" + model.user1);
    print("Model2" + model.user2);

    await createChat(chat: model).then(
          (_) {
        Navigator.of(context).pop();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatView(
              useremail: email,
              chatModel: model,
              isFromShare: false,
              news: NewsModel(),
              isFromNewChat: IsFromNewChat(
                  true, DateTime.now().millisecondsSinceEpoch),
            ),
          ),
        );
      },
    );
  }

}
