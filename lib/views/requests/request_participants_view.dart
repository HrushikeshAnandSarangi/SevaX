import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/request/pages/borrow_request_participants.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart'
    as FirestoreRequestManager;
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/user_profile_image.dart';
import 'package:shimmer/shimmer.dart';

import '../core.dart';

class RequestParticipantsView extends StatefulWidget {
  final RequestModel requestModel;
  final TimebankModel? timebankModel;

  RequestParticipantsView({required this.requestModel, this.timebankModel});

  @override
  _RequestParticipantsViewState createState() =>
      _RequestParticipantsViewState();
}

class _RequestParticipantsViewState extends State<RequestParticipantsView> {
  List<String>? acceptors;
  List<String>? approvedMembers;
  List<String>? newList;
  RequestModel? requestModel;
  List<String>? oneToManyRequestAttenders;
  // RequestModel requestModel;
  HashMap<String, AcceptorItem> filteredList = HashMap();

  @override
  void initState() {
    super.initState();
    requestModel = widget.requestModel;
    FirestoreRequestManager.getRequestStreamById(requestId: requestModel!.id!)
        .listen((_requestModel) {
      requestModel = _requestModel;
      try {
        setState(() {});
      } on Exception catch (error) {
        logger.e(error);
      }
    });
  }

  Future<Map<String, dynamic>> getUserDetails({String? memberEmail}) async {
    var user = await CollectionRef.users.doc(memberEmail).get();

    return Map<String, dynamic>.from(user.data() as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return list;
  }

  Widget get list {
    var futures = <Future>[];
    futures.clear();
    acceptors = requestModel!.acceptors ?? [];
    approvedMembers = requestModel!.approvedUsers ?? [];
    if (widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
      oneToManyRequestAttenders =
          widget.requestModel.oneToManyRequestAttenders ?? [];
      newList = acceptors! + approvedMembers! + oneToManyRequestAttenders!;
    } else {
      newList = acceptors! + approvedMembers!;
    }

    List<String> result = LinkedHashSet<String>.from(newList!).toList();

    result.forEach((email) {
      futures.add(getUserDetails(memberEmail: email));
    });
    return FutureBuilder(
        future: Future.wait(futures),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasError) {
            return Text(
              S.of(context).general_stream_error,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }

          if (snapshot.data!.length == 0) {
            return Center(
              child: Text(S.of(context).no_pending_requests),
            );
          }
          List<UserModel> snap = snapshot.data!.map((f) {
            return UserModel.fromMap(f, 'from participants view');
          }).toList();

          snap.sort((a, b) =>
              a.fullname!.toLowerCase().compareTo(b.fullname!.toLowerCase()));

          logger.e('borrowAcceptorModel length 1: ' + snap.length.toString());

          if (requestModel!.requestType == RequestType.BORROW) {
            return BorrowRequestParticipants(
              userModelList: snap,
              timebankModel: widget.timebankModel!,
              requestModel: requestModel!,
            );
          } else {
            return ListView(
              children: <Widget>[
                ...snap.map((userModel) {
                  // return Text(f['fullname']);

                  UserRequestStatusType status;
                  status =
                      getUserRequestStatusType(userModel.email!, requestModel!);

                  return makeUserWidget(userModel, context, status);
                }).toList()
              ],
            );
          }
        });
  }

  Widget makeUserWidget(
      UserModel userModel, BuildContext context, UserRequestStatusType status) {
    return Container(
      margin: EdgeInsets.fromLTRB(30, 20, 30, 10),
      child: Stack(
        children: <Widget>[
          getUserCard(userModel, context: context, statusType: status),
          Positioned(
            left: 5,
            top: 10,
            child: getUserThumbnail(
              userModel.photoURL!,
              userModel.email!,
              userModel.sevaUserID!,
            ),
          ),
        ],
      ),
    );
  }

  Widget getUserThumbnail(String photoURL, String email, String sevaUserID) {
    return UserProfileImage(
      photoUrl: photoURL,
      email: email,
      userId: sevaUserID,
      height: 60,
      width: 60,
      timebankModel: widget.timebankModel!,
    );
  }

  Widget getUserCard(UserModel userModel,
      {BuildContext? context, UserRequestStatusType? statusType}) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Container(
        height: 200,
        width: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
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
                      userModel.fullname!,
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
                  userModel.bio ?? S.of(context!).bio_not_updated,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
              widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
                  ? oneToManyParticipantsWidget(userModel)
                  : ifUserIsNotApproved(userModel)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              height: 50,
                              padding: EdgeInsets.only(bottom: 10),
                              child: CustomElevatedButton(
                                shape: StadiumBorder(),
                                color: Colors.indigo,
                                textColor: Colors.white,
                                elevation: 5,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                onPressed: () async {
                                  approveMemberForVolunteerRequest(
                                    model: requestModel!,
                                    notificationId: Utils.getUuid(),
                                    user: userModel,
                                    context: context!,
                                  );
                                },
                                child: Text(S.of(context!).approve,
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 50,
                              padding: EdgeInsets.only(bottom: 10),
                              child: CustomElevatedButton(
                                shape: StadiumBorder(),
                                color: Colors.redAccent,
                                textColor: Colors.white,
                                elevation: 5,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                onPressed: () async {
                                  declineRequestedMember(
                                      model: requestModel!,
                                      notificationId: "sampleID",
                                      user: userModel);
                                },
                                child: Text(
                                  S.of(context).reject,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              height: 50,
                              padding: EdgeInsets.only(bottom: 10),
                              child: CustomElevatedButton(
                                shape: StadiumBorder(),
                                color: Colors.green,
                                textColor: Colors.white,
                                elevation: 5,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                onPressed: () {},
                                child: Text(S.of(context!).approved,
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
    return !requestModel!.approvedUsers!.contains(user.email);
  }

  Widget oneToManyParticipantsWidget(userModel) {
    return (widget.requestModel.oneToManyRequestAttenders!
            .contains(userModel.email))
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10, right: 10),
                height: 50,
                //width: 120,
                padding: EdgeInsets.only(bottom: 10),
                child: CustomElevatedButton(
                  shape: StadiumBorder(),
                  color: HexColor('#64C328'),
                  textColor: Colors.white,
                  elevation: 5,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onPressed: () {},
                  child: Text(S.of(context).attending,
                      style: TextStyle(
                        fontSize: 14,
                      )),
                ),
              ),
            ],
          )
        : (widget.requestModel.approvedUsers!.contains(userModel.email))
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 10, right: 10),
                    height: 50,
                    //width: 120,
                    padding: EdgeInsets.only(bottom: 10),
                    child: CustomElevatedButton(
                      shape: StadiumBorder(),
                      color: HexColor('#64C328'),
                      textColor: Colors.white,
                      elevation: 5,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onPressed: () {},
                      child: Text(S.of(context).speaker,
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                  ),
                ],
              )
            : (widget.requestModel.acceptors!.contains(userModel.email))
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 10, right: 10),
                        height: 50,
                        //width: 120,
                        padding: EdgeInsets.only(bottom: 10),
                        child: CustomElevatedButton(
                          shape: StadiumBorder(),
                          color: HexColor('#64C328'),
                          textColor: Colors.white,
                          elevation: 5,
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          onPressed: () {},
                          //checking if speaker is the creator then we can directly show as speaker
                          child: userModel.email == widget.requestModel.email
                              ? Text(
                                  S.of(context).speaker,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                )
                              : Text(
                                  S.of(context).invited_speaker,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  )
                : Container();
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

//// crate dialog for approval or rejection
//  Future showDialogForApprovalOfRequest({
//    BuildContext context,
//    UserModel userModel,
//    RequestModel requestModel,
//    String notificationId,
//  }) {
//    return showDialog(
//        context: context,
//        builder: (BuildContext viewContext) {
//          return AlertDialog(
//            shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.all(Radius.circular(25.0))),
//            content: Form(
//              //key: _formKey,
//              child: Column(
//                mainAxisSize: MainAxisSize.min,
//                children: <Widget>[
//                  _getCloseButton(viewContext),
//                  Container(
//                    height: 70,
//                    width: 70,
//                    child: CircleAvatar(
//                      backgroundImage: NetworkImage(userModel.photoURL),
//                    ),
//                  ),
//                  Padding(
//                    padding: EdgeInsets.all(4.0),
//                  ),
//                  Padding(
//                    padding: EdgeInsets.all(4.0),
//                    child: Text(
//                      userModel.fullname == null
//                          ? S.of(context).anonymous
//                          : userModel.fullname,
//                      style: TextStyle(
//                        fontSize: 18,
//                        fontWeight: FontWeight.w600,
//                      ),
//                    ),
//                  ),
//                  Padding(
//                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
//                    child: Text(
//                      userModel.email ?? '',
//                    ),
//                  ),
//                  if (userModel.bio != null)
//                    Padding(
//                      padding: EdgeInsets.all(0.0),
//                      child: Text(
//                        "${S.of(context).about} ${userModel.fullname}",
//                        style: TextStyle(
//                          fontSize: 13,
//                          fontWeight: FontWeight.bold,
//                        ),
//                      ),
//                    ),
//                  Padding(
//                    padding: EdgeInsets.all(8.0),
//                    child: Text(
//                      userModel.bio == null
//                          ? S.of(context).bio_not_updated
//                          : userModel.bio,
//                      maxLines: 5,
//                      overflow: TextOverflow.ellipsis,
//                    ),
//                  ),
//                  Center(
//                    child: Text(
//                        "${S.of(context).by_approving_you_accept}, ${userModel.fullname} ${S.of(context).my_requests}",
//                        style: TextStyle(
//                          fontStyle: FontStyle.italic,
//                        ),
//                        textAlign: TextAlign.center),
//                  ),
//                  Padding(
//                    padding: EdgeInsets.all(8.0),
//                  ),
//                  Column(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      Container(
//                        width: double.infinity,
//                        child: CustomElevatedButton(
//                          color: FlavorConfig.values.theme.primaryColor,
//                          child: Text(
//                            S.of(context).approve,
//                            style: TextStyle(
//                              color: Colors.white,
//                              fontFamily: 'Europa',
//                            ),
//                          ),
//                          onPressed: () async {
//                            // Once approved
//                            approveMemberForVolunteerRequest(
//                              model: requestModel,
//                              notificationId: notificationId,
//                              user: userModel,
//                            );
//                            Navigator.pop(viewContext);
//                          },
//                        ),
//                      ),
//                      Padding(
//                        padding: EdgeInsets.all(5.0),
//                      ),
//                      Container(
//                        width: double.infinity,
//                        child: CustomElevatedButton(
//                          color: Theme.of(context).accentColor,
//                          child: Text(
//                            S.of(context).decline,
//                            style: TextStyle(
//                              color: Colors.white,
//                              fontFamily: 'Europa',
//                            ),
//                          ),
//                          onPressed: () async {
//                            // request declined
//
//                            declineRequestedMember(
//                                model: requestModel,
//                                notificationId: notificationId,
//                                user: userModel);
//
//                            Navigator.pop(viewContext);
//                          },
//                        ),
//                      ),
//                    ],
//                  )
//                ],
//              ),
//            ),
//          );
//        });
//  }

  void declineRequestedMember({
    RequestModel? model,
    UserModel? user,
    String? notificationId,
  }) {
    List<String> acceptedUsers = model!.acceptors ?? [];
    Set<String> usersSet = acceptedUsers.toSet();

    usersSet.remove(user?.email!);
    model.acceptors = usersSet.toList();

    rejectAcceptRequest(
      requestModel: model,
      rejectedUserId: user!.sevaUserID!,
      notificationId: notificationId!,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity!,
    );
  }

  void approveMemberForVolunteerRequest({
    RequestModel? model,
    UserModel? user,
    String? notificationId,
    BuildContext? context,
  }) {
    List<String> approvedUsers = model!.approvedUsers!;
    Set<String> acceptedSet = approvedUsers.toSet();

    acceptedSet.add(user!.email!);
    model.approvedUsers = acceptedSet.toList();

    if (model.numberOfApprovals! <= model.approvedUsers!.length)
      model.accepted = true;
    approveAcceptRequest(
        requestModel: model,
        approvedUserId: user.sevaUserID!,
        notificationId: notificationId!,
        communityId: SevaCore.of(context!).loggedInUser.currentCommunity!,
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
    if (requestModel.acceptors!.contains(sevaUserEmail)) {
      return UserRequestStatusType.ACCEPTED;
    } else if (requestModel.approvedUsers!.contains(sevaUserEmail)) {
      return UserRequestStatusType.APPROVED;
    }
    return UserRequestStatusType.ACCEPTED; // Default return value
  }
}

Future<List<UserModel>> getRequestStatus({
  required String requestId,
}) async {
  final requestDetails = await CollectionRef.requests.doc(requestId).get();
  var futures = <Future>[];
  RequestModel model = RequestModel.fromMap(
    requestDetails.data() as Map<String, dynamic>,
  );

  model.approvedUsers!.forEach((membersId) {
    futures.add(
      CollectionRef.users.doc(membersId).get(),
    );
  });

  final results = await Future.wait(futures);
  usersRequested.clear();
  for (var doc in results) {
    var user = UserModel.fromDynamic(doc);
    usersRequested.add(user);
  }
  return usersRequested;
}

List<UserModel> usersRequested = [];

class AcceptorItem {
  final String email;
  final bool approved;

  AcceptorItem({required this.email, required this.approved});
}

enum UserRequestStatusType { ACCEPTED, APPROVED }
