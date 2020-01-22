import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/views/messages/chatview.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';

//TODO update bio and remove un-necessary stuff

class ProfileViewer extends StatefulWidget {
  final String userEmail;
  UserModel userModel;
  bool isBlocked = false;

  ProfileViewer({this.userEmail});

  @override
  State<StatefulWidget> createState() {
    return ProfileViewerState();
  }
}

class ProfileViewerState extends State<ProfileViewer> {
  @override
  Widget build(BuildContext context) {
    String loggedInEmail = SevaCore.of(context).loggedInUser.email;
    UserModel userData = SevaCore.of(context).loggedInUser;

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   elevation: 0,

      // backgroundColor: Colors.white,
      // title: Text(
      //   'User Profile',
      //   style: TextStyle(color: Colors.white),
      // ),
      // centerTitle: false,
      // ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(widget.userEmail)
            .snapshots(),
        builder: (BuildContext firebasecontext,
            AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              widget.userModel = UserModel.fromMap(snapshot.data.data);

              if (widget.userModel == null) {
                print("User details not fouund");
                Navigator.pop(context);
                return Offstage();
              }

              if (widget.userModel.fullname == null) {
                widget.userModel.fullname = defaultUsername;
              }

              if (widget.userModel.photoURL == null) {
                widget.userModel.photoURL = defaultUserImageURL;
              }

              widget.isBlocked =
                  widget.userModel.blockedBy.contains(userData.sevaUserID);
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppBar(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      iconTheme: IconThemeData(color: Colors.grey),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 25),
                      height: 100,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ProfileImage(
                            image: snapshot.data['photourl'],
                            tag: widget.userEmail,
                            radius: 50,
                          ),
                          SizedBox(width: 20),
                          ProfileHeader(
                            rating: '4.5',
                            name: snapshot.data['fullname'],
                            email: snapshot.data['email'],
                            isBlocked: widget.isBlocked,
                            message: widget.userEmail == loggedInEmail ||
                                    widget.isBlocked
                                ? null
                                : () => onMessageClick(loggedInEmail),
                            block: widget.userEmail == loggedInEmail
                                ? null
                                : onBlockClick,
                            report: widget.userEmail == loggedInEmail
                                ? null
                                : () => onReportClick(
                                      userData: userData,
                                      userId: snapshot.data['sevauserid'],
                                    ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 20,
                      ),
                      child: UserProfileDetails(
                        title: 'About ${snapshot.data['fullname']}',
                        details: snapshot.data['bio']??'',
                      ),
                    ),

                    SkillAndInterestBuilder(
                      skills: snapshot.data['skills'],
                      interests: snapshot.data['interests'],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 20),
                      child: JobsCounter(
                        jobs: 32,
                        hours: 1300,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Availability\n',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                            // TextSpan(text: '', style: TextStyle(height: 10)),
                            TextSpan(
                              text: 'Available as needed - Open to Offers',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.symmetric(
                    //     horizontal: 25,
                    //     vertical: 20,
                    //   ),
                    //   child: Container(
                    //     width: 170,
                    //     child: Column(
                    //       children: <Widget>[
                    //         OutlineButton(
                    //           borderSide: BorderSide(
                    //             color: Theme.of(context).accentColor,
                    //           ),
                    //           child: Row(
                    //             children: <Widget>[
                    //               Icon(
                    //                 Icons.forum,
                    //                 color: Theme.of(context).accentColor,
                    //               ),
                    //               Text(' Messages'),
                    //             ],
                    //           ),
                    //           onPressed: widget.userEmail == loggedInEmail ||
                    //                   widget.isBlocked
                    //               ? null
                    //               : () => onMessageClick(loggedInEmail),
                    //         ),
                    //         SizedBox(height: 10),
                    //         OutlineButton(
                    //           borderSide: BorderSide(
                    //             color: Theme.of(context).accentColor,
                    //           ),
                    //           child: Row(
                    //             children: <Widget>[
                    //               Icon(
                    //                 Icons.block,
                    //                 color: Theme.of(context).accentColor,
                    //               ),
                    //               Text(widget.isBlocked ? 'Unblock' : 'Block'),
                    //             ],
                    //           ),
                    //           onPressed: widget.userEmail == loggedInEmail
                    //               ? null
                    //               : onBlockClick,
                    //         ),
                    //         SizedBox(height: 10),
                    //         OutlineButton(
                    //           borderSide: BorderSide(
                    //             color: Theme.of(context).accentColor,
                    //           ),
                    //           child: Row(
                    //             children: <Widget>[
                    //               Icon(
                    //                 Icons.flag,
                    //                 color: Theme.of(context).accentColor,
                    //               ),
                    //               Text(' Report Member')
                    //             ],
                    //           ),
                    //           onPressed: widget.userEmail == loggedInEmail
                    //               ? null
                    //               : () => onReportClick(
                    //                     userData: userData,
                    //                     userId: snapshot.data['sevauserid'],
                    //                   ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    //   height: 110.0,
                    //   child: Column(
                    //     children: <Widget>[
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //         children: <Widget>[
                    //           Container(
                    //             padding: EdgeInsets.only(top: 25.0),
                    //             child: CircleAvatar(
                    //               backgroundImage: NetworkImage(
                    //                   snapshot.data['photourl'] ?? ''),
                    //               minRadius: 40.0,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
                    //   child: Center(
                    //     child: Text(
                    //       widget.userModel.fullname,
                    //       style: TextStyle(
                    //           fontWeight: FontWeight.w800, fontSize: 17.0),
                    //       // overflow: TextOverflow.ellipsis,
                    //       // maxLines: 2,
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    // padding: EdgeInsets.fromLTRB(
                    //     MediaQuery.of(context).size.width / 2.6,
                    //     0,
                    //     MediaQuery.of(context).size.width / 2.6,
                    //     0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: <Widget>[
                    //       OutlineButton(
                    //         borderSide: BorderSide(
                    //           color: Theme.of(context).accentColor,
                    //         ),
                    //         child: Row(
                    //           children: <Widget>[
                    //             Icon(
                    //               Icons.forum,
                    //               color: Theme.of(context).accentColor,
                    //             ),
                    //             Text(' Messages'),
                    //           ],
                    //         ),
                    //         onPressed: widget.userEmail == loggedInEmail ||
                    //                 widget.isBlocked
                    //             ? null
                    //             : () {
                    //                 List users = [
                    //                   widget.userEmail,
                    //                   loggedInEmail
                    //                 ];
                    //                 users.sort();
                    //                 ChatModel model = ChatModel();
                    //                 model.user1 = users[0];
                    //                 model.user2 = users[1];
                    //                 createChat(chat: model);
                    //                 Navigator.push(
                    //                   context,
                    //                   MaterialPageRoute(
                    //                     builder: (context) => ChatView(
                    //                       useremail: widget.userEmail,
                    //                       chatModel: model,
                    //                     ),
                    //                   ),
                    //                 );
                    //               },
                    //       ),
                    //       Padding(
                    //         padding: EdgeInsets.only(left: 5.0),
                    //       ),
                    //       Container(
                    //         width: 10,
                    //       ),
                    //       Offstage(
                    //         offstage: false,
                    //         child: OutlineButton(
                    //           borderSide: BorderSide(
                    //             color: Theme.of(context).accentColor,
                    //           ),
                    //           child: Row(
                    //             children: <Widget>[
                    //               Icon(
                    //                 Icons.block,
                    //                 color: Theme.of(context).accentColor,
                    //               ),
                    //               Text(widget.isBlocked ? 'Unblock' : 'Block'),
                    //             ],
                    //           ),
                    //           onPressed: widget.userEmail == loggedInEmail
                    //               ? null
                    //               : () {
                    //                   var onDialogActviityResult =
                    //                       blockMemberDialogView(
                    //                     context,
                    //                   );

                    //                   onDialogActviityResult.then((result) {
                    //                     print("result " + result);

                    //                     switch (result) {
                    //                       case "BLOCK":
                    //                         blockMember(ACTION.BLOCK);
                    //                         break;

                    //                       case "UNBLOCK":
                    //                         blockMember(ACTION.UNBLOCK);

                    //                         break;

                    //                       case "CANCEL":
                    //                         break;
                    //                     }
                    //                   });
                    //                 },
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: <Widget>[
                    //       OutlineButton(
                    //         borderSide: BorderSide(
                    //           color: Theme.of(context).accentColor,
                    //         ),
                    //         child: Row(
                    //           children: <Widget>[
                    //             Icon(
                    //               Icons.flag,
                    //               color: Theme.of(context).accentColor,
                    //             ),
                    //             Text(' Report Member')
                    //           ],
                    //         ),
                    //         onPressed: widget.userEmail == loggedInEmail
                    //             ? null
                    //             : () {
                    //                 showDialog(
                    //                   context: context,
                    //                   builder: (BuildContext viewContext) {
                    //                     // return object of type Dialog
                    //                     return AlertDialog(
                    //                       title: Text('Report Member?'),
                    //                       content: Text(
                    //                           'Do you want to report this member to admin?'),
                    //                       actions: <Widget>[
                    //                         FlatButton(
                    //                           child: Text(
                    //                             'Cancel',
                    //                             style: TextStyle(
                    //                               fontSize: dialogButtonSize,
                    //                             ),
                    //                           ),
                    //                           onPressed: () {
                    //                             Navigator.of(viewContext).pop();
                    //                           },
                    //                         ),
                    //                         FlatButton(
                    //                           child: Text(
                    //                             'Report',
                    //                             style: TextStyle(
                    //                               fontSize: dialogButtonSize,
                    //                             ),
                    //                           ),
                    //                           onPressed: () {
                    //                             print(snapshot
                    //                                 .data['sevauserid']);

                    //                             Firestore.instance
                    //                                 .collection(
                    //                                     'reported_users_list')
                    //                                 .where('timebankId',
                    //                                     isEqualTo: FlavorConfig
                    //                                         .values.timebankId)
                    //                                 .where('reporterId',
                    //                                     isEqualTo:
                    //                                         userData.sevaUserID)
                    //                                 .where('reportedId',
                    //                                     isEqualTo: snapshot
                    //                                         .data['sevauserid'])
                    //                                 .getDocuments()
                    //                                 .then((data) {
                    //                               if (data.documents.length ==
                    //                                   0) {
                    //                                 Firestore.instance
                    //                                     .collection(
                    //                                         'reported_users_list')
                    //                                     .add({
                    //                                       "reporterId": userData
                    //                                           .sevaUserID,
                    //                                       "reportedId":
                    //                                           snapshot.data[
                    //                                               'sevauserid'],
                    //                                       "timebankId":
                    //                                           FlavorConfig
                    //                                               .values
                    //                                               .timebankId
                    //                                     })
                    //                                     .then((result) => {
                    //                                           Navigator.pop(
                    //                                               viewContext),
                    //                                           Navigator.of(
                    //                                                   context)
                    //                                               .pop()
                    //                                         })
                    //                                     .catchError((err) =>
                    //                                         print(err));
                    //                               } else {
                    //                                 Navigator.pop(viewContext);
                    //                                 Navigator.of(context).pop();
                    //                               }
                    //                             });
                    //                           },
                    //                         ),
                    //                       ],
                    //                     );
                    //                   },
                    //                 );
                    //               },
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // Container(
                    //   padding: EdgeInsets.only(left: 25.0, right: 25.0),
                    //   child: Divider(
                    //     color: Colors.deepPurple,
                    //   ),
                    // ),
                    // Container(
                    //   padding:
                    //       EdgeInsets.only(left: 25.0, right: 25.0, top: 5.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: <Widget>[
                    //       Text(
                    //         'Bio and CV',
                    //         style: TextStyle(
                    //             fontSize: 16.0, fontWeight: FontWeight.w700),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   padding: EdgeInsets.only(left: 25.0, right: 25.0),
                    //   child: Text(
                    //     snapshot.data['bio'] ?? '',
                    //     style: TextStyle(
                    //         fontSize: 16.0, fontWeight: FontWeight.w400),
                    //   ),
                    // ),

                    // Container(
                    //   padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                    //   child: Text(
                    //     'My Interests',
                    //     style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
                    //   ),
                    // ),

                    // Padding(
                    //   padding: EdgeInsets.all(20.0),
                    // ),

                    // Container(
                    //   padding: EdgeInsets.only(left: 25.0, top: 15.0, right: 25.0),
                    //   child: TaskButton(),
                    // ),
                    // Container(
                    //   padding: EdgeInsets.only(left: 25.0, top: 15.0, right: 25.0),
                    //   child: HoursExchangeButton(),
                    // ),
                    // Padding(
                    //   padding: EdgeInsets.all(10.0),
                    // ),

                    // Container(
                    //   padding: EdgeInsets.only(left: 25.0, top: 15.0, right: 25.0),
                    //   child: Text('appName  - ' + _appName + 'appName  - ' + _appName +
                    //               'packageName  - ' + _packageName +
                    //               'version  - ' + _version +
                    //               'BuildNumber  - ' + _buildNumber),
                    // ),
                    // Container(
                    //   child: Text(' '),
                    // ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  void onMessageClick(loggedInEmail) {
    List users = [widget.userEmail, loggedInEmail];
    users.sort();
    ChatModel model = ChatModel();
    model.user1 = users[0];
    model.user2 = users[1];
    createChat(chat: model);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatView(
          useremail: widget.userEmail,
          chatModel: model,
        ),
      ),
    );
  }

  void onBlockClick() {
    var onDialogActviityResult = blockMemberDialogView(
      context,
    );

    onDialogActviityResult.then((result) {
      print("result " + result);

      switch (result) {
        case "BLOCK":
          blockMember(ACTION.BLOCK);
          break;

        case "UNBLOCK":
          blockMember(ACTION.UNBLOCK);

          break;

        case "CANCEL":
          break;
      }
    });
  }

  void onReportClick({UserModel userData, String userId}) {
    showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        // return object of type Dialog
        return AlertDialog(
          title: Text('Report Member?'),
          content: Text(
            'Do you want to report this member to admin?',
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                Navigator.of(viewContext).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Report',
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                print(userId);

                Firestore.instance
                    .collection('reported_users_list')
                    .where('timebankId',
                        isEqualTo: FlavorConfig.values.timebankId)
                    .where('reporterId', isEqualTo: userData.sevaUserID)
                    .where('reportedId', isEqualTo: userId)
                    .getDocuments()
                    .then((data) {
                  if (data.documents.length == 0) {
                    Firestore.instance
                        .collection('reported_users_list')
                        .add({
                          "reporterId": userData.sevaUserID,
                          "reportedId": userId,
                          "timebankId": FlavorConfig.values.timebankId
                        })
                        .then((result) => {
                              Navigator.pop(viewContext),
                              Navigator.of(context).pop()
                            })
                        .catchError((err) => print(err));
                  } else {
                    Navigator.pop(viewContext);
                    Navigator.of(context).pop();
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  void blockMember(ACTION action) {
    switch (action) {
      case ACTION.BLOCK:
        Firestore.instance
            .collection("users")
            .document(SevaCore.of(context).loggedInUser.email)
            .updateData({
          'blockedMembers': FieldValue.arrayUnion([widget.userModel.sevaUserID])
        });
        Firestore.instance
            .collection("users")
            .document(widget.userModel.email)
            .updateData({
          'blockedBy': FieldValue.arrayUnion(
              [SevaCore.of(context).loggedInUser.sevaUserID])
        });
        setState(() {
          widget.isBlocked = !widget.isBlocked;
          var updateUser = SevaCore.of(context).loggedInUser;
          var blockedMembers = List<String>.from(updateUser.blockedMembers);
          blockedMembers.add(widget.userModel.sevaUserID);
          SevaCore.of(context).loggedInUser =
              updateUser.setBlockedMembers(blockedMembers);
        });
        break;

      case ACTION.UNBLOCK:
        Firestore.instance
            .collection("users")
            .document(SevaCore.of(context).loggedInUser.email)
            .updateData({
          'blockedMembers':
              FieldValue.arrayRemove([widget.userModel.sevaUserID])
        });
        Firestore.instance
            .collection("users")
            .document(widget.userModel.email)
            .updateData({
          'blockedBy': FieldValue.arrayRemove(
              [SevaCore.of(context).loggedInUser.sevaUserID])
        });

        setState(() {
          widget.isBlocked = !widget.isBlocked;
          var updateUser = SevaCore.of(context).loggedInUser;
          var blockedMembers = List<String>.from(updateUser.blockedMembers);
          blockedMembers.remove(widget.userModel.sevaUserID);
          SevaCore.of(context).loggedInUser =
              updateUser.setBlockedMembers(blockedMembers);
        });
        break;
    }
  }

  Future<String> blockMemberDialogView(BuildContext viewContext) async {
    return showDialog(
      context: viewContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(widget.isBlocked
              ? 'Unblock'
              : 'Block' + " ${widget.userModel.fullname.split(' ')[0]}."),
          content: new Text(widget.isBlocked
              ? '${widget.userModel.fullname.split(' ')[0]}  would be unblocked'
              : "${widget.userModel.fullname.split(' ')[0]} will no longer be available to send you messages and engage with the content you create"),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                "CANCEL",
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop("CANCEL");
              },
            ),
            new FlatButton(
              child: new Text(
                widget.isBlocked ? 'UNBLOCK' : 'BLOCK',
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                widget.isBlocked
                    ? Navigator.of(context).pop("UNBLOCK")
                    : Navigator.of(context).pop("BLOCK");
              },
            ),
          ],
        );
      },
    );
  }
}

class JobsCounter extends StatelessWidget {
  JobsCounter({
    Key key,
    this.jobs,
    this.hours,
  }) : super(key: key);
  final int jobs;
  final int hours;

  final BorderSide borderOnepx = BorderSide(
    color: Colors.grey[300],
    width: 1,
  );
  final BorderSide borderHalfpx = BorderSide(
    color: Colors.grey[300],
    width: 0.5,
  );

  final TextStyle title = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  final TextStyle subTitle = TextStyle(
    color: Colors.grey,
    fontSize: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 80,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(
                top: borderOnepx,
                right: borderHalfpx,
                bottom: borderOnepx,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$jobs\n',
                      style: title,
                    ),
                    TextSpan(
                      text: 'Jobs',
                      style: subTitle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            height: 80,
            decoration: BoxDecoration(
              border: Border(
                top: borderOnepx,
                left: borderHalfpx,
                bottom: borderOnepx,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$hours\n',
                      style: title,
                    ),
                    TextSpan(
                      text: 'Hours worked',
                      style: subTitle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UserProfileDetails extends StatefulWidget {
  final String title;
  final String details;
  const UserProfileDetails({
    Key key,
    this.title,
    this.details,
  }) : super(key: key);

  @override
  _UserProfileDetailsState createState() => _UserProfileDetailsState();
}

class _UserProfileDetailsState extends State<UserProfileDetails> {
  final int maxLength = 100;
  bool viewFullDetails = true;

  @override
  void initState() {
    viewFullDetails =
        widget.details != null ? widget.details.length <= maxLength : false;
    // if (widget.details.length <= maxLength) viewFullDetails = true;
    super.initState();
  }

  viewMore() {
    setState(() {
      viewFullDetails = !viewFullDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                // text: widget.details,
                text: viewFullDetails
                    ? widget.details
                    : widget.details.substring(0, maxLength),

                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              // TextSpan(text: ' ...'),
              TextSpan(
                text: widget.details.length > maxLength
                    ? viewFullDetails ? '  Less' : '  More'
                    : '',
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()..onTap = viewMore,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String rating;
  final Function message;
  final Function block;
  final Function report;
  final bool isBlocked;

  const ProfileHeader({
    Key key,
    this.name,
    this.email,
    this.rating,
    this.message,
    this.block,
    this.report,
    this.isBlocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StreamBuilder(
          stream: Firestore.instance
              .collection("reviews")
              .where("reviewed", isEqualTo: email)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            double r = 0;
            if (snapshot.data != null) {
              snapshot.data.documents.forEach((data) {
                r += double.parse((data['ratings']));
              });
            }

            return Container(
              child: Row(
                children: <Widget>[
                  SizedBox(width: 8),
                  Text(
                    r != null
                        ? r > 0
                            ? '${(r / snapshot.data.documents.length).toStringAsFixed(1)}'
                            : 'No ratings yet'
                        : 'Loading',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: r > 0 ? 16 : 14,
                    ),
                  ),
                  r > 0
                      ? Icon(
                          Icons.star,
                          color: Colors.blue,
                        )
                      : Container(),
                ],
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 8,
            top: 2,
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$name',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                // TextSpan(
                //   text: '\n$email',
                //   style: TextStyle(color: Colors.grey),
                // )
              ],
            ),
          ),
        ),
        Container(
          height: 25,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.message,
                ),
                onPressed: message,
                tooltip: 'Message',
                color: Theme.of(context).accentColor,
              ),
              IconButton(
                icon: Icon(Icons.block),
                onPressed: block,
                tooltip: isBlocked ? 'Unblock' : 'Block',
                color: Theme.of(context).accentColor,
              ),
              IconButton(
                icon: Icon(Icons.flag),
                onPressed: report,
                tooltip: 'Report member',
                color: Theme.of(context).accentColor,
              ),
            ],
          ),
        )
        // Text(
        //   '$email',
        //   style: TextStyle(color: Colors.grey),
        // )
        // Row(
        //   children: <Widget>[
        //     Icon(Icons.location_on, color: Colors.grey),
        //     RichText(
        //         text: TextSpan(children: <TextSpan>[
        //       TextSpan(
        //         text: 'Norway',
        //         style: TextStyle(color: Colors.black),
        //       ),
        //       TextSpan(
        //         text: ' 10:25am',
        //         style: TextStyle(color: Colors.grey),
        //       ),
        //     ])),
        //   ],
        // )
      ],
    );
  }
}

class ProfileImage extends StatelessWidget {
  final String image;
  final double radius;
  final String tag;
  const ProfileImage({
    Key key,
    this.image,
    this.tag,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: CircleAvatar(
        backgroundImage: NetworkImage(
          image ?? '',
        ),
        minRadius: radius,
      ),
    );
  }
}

// class FollowSection extends StatefulWidget {
//   _FollowSectionState createState() => _FollowSectionState();
// }

// class _FollowSectionState extends State<FollowSection> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         children: <Widget>[
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Container(
//                 padding: EdgeInsets.only(right: 15.0),
//                 child: Followers(),
//               ),
//               Container(
//                 padding: EdgeInsets.only(right: 15.0),
//                 child: Following(),
//               ),
//               Container(
//                 child: NumberOfPosts(),
//               ),
//             ],
//           ),
//           EditButton(),
//         ],
//       ),
//     );
//   }
// }

// class NameInfo extends StatefulWidget {
//   _NameInfoState createState() => _NameInfoState();
// }

// class _NameInfoState extends State<NameInfo> {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//         child: Container(
//       child: Text(
//         SevaCore.of(context).loggedInUser.fullname,
//         style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17.0),
//         // overflow: TextOverflow.ellipsis,
//         // maxLines: 2,
//       ),
//     )
//         // crossAxisAlignment: CrossAxisAlignment.center,
//         // children: <Widget>[
//         //   Center(
//         //     child: Text("data"),
//         //   ),
//         // Text(

//         //   globals.fullname,
//         //   style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17.0),
//         //   overflow: TextOverflow.ellipsis,
//         //   maxLines: 2,
//         // ),
//         // ],
//         // ),
//         );
//   }
// }

// class Followers extends StatefulWidget {
//   _FollowersState createState() => _FollowersState();
// }

// class _FollowersState extends State<Followers> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         // mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Text(
//             '63',
//             style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.green,
//                 fontSize: 12.0),
//             textAlign: TextAlign.left,
//             overflow: TextOverflow.ellipsis,
//             maxLines: 2,
//           ),
//           Text(
//             'Connections',
//             style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//                 fontSize: 12.0),
//             textAlign: TextAlign.left,
//             overflow: TextOverflow.ellipsis,
//             maxLines: 2,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Following extends StatefulWidget {
//   _FollowingState createState() => _FollowingState();
// }

// class _FollowingState extends State<Following> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         // mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Text(
//             '190',
//             style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.green,
//                 fontSize: 12.0),
//             textAlign: TextAlign.left,
//             overflow: TextOverflow.ellipsis,
//             maxLines: 2,
//           ),
//           Text(
//             'Following',
//             style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//                 fontSize: 12.0),
//             textAlign: TextAlign.left,
//             overflow: TextOverflow.ellipsis,
//             maxLines: 2,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class NumberOfPosts extends StatefulWidget {
//   _NumberOfPostsState createState() => _NumberOfPostsState();
// }

// class _NumberOfPostsState extends State<NumberOfPosts> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         // mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Text(
//             '90',
//             style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.green,
//                 fontSize: 12.0),
//             textAlign: TextAlign.left,
//             overflow: TextOverflow.ellipsis,
//             maxLines: 2,
//           ),
//           Text(
//             'Posts',
//             style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//                 fontSize: 12.0),
//             textAlign: TextAlign.left,
//             overflow: TextOverflow.ellipsis,
//             maxLines: 2,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class EditButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         children: <Widget>[
//           Container(
//             padding: EdgeInsets.only(top: 5.0),
//             height: 30.0,
//             child: ButtonTheme(
//               minWidth: 206.0,
//               child: RaisedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ProfileEdit()),
//                   );
//                 },
//                 textColor: Colors.white,
//                 color: Colors.blue,
//                 child: Text(
//                   'EDIT',
//                   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.0),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TaskButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         child: FlatButton(
//             onPressed: () {
//               //     Navigator.push(
//               //   context,
//               //   MaterialPageRoute(builder: (context) => MyTasksView()),
//               // );
//             },
//             color: Colors.white70,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 Text('My Tasks'),
//                 Icon(Icons.keyboard_arrow_right, size: 24.0),
//               ],
//             )));
//   }
// }

// class HoursExchangeButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         child: FlatButton(
//             onPressed: () {
//               //     Navigator.push(
//               //   context,
//               //   MaterialPageRoute(builder: (context) => MyTasksView()),
//               // );
//             },
//             color: Colors.white70,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 Text('My Hours and Exchanges'),
//                 Icon(Icons.keyboard_arrow_right, size: 24.0),
//               ],
//             )));
//   }
// }

// Color _getChipColor() {
//   List colors = [
//     Colors.red,
//     Colors.pink,
//     Colors.purple,
//     Colors.deepPurple,
//     Colors.indigo,
//     Colors.blue,
//     Colors.lightBlue,
//     Colors.cyan,
//     Colors.teal,
//     Colors.green,
//     Colors.lightGreen,
//     Colors.lime,
//     Colors.amber,
//     Colors.orange,
//     Colors.deepOrange,
//     Colors.brown,
//     Colors.blueGrey,
//     Colors.redAccent,
//   ];

//   Random random = Random();
//   int selected = random.nextInt(18);

//   return colors[selected];
// }

// Widget getChipWidgets(List<dynamic> strings, BuildContext context) {
//   return Wrap(
//       spacing: 5.0,
//       alignment: WrapAlignment.start,
//       children: strings
//           .map((item) =>
//           ActionChip(
//                 padding: EdgeInsets.all(3.0),
//                 onPressed: () {},
//                 backgroundColor: Theme.of(context).accentColor,
//                 label: Text(
//                   item,
//                   style: TextStyle(
//                     color: FlavorConfig.values.buttonTextColor,
//                   ),
//                 ),
//               ))
//           .toList());
// }

enum ACTION { BLOCK, UNBLOCK }

class SkillAndInterestBuilder extends StatelessWidget {
  final List skills;
  final List interests;

  const SkillAndInterestBuilder({Key key, this.skills, this.interests})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 25,
          ),
          child: Text(
            'Skills',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          height: 40,
          child: skills != null
              ? createLabels(skills) //snapshot.data['skills'])
              // ? getChipWidgets(snapshot.data['skills'], context)
              : Padding(
                  padding: EdgeInsets.all(5.0),
                ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 25,
          ),
          child: Text(
            'My Interests',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          height: 40,
          // padding: EdgeInsets.only(left: 25.0, right: 25.0),
          child: interests != null
              ? createLabels(interests) //(snapshot.data['interests'])
              // ? getChipWidgets(
              //     snapshot.data['interests'], context)
              : Padding(
                  padding: EdgeInsets.all(5.0),
                ),
        ),
      ],
    );
  }

  Widget createLabels(List data) {
    int length = data.length;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 22.5,
        vertical: 5,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 2.5,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            color: Color(0xFFFa3ebff).withOpacity(0.3),
            alignment: Alignment.center,
            child: Text(
              data[index],
              style: TextStyle(
                color: Color(0xFFF0ca5f2),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
