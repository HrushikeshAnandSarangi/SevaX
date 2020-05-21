import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart'
    as FirestoreRequestManager;
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../flavor_config.dart';
import '../core.dart';

class RequestParticipantsView extends StatefulWidget {
  RequestModel requestModel;

  RequestParticipantsView({@required this.requestModel});

  @override
  _RequestParticipantsViewState createState() =>
      _RequestParticipantsViewState(requestModel);
}

class _RequestParticipantsViewState extends State<RequestParticipantsView> {
  List<String> acceptors;
  List<String> approvedMembers;
  List<String> newList;
  RequestModel requestModel;
  HashMap<String, AcceptorItem> filteredList = HashMap();

  _RequestParticipantsViewState(RequestModel _requestModel) {
    requestModel = _requestModel;
  }

  static String ACCEPTED;
  static String APPROVED;

  @override
  void initState() {
    super.initState();
    FirestoreRequestManager.getRequestStreamById(requestId: requestModel.id)
        .listen((_requestModel) {
      requestModel = _requestModel;
      try {
        setState(() {});
      } on Exception {
        print("Exception caught in request_participants_view");
      }
    });
  }

  Future<dynamic> getUserDetails({String memberEmail}) async {
    var user = await Firestore.instance
        .collection("users")
        .document(memberEmail)
        .get();

    return user.data;
  }

  @override
  Widget build(BuildContext context) {

    ACCEPTED = AppLocalizations.of(context).translate('requests','accepted');
    APPROVED = AppLocalizations.of(context).translate('requests','approved');
    return list;
  }

  Widget get list {
    var futures = <Future>[];
    futures.clear();
    acceptors = requestModel.acceptors ?? [];
    approvedMembers = requestModel.approvedUsers ?? [];
    newList = acceptors + approvedMembers;

    List<String> result = LinkedHashSet<String>.from(newList).toList();

    result.forEach((email) {
      futures.add(getUserDetails(memberEmail: email));
    });
    return FutureBuilder(
        future: Future.wait(futures),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasError) {
            return Text('${AppLocalizations.of(context).translate('requests','error')} ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.length == 0) {
            return Center(
              child: Text(AppLocalizations.of(context).translate('requests','no_pending')),
            );
          }
          var snap = snapshot.data.map((f) {
            return UserModel.fromDynamic(f);
          }).toList();

          snap.sort((a, b) =>
              a.fullname.toLowerCase().compareTo(b.fullname.toLowerCase()));

          return ListView(
            children: <Widget>[
              ...snap.map((userModel) {
                // return Text(f['fullname']);

                UserRequestStatusType status;
                status =
                    getUserRequestStatusType(userModel.email, requestModel);

                return makeUserWidget(userModel, context, status);
              }).toList()
            ],
          );
        });
  }

  Widget makeUserWidget(
      UserModel userModel, BuildContext context, UserRequestStatusType status) {
    return Container(
        margin: EdgeInsets.fromLTRB(30, 20, 30, 10),
        child: Stack(children: <Widget>[
          getUserCard(userModel, context: context, statusType: status),
          getUserThumbnail(userModel.photoURL),
        ]));
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
                image: NetworkImage(photoURL ??
                    "https://www.itl.cat/pngfile/big/43-430987_cute-profile-images-pic-for-whatsapp-for-boys.jpg"))));
  }

  Widget getUserCard(UserModel userModel,
      {BuildContext context, UserRequestStatusType statusType}) {
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
                    child: Text(
                      userModel.fullname,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Icon(

                  //   Icons.chat_bubble,
                  //   color: Colors.blueGrey,
                  //   size: 35,
                  // ),
                ],
              ),
              Expanded(
                child: Text(
                  userModel.bio ?? AppLocalizations.of(context).translate('requests','updated_bio'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
              ifUserIsNotApproved(userModel)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          height: 40,
                          padding: EdgeInsets.only(bottom: 10),
                          child: RaisedButton(
                            shape: StadiumBorder(),
                            color: Colors.indigo,
                            textColor: Colors.white,
                            elevation: 5,
                            onPressed: () async {
                              approveMemberForVolunteerRequest(
                                model: requestModel,
                                notificationId: Utils.getUuid(),
                                user: userModel,
                                context: context,
                              );
                            },
                            child:  Text(AppLocalizations.of(context).translate('requests','approve'),
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 40,
                          padding: EdgeInsets.only(bottom: 10),
                          child: RaisedButton(
                            shape: StadiumBorder(),
                            color: Colors.redAccent,
                            textColor: Colors.white,
                            elevation: 5,
                            onPressed: () async {
                              declineRequestedMember(
                                  model: requestModel,
                                  notificationId: "sampleID",
                                  user: userModel);
                            },
                            child:  Text(AppLocalizations.of(context).translate('requests','reject'),
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          height: 40,
                          padding: EdgeInsets.only(bottom: 10),
                          child: RaisedButton(
                            shape: StadiumBorder(),
                            color: Colors.green,
                            textColor: Colors.white,
                            elevation: 5,
                            onPressed: () {
                              print("approved");
                            },
                            child: Text(AppLocalizations.of(context).translate('requests','approved'),
                                style: TextStyle(
                                  fontSize: 12,
                                )),
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

  bool ifUserIsNotApproved(UserModel user) {
    return !requestModel.approvedUsers.contains(user.email);
  }

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

// crate dialog for approval or rejection
  Future showDialogForApprovalOfRequest({
    BuildContext context,
    UserModel userModel,
    RequestModel requestModel,
    String notificationId,
  }) {
    return showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            content: Form(
              //key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _getCloseButton(viewContext),
                  Container(
                    height: 70,
                    width: 70,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(userModel.photoURL),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      userModel.fullname == null
                          ? AppLocalizations.of(context).translate('requests','Anonymous')
                          : userModel.fullname,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Text(
                      userModel.email == null
                          ? AppLocalizations.of(context).translate('requests','no_updated')
                          : userModel.email,
                    ),
                  ),
                  if (userModel.bio != null)
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Text(
                        "${AppLocalizations.of(context).translate('requests','about')} ${userModel.fullname}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      userModel.bio == null
                          ? AppLocalizations.of(context).translate('notifications','bio_notupdated')
                          : userModel.bio,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Center(
                    child: Text(
                        "${AppLocalizations.of(context).translate('requests','by_approving')}, ${userModel.fullname} ${AppLocalizations.of(context).translate('requests','my_requests')}",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: FlavorConfig.values.theme.primaryColor,
                          child: Text(
                            AppLocalizations.of(context).translate('requests','approve'),
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Europa'),
                          ),
                          onPressed: () async {
                            // Once approved
                            approveMemberForVolunteerRequest(
                              model: requestModel,
                              notificationId: notificationId,
                              user: userModel,
                            );
                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.0),
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            AppLocalizations.of(context).translate('requests','decline'),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Europa',
                            ),
                          ),
                          onPressed: () async {
                            // request declined

                            declineRequestedMember(
                                model: requestModel,
                                notificationId: notificationId,
                                user: userModel);

                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  void declineRequestedMember({
    RequestModel model,
    UserModel user,
    String notificationId,
  }) {
    List<String> acceptedUsers = model.acceptors ?? [];
    Set<String> usersSet = acceptedUsers.toSet();

    usersSet.remove(user.email);
    model.acceptors = usersSet.toList();

    rejectAcceptRequest(
      requestModel: model,
      rejectedUserId: user.sevaUserID,
      notificationId: notificationId,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
  }

  void approveMemberForVolunteerRequest({
    RequestModel model,
    UserModel user,
    String notificationId,
    @required BuildContext context,
  }) {
    List<String> approvedUsers = model.approvedUsers;
    Set<String> acceptedSet = approvedUsers.toSet();

    acceptedSet.add(user.email);
    model.approvedUsers = acceptedSet.toList();

    if (model.numberOfApprovals <= model.approvedUsers.length)
      model.accepted = true;
    approveAcceptRequest(
        requestModel: model,
        approvedUserId: user.sevaUserID,
        notificationId: notificationId,
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        directToMember: true);
  }

  Widget _getCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        alignment: FractionalOffset.topRight,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'lib/assets/images/close.png',
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Decoration get notificationDecoration => ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        shadows: shadowList,
      );

  List<BoxShadow> get shadowList => [shadow];

  BoxShadow get shadow {
    return BoxShadow(
      color: Colors.black.withAlpha(10),
      spreadRadius: 2,
      blurRadius: 3,
    );
  }

  Widget get notificationShimmer {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white.withAlpha(80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: ListTile(
            title: Container(height: 10, color: Colors.white),
            subtitle: Container(height: 10, color: Colors.white),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
            ),
          ),
        ),
        baseColor: Colors.black.withAlpha(50),
        highlightColor: Colors.white.withAlpha(50),
      ),
    );
  }

  String getUserRequestTypeTitle() {
    return "";
  }

  UserRequestStatusType getUserRequestStatusType(
      String sevaUserEmail, RequestModel requestModel) {
    if (requestModel.acceptors.contains(sevaUserEmail)) {
      return UserRequestStatusType.ACCEPTED;
    } else if (requestModel.approvedUsers.contains(sevaUserEmail)) {
      return UserRequestStatusType.APPROVED;
    }
  }
}

Future<List<UserModel>> getRequestStatus({
  @required String requestId,
}) async {
  Firestore.instance.collection('requests').document(requestId).get().then(
    (requestDetails) async {
      var futures = <Future>[];
      RequestModel model = RequestModel.fromMap(
        requestDetails.data,
      );

      model.approvedUsers.forEach((membersId) {
        futures.add(
          Firestore.instance
              .collection("users")
              .document(membersId)
              .get()
              .then((onValue) {
            return onValue;
          }),
        );
      });

      return Future.wait(futures).then((onValue) {
        for (int i = 0; i < model.approvedUsers.length; i++) {
          var user = UserModel.fromDynamic(onValue[i]);
          usersRequested.add(user);
        }
        return usersRequested;
      });
    },
  );
}

List<UserModel> usersRequested = List();

class AcceptorItem {
  final String email;
  final bool approved;

  AcceptorItem({this.email, this.approved});
}

enum UserRequestStatusType { ACCEPTED, APPROVED }
