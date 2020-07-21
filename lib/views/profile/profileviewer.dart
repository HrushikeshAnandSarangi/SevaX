import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sevaexchange/components/pdf_screen.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/reported_members/pages/report_member_page.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

//TODO update bio and remove un-necessary stuff

class ProfileViewer extends StatefulWidget {
  final String userEmail;
  final String timebankId;
  final String entityName;
  final bool isFromTimebank;
  //UserModel userModel;
  //bool isBlocked = false;

  ProfileViewer({
    this.userEmail,
    @required this.timebankId,
    this.isFromTimebank,
    this.entityName,
  })  : assert(userEmail != null),
//        assert(entityName != null),
        assert(timebankId != null);
//        assert(isFromTimebank != null);
  @override
  State<StatefulWidget> createState() {
    return ProfileViewerState();
  }
}

class ProfileViewerState extends State<ProfileViewer> {
  UserModel user;
  bool isBlocked;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("**********************${widget.timebankId}");

    String loggedInEmail = SevaCore.of(context).loggedInUser.email;
    UserModel userData = SevaCore.of(context).loggedInUser;

    return Scaffold(
      backgroundColor: Colors.white,
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
              user = UserModel.fromMap(snapshot.data.data);

              if (user == null) {
                print("User details not fouund");
                Navigator.pop(context);
                return Offstage();
              }

              if (user.fullname == null) {
                user.fullname = defaultUsername;
              }

              if (user.photoURL == null) {
                user.photoURL = defaultUserImageURL;
              }

              isBlocked = user.blockedBy.contains(userData.sevaUserID);
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
                            isBlocked: isBlocked,
                            message: widget.userEmail == loggedInEmail ||
                                    isBlocked
                                ? null
                                : () => onMessageClick(
                                    user, SevaCore.of(context).loggedInUser),
                            block: widget.userEmail == loggedInEmail
                                ? null
                                : onBlockClick,
                            report: widget.userEmail == loggedInEmail
                                ? null
                                : () => onReportClick(
                                      reporterUserModel: userData,
                                      reportedUserModel: user,
                                    ),
                            reportStatus: getReportedStatus(
                              timebankId: widget.timebankId,
                              currentUserId:
                                  SevaCore.of(context).loggedInUser.sevaUserID,
                              profileUserId: user.sevaUserID,
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
                        title: AppLocalizations.of(context)
                                .translate('profile', 'about') +
                            ' ${snapshot.data['fullname']}',
                        details: snapshot.data['bio'] ?? '',
                      ),
                    ),
                    SkillAndInterestBuilder(
                      skills: snapshot.data['skills'],
                      interests: snapshot.data['interests'],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 25,
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate('cv', 'cv'),
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w700),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        openPdfViewer(
                            documentName: userData.cvName ?? "cv name",
                            documentUrl: userData.cvUrl ?? "");
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22.5,
                          vertical: 5,
                        ),
                        child: Container(
                          height: 40,
                          color: Color(0xFFFa3ebff).withOpacity(0.3),
                          alignment: Alignment.center,
                          child: Text(
                            userData.cvName ?? "CV Name",
                            style: TextStyle(
                              color: Color(0xFFF0ca5f2),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      child: StreamBuilder<List<RequestModel>>(
                        stream: FirestoreManager.getCompletedRequestStream(
                            userEmail: widget.userEmail,
                            userId: user.sevaUserID),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          List<RequestModel> requestList = snapshot.data;
                          double toltalHoursWorked = 0;

                          toltalHoursWorked = getTotalWorkedHours(requestList);

                          return JobsCounter(
                            jobs: requestList.length,
                            hours: toltalHoursWorked.toInt(),
                          );
                        },
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
                              text: AppLocalizations.of(context)
                                      .translate('profile', 'availability') +
                                  '\n',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                            // TextSpan(text: '', style: TextStyle(height: 10)),
                            TextSpan(
                              text: AppLocalizations.of(context)
                                  .translate('profile', 'availabilityas'),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Future<void> onMessageClick(UserModel user, UserModel loggedInUser) async {
    ParticipantInfo sender = ParticipantInfo(
      id: loggedInUser.sevaUserID,
      name: loggedInUser.fullname,
      photoUrl: loggedInUser.photoURL,
      type: ChatType.TYPE_PERSONAL,
    );

    ParticipantInfo reciever = ParticipantInfo(
      id: user.sevaUserID,
      name: user.fullname,
      photoUrl: user.photoURL,
      type: ChatType.TYPE_PERSONAL,
    );
    createAndOpenChat(
      context: context,
      timebankId: widget.timebankId,
      communityId: loggedInUser.currentCommunity,
      sender: sender,
      reciever: reciever,
      isFromRejectCompletion: false,
    );
  }

  Future<File> createFileOfPdfUrl(
      String documentUrl, String documentName) async {
    final url = documentUrl;
    final filename = documentName;
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  void openPdfViewer({String documentUrl, String documentName}) {
    createFileOfPdfUrl(documentUrl, documentName).then((f) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFScreen(
                  docName: documentName,
                  pathPDF: f.path,
                  isFromFeeds: false,
                  pdfUrl: documentUrl,
                )),
      );
    });
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

  void onReportClick(
      {UserModel reportedUserModel, UserModel reporterUserModel}) {
    Navigator.of(context)
        .push(
      ReportMemberPage.route(
          reportedUserModel: reportedUserModel,
          reportingUserModel: reporterUserModel,
          timebankId: widget.timebankId,
          isFromTimebank: widget.isFromTimebank,
          entityName: widget.entityName),
    )
        .then((_) {
      setState(() {});
    });
    // showDialog(
    //   context: context,
    //   builder: (BuildContext viewContext) {
    //     // return object of type Dialog
    //     return AlertDialog(
    //       title: Text('Report Member?'),
    //       content: Text(
    //         'Do you want to report this member to admin?',
    //       ),
    //       actions: <Widget>[
    //         FlatButton(
    //           padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
    //           color: Theme.of(context).accentColor,
    //           textColor: FlavorConfig.values.buttonTextColor,
    //           child: Text(
    //             'Report',
    //             style: TextStyle(
    //               fontSize: dialogButtonSize,
    //             ),
    //           ),
    //           onPressed: () {
    //             print(reportedUserModel.sevaUserID);
    //             Report report = Report(
    //               reporterId: reporterUserModel.sevaUserID,
    //               attachment: "some url",
    //               message: "test message",
    //               reporterImage: reporterUserModel.photoURL,
    //               reporterName: reporterUserModel.fullname,
    //             );
    //             Firestore.instance
    //                 .collection('reported_users_list')
    //                 .document(
    //                     "${reportedUserModel.sevaUserID}*${widget.timebankId}")
    //                 .setData({
    //               "reportedId": reportedUserModel.sevaUserID,
    //               "timebankId": widget.timebankId,
    //               "reportedUserName": reportedUserModel.fullname,
    //               "reportedUserImage": reportedUserModel.photoURL,
    //               "reporterId": FieldValue.arrayUnion(
    //                 [reporterUserModel.sevaUserID],
    //               ),
    //               "reports": FieldValue.arrayUnion([report.toMap()])
    //             }, merge: true).then((result) => {
    //                       Navigator.pop(viewContext),
    //                       Navigator.of(context).pop()
    //                     });
    //           },
    //         ),
    //         FlatButton(
    //           child: Text(
    //             'Cancel',
    //             style: TextStyle(fontSize: dialogButtonSize, color: Colors.red),
    //           ),
    //           onPressed: () {
    //             Navigator.of(viewContext).pop();
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  void blockMember(ACTION action) {
    switch (action) {
      case ACTION.BLOCK:
        Firestore.instance
            .collection("users")
            .document(SevaCore.of(context).loggedInUser.email)
            .updateData({
          'blockedMembers': FieldValue.arrayUnion([user.sevaUserID])
        });
        Firestore.instance.collection("users").document(user.email).updateData({
          'blockedBy': FieldValue.arrayUnion(
              [SevaCore.of(context).loggedInUser.sevaUserID])
        });
        setState(() {
          isBlocked = !isBlocked;
          var updateUser = SevaCore.of(context).loggedInUser;
          var blockedMembers = List<String>.from(updateUser.blockedMembers);
          blockedMembers.add(user.sevaUserID);
          SevaCore.of(context).loggedInUser =
              updateUser.setBlockedMembers(blockedMembers);
        });
        break;

      case ACTION.UNBLOCK:
        Firestore.instance
            .collection("users")
            .document(SevaCore.of(context).loggedInUser.email)
            .updateData({
          'blockedMembers': FieldValue.arrayRemove([user.sevaUserID])
        });
        Firestore.instance.collection("users").document(user.email).updateData({
          'blockedBy': FieldValue.arrayRemove(
              [SevaCore.of(context).loggedInUser.sevaUserID])
        });

        setState(() {
          isBlocked = !isBlocked;
          var updateUser = SevaCore.of(context).loggedInUser;
          var blockedMembers = List<String>.from(updateUser.blockedMembers);
          blockedMembers.remove(user.sevaUserID);
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
          title: new Text(isBlocked
              ? AppLocalizations.of(context).translate('profile', 'unblock')
              : AppLocalizations.of(context).translate('profile', 'block') +
                  " ${user.fullname.split(' ')[0]}."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text(isBlocked
                  ? '${user.fullname.split(' ')[0]} ' +
                      AppLocalizations.of(context)
                          .translate('profile', 'wouldbeunblocked')
                  : "${user.fullname.split(' ')[0]} " +
                      AppLocalizations.of(context)
                          .translate('profile', 'nolonger')),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  new FlatButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: new Text(
                      isBlocked
                          ? AppLocalizations.of(context)
                              .translate('profile', 'unblock')
                          : AppLocalizations.of(context)
                              .translate('profile', 'block'),
                      style: TextStyle(
                          fontSize: dialogButtonSize, fontFamily: 'Europa'),
                    ),
                    onPressed: () {
                      isBlocked
                          ? Navigator.of(context).pop("UNBLOCK")
                          : Navigator.of(context).pop("BLOCK");
                    },
                  ),
                  new FlatButton(
                    child: new Text(
                      AppLocalizations.of(context)
                          .translate('shared', 'cancel'),
                      style: TextStyle(
                          fontSize: dialogButtonSize,
                          fontFamily: 'Europa',
                          color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop("CANCEL");
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  double getTotalWorkedHours(List<RequestModel> requestList) {
    double toltalHoursWorked = 0;
    requestList.forEach((requestModel) {
      TransactionModel transmodel =
          requestModel.transactions.firstWhere((transaction) {
        return transaction.to == user.sevaUserID;
      });
      if (transmodel != null && transmodel.credits != null) {
        toltalHoursWorked = toltalHoursWorked + transmodel.credits;
      }
    });
    return toltalHoursWorked;
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
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$jobs\n',
                      style: title,
                    ),
                    TextSpan(
                      text: AppLocalizations.of(context)
                          .translate('profile', 'jobs'),
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
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: hours == null ? '0\n' : '$hours\n' ?? '0\n',
                      style: title,
                    ),
                    TextSpan(
                      text: AppLocalizations.of(context)
                          .translate('profile', 'hoursworked'),
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
                    ? viewFullDetails
                        ? ' ' +
                            AppLocalizations.of(context)
                                .translate('profile', 'less')
                        : '  ' +
                            AppLocalizations.of(context)
                                .translate('profile', 'more')
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
  final Future<bool> reportStatus;

  const ProfileHeader({
    Key key,
    this.name,
    this.email,
    this.rating,
    this.message,
    this.block,
    this.report,
    this.isBlocked,
    this.reportStatus,
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
                            : AppLocalizations.of(context)
                                .translate('profile', 'noratingyet')
                        : AppLocalizations.of(context)
                            .translate('profile', 'loading_n'),
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
                tooltip: AppLocalizations.of(context)
                    .translate('profile', 'message'),
                color: Theme.of(context).accentColor,
              ),
              IconButton(
                icon: Icon(
                  Icons.block,
                ),
                onPressed: block,
                tooltip: isBlocked
                    ? AppLocalizations.of(context)
                        .translate('profile', 'unblock')
                    : AppLocalizations.of(context)
                        .translate('profile', 'block'),
                color: isBlocked ? Colors.red : Theme.of(context).accentColor,
              ),
              FutureBuilder<bool>(
                  future: reportStatus,
                  builder: (context, snapshot) {
                    log(snapshot.data.toString());
                    return IconButton(
                      icon: Icon(Icons.flag),
                      onPressed: !(snapshot.data ?? true) ? report : null,
                      tooltip: AppLocalizations.of(context)
                          .translate('profile', 'report_member'),
                      color: !(snapshot.data ?? true)
                          ? Theme.of(context).accentColor
                          : Colors.grey,
                    );
                  }),
            ],
          ),
        )
      ],
    );
  }
}

class CompletedList extends StatelessWidget {
  final List<RequestModel> requestList;

  //List<UserModel> userList = [];

  final UserModel userModel;

  CompletedList({
    this.requestList,
    this.userModel,
  }); //  requestStream = FirestoreManager.getCompletedRequestStream(

  @override
  Widget build(BuildContext context) {
    if (requestList.length == 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Center(
          child: Text(
              userModel.fullname +
                  ' ' +
                  AppLocalizations.of(context)
                      .translate('profile', 'not_completed'),
              textAlign: TextAlign.center),
        ),
      );
    }
    return Column(
      children: <Widget>[
        ListView.builder(
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: requestList.length,
          itemBuilder: (context, index) {
            RequestModel model = requestList.elementAt(index);

            return Card(
              child: ListTile(
                title: Text(model.title),
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(userModel.photoURL ?? defaultUserImageURL),
                ),
                trailing: () {
                  TransactionModel transmodel =
                      model.transactions.firstWhere((transaction) {
                    return transaction.to == userModel.sevaUserID;
                  });
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('${transmodel.credits}'),
                      Text(
                          AppLocalizations.of(context)
                              .translate('profile', 'seva_credits_ad'),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          )),
                    ],
                  );
                }(),
                subtitle: Text('${userModel.fullname}'),
              ),
            );
          },
        ),
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
          image ?? defaultUserImageURL,
        ),
        minRadius: radius,
      ),
    );
  }
}

enum ACTION { BLOCK, UNBLOCK }

class SkillAndInterestBuilder extends StatelessWidget {
  final List skills;
  final List interests;

  const SkillAndInterestBuilder({Key key, this.skills, this.interests})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //altered code
    return FutureBuilder(
        future: FirestoreManager.getUserSkillsInterests(
            skillsIdList: this.skills, interestsIdList: this.interests),
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 25,
                ),
                child: Text(
                  AppLocalizations.of(context).translate('skills', 'title'),
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                height: 40,
                child: snapshot.data != null &&
                        this.skills != null &&
                        this.skills.length != 0
                    ? createLabels(snapshot.data['skills'])
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
                  AppLocalizations.of(context).translate('interests', 'title'),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                height: 40,
                child: snapshot.data != null &&
                        this.interests != null &&
                        this.interests.length != 0
                    ? createLabels(snapshot.data['interests'])
                    : Padding(
                        padding: EdgeInsets.all(5.0),
                      ),
              ),
            ],
          );
        });
  }

  Widget createLabels(List data) {
    var length = data == null ? 0 : data.length;
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
              data[index].toString(),
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

Future<bool> getReportedStatus({
  String timebankId,
  String currentUserId,
  String profileUserId,
}) async {
  bool flag = false;
  QuerySnapshot query = await Firestore.instance
      .collection('reported_users_list')
      .where("reportedId", isEqualTo: profileUserId)
      .where("reporterIds", arrayContains: currentUserId)
      // .where("timebankIds", arrayContains: timebankId)
      .getDocuments();
  query.documents.forEach((data) {
    if (data.data['timebankIds'].contains(timebankId)) {
      flag = true;
    } else {
      flag = false;
    }
  });

  return flag;
}
