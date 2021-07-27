import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sevaexchange/components/pdf_screen.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/reported_members/pages/report_member_page.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

//TODO update bio and remove un-necessary stuff

class ProfileViewer extends StatefulWidget {
  final String userEmail;
  final String userId;
  final String timebankId;
  final String entityName;
  final bool isFromTimebank;

  //UserModel userModel;
  //bool isBlocked = false;

  ProfileViewer({
    this.userEmail,
    this.timebankId,
    this.isFromTimebank,
    this.entityName,
    this.userId,
  }) :
        //assert(userEmail != null),
//        assert(entityName != null),
        assert(timebankId != null);

//        assert(isFromTimebank != null);
  @override
  State<StatefulWidget> createState() {
    return ProfileViewerState();
  }
}

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

class ProfileViewerState extends State<ProfileViewer> {
  UserModel user;
  bool isBlocked;

  @override
  void initState() {
    super.initState();
  }

  TRscore(num trustworthinessscore, num reliabilityscore) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 80,
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SmoothStarRating(
                      allowHalfRating: true,
                      isReadOnly: true,
                      onRated: (v) {},
                      starCount: 5,
                      rating: trustworthinessscore != null
                          ? trustworthinessscore
                          : 0,
                      size: 28.0,
                      filledIconData: Icons.star,
                      halfFilledIconData: Icons.star_half,
                      color: Colors.yellow,
                      borderColor: Colors.yellow,
                      spacing: 0.0),
                  Text(
                    S.of(context).trustworthiness,
                    style: subTitle,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            height: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SmoothStarRating(
                    allowHalfRating: true,
                    isReadOnly: true,
                    onRated: (v) {},
                    starCount: 5,
                    rating: reliabilityscore != null ? reliabilityscore : 0,
                    size: 28.0,
                    filledIconData: Icons.star,
                    halfFilledIconData: Icons.star_half,
                    color: Colors.yellow,
                    borderColor: Colors.yellow,
                    spacing: 0.0),
                Text(
                  S.of(context).reliabilitysocre,
                  style: subTitle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String loggedInEmail = SevaCore.of(context).loggedInUser.email;
    UserModel userData = SevaCore.of(context).loggedInUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<UserModel>(
        stream: widget.userEmail == null
            ? getUserForIdStream(sevaUserId: widget.userId)
            : getUserForEmailStream(widget.userEmail),
        builder:
            (BuildContext firebasecontext, AsyncSnapshot<UserModel> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return LoadingIndicator();
            default:
              user = snapshot.data;

              if (user == null) {
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
                            image: snapshot.data.photoURL,
                            tag: widget.userEmail ?? widget.userId,
                            radius: 50,
                          ),
                          SizedBox(width: 20),
                          ProfileHeader(
                            rating: '4.5',
                            name: user.fullname,
                            email: user.email,
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
                        title:
                            S.of(context).about + ' ${snapshot.data.fullname}',
                        details: snapshot.data.bio ?? '',
                      ),
                    ),
                    SkillAndInterestBuilder(
                      skills: snapshot.data.skills,
                      interests: snapshot.data.interests,
                    ),
                    Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: TRscore(
                            user.trustworthinessscore, user.reliabilityscore)),
                    // '$' donated and 'Items' donated
                    // SizedBox(
                    //   height: 20,
                    // ),
                    // Padding(
                    //     padding:
                    //         EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    //     child: GoodsAndAmountDonations(
                    //         userId: user.sevaUserID,
                    //         isGoods: false,
                    //         isTimeBank: false,
                    //         onTap: () {})),
                    // SizedBox(
                    //   height: 15,
                    // ),
                    // Padding(
                    //     padding:
                    //         EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    //     child: GoodsAndAmountDonations(
                    //         userId: user.sevaUserID,
                    //         isGoods: true,
                    //         isTimeBank: false,
                    //         onTap: () {})),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 0),
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
                            return LoadingIndicator();
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
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 25,
                      ),
                      child: Text(
                        S.of(context).cv_resume,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (user.cvUrl != null)
                          openPdfViewer(
                              documentName: user.cvName ?? "cv name",
                              documentUrl: user.cvUrl ?? "");
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.attachment,
                                color: Colors.black54,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                user.cvName ?? S.of(context).cv_not_available,
                                style: TextStyle(
                                  color: Color(0xFFF0ca5f2),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: S.of(context).availablity + '\n',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                            // TextSpan(text: '', style: TextStyle(height: 10)),
                            TextSpan(
                              text: S.of(context).available_as_needed,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20)
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

  void openPdfViewer({String documentUrl, String documentName}) {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    progressDialog.show();

    createFileOfPdfUrl(documentUrl, documentName).then((f) {
      progressDialog.hide();

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
  }

  void blockMember(ACTION action) {
    switch (action) {
      case ACTION.BLOCK:
        CollectionRef.users
            .doc(SevaCore.of(context).loggedInUser.email)
            .update({
          'blockedMembers': FieldValue.arrayUnion([user.sevaUserID])
        });
        CollectionRef.users.doc(user.email).update({
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
        CollectionRef.users
            .doc(SevaCore.of(context).loggedInUser.email)
            .update({
          'blockedMembers': FieldValue.arrayRemove([user.sevaUserID])
        });
        CollectionRef.users.doc(user.email).update({
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
          title: Text(isBlocked
              ? S.of(context).unblock
              : S.of(context).block + " ${user.fullname.split(' ')[0]}."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                isBlocked
                    ? '${user.fullname.split(' ')[0]} ' +
                        S.of(context).would_be_unblocked
                    : "${user.fullname.split(' ')[0]} " +
                        S.of(context).chat_block_warning,
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  CustomTextButton(
                    shape: StadiumBorder(),
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      isBlocked ? S.of(context).unblock : S.of(context).block,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: dialogButtonSize,
                        fontFamily: 'Europa',
                      ),
                    ),
                    onPressed: () {
                      isBlocked
                          ? Navigator.of(context).pop("UNBLOCK")
                          : Navigator.of(context).pop("BLOCK");
                    },
                  ),
                  CustomTextButton(
                    child: Text(
                      S.of(context).cancel,
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
                top: BorderSide(
                  color: Colors.white,
                  width: 0,
                ),
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
                      text: S.of(context).exchanges,
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
                top: BorderSide(
                  color: Colors.white,
                  width: 0,
                ),
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
                      text: S.of(context).hours_worked,
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

  void viewMore() {
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
                        ? ' ' + S.of(context).less
                        : '  ' + S.of(context).more
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
        StreamBuilder<QuerySnapshot>(
          stream: CollectionRef.reviews
              .where("reviewed", isEqualTo: email)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            double r = 0;
            if (snapshot.data != null) {
              snapshot.data.docs.forEach((data) {
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
                            ? '${(r / snapshot.data.docs.length).toStringAsFixed(1)}'
                            : S.of(context).no_ratings_yet
                        : S.of(context).loading,
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
                tooltip: S.of(context).message,
                color: Theme.of(context).accentColor,
              ),
              IconButton(
                icon: Icon(
                  Icons.block,
                ),
                onPressed: block,
                tooltip:
                    isBlocked ? S.of(context).unblock : S.of(context).block,
                color: isBlocked ? Colors.red : Theme.of(context).accentColor,
              ),
              FutureBuilder<bool>(
                  future: reportStatus,
                  builder: (context, snapshot) {
                    log(snapshot.data.toString());
                    return IconButton(
                      icon: Icon(Icons.flag),
                      onPressed: !(snapshot.data ?? true) ? report : null,
                      tooltip: S.of(context).report_members,
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
              userModel.fullname + ' ' + S.of(context).not_completed_any_tasks,
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
                      Text(S.of(context).seva_credits,
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
            skillsIdList: this.skills,
            interestsIdList: this.interests,
            languageCode: SevaCore.of(context).loggedInUser.language),
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
                  S.of(context).skills,
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
                  S.of(context).interests,
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
  QuerySnapshot query = await CollectionRef.reportedUsersList
      .where("reportedId", isEqualTo: profileUserId)
      .where("reporterIds", arrayContains: currentUserId)
      // .where("timebankIds", arrayContains: timebankId)
      .get();
  query.docs.forEach((data) {
    if (data.data()['timebankIds'].contains(timebankId)) {
      flag = true;
    } else {
      flag = false;
    }
  });

  return flag;
}
