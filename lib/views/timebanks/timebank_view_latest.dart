import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/sponsors/sponsors_widget.dart';
import 'package:sevaexchange/ui/screens/sponsors/widgets/get_user_verified.dart';
import 'package:sevaexchange/ui/screens/user_info/pages/user_donations.dart';
import 'package:sevaexchange/ui/screens/user_info/pages/user_donations_list.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/views/timebanks/widgets/timebank_seva_coin.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/user_profile_image.dart';

class TimeBankAboutView extends StatefulWidget {
  final TimebankModel timebankModel;
  final String email;
  final String userId;
  TimeBankAboutView.of({this.timebankModel, this.email, this.userId});

  @override
  _TimeBankAboutViewState createState() => _TimeBankAboutViewState();
}

class _TimeBankAboutViewState extends State<TimeBankAboutView>
    with AutomaticKeepAliveClientMixin {
  bool descTextShowFlag = false;
  bool isUserJoined = false;
  String loggedInUser;
  UserModelListMoreStatus userModels;
  UserModel user;
  bool isDataLoaded = false;
  bool isAdminLoaded = false;
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => getData());
    }

    super.initState();
  }

  void getData() async {
    await FirestoreManager.getUserForId(
            sevaUserId: widget.timebankModel.creatorId)
        .then((onValue) {
      user = onValue;
      setState(() {
        isAdminLoaded = true;
      });
    });
    var templist = [
      ...widget.timebankModel.members,
      ...widget.timebankModel.organizers,
      ...widget.timebankModel.admins,
      ...widget.timebankModel.coordinators
    ];
    isUserJoined = templist.contains(widget.userId) ? true : false;
    isDataLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: CachedNetworkImage(
                    imageUrl:
                        widget.timebankModel.cover_url ?? defaultGroupImageURL,
                    fit: BoxFit.cover,
                    height: 200,
                    errorWidget: (context, url, error) => Image(
                      fit: BoxFit.cover,
                      width: 620,
                      height: 180,
                      image: NetworkImage(defaultGroupImageURL),
                    ),
                    placeholder: (context, url) {
                      return LoadingIndicator();
                    },
                  ),
                ),
                Positioned(
                  child: Container(
                    child: CachedNetworkImage(
                      imageUrl: (widget.timebankModel.photoUrl == null ||
                              widget.timebankModel.photoUrl == '')
                          ? defaultUserImageURL
                          : widget.timebankModel.photoUrl,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 70,
                      placeholder: (context, url) {
                        return LoadingIndicator();
                      },
                    ),
                  ),
                  left: 13.0,
                  bottom: -38.0,
                ),
              ],
            ),
            SizedBox(
              height: 45,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 5),
              child: Text(
                widget.timebankModel.name ?? " ",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            isUserJoined
                ? TimeBankSevaCoin(
                    isAdmin: isAccessAvailable(widget.timebankModel,
                        SevaCore.of(context).loggedInUser.sevaUserID),
                    loggedInUser: SevaCore.of(context).loggedInUser,
                    timebankData: widget.timebankModel)
                : Offstage(),
            SizedBox(
              height: 15,
            ),
            // isAccessAvailable(
            //   widget.timebankModel,
            //   SevaCore.of(context).loggedInUser.sevaUserID,
            // ) ? Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: TransactionsMatrixCheck(
            //           upgradeDetails:
            //               AppConfig.upgradePlanBannerModel.add_manual_time,
            //           transaction_matrix_type: "add_manual_time",
            //           child: AddManualTimeButton(
            //             typeId: widget.timebankModel.id,
            //             timebankId: widget.timebankModel.parentTimebankId ==
            //                     FlavorConfig.values.timebankId
            //                 ? widget.timebankModel.id
            //                 : widget.timebankModel.parentTimebankId,
            //             timeFor: ManualTimeType.Timebank,
            //             userType: getLoggedInUserRole(
            //               widget.timebankModel,
            //               SevaCore.of(context).loggedInUser.sevaUserID,
            //             ),
            //             communityName: widget.timebankModel.name,
            //           ),
            //         ),
            //       )
            //     : Container(),
            isAccessAvailable(widget.timebankModel,
                    SevaCore.of(context).loggedInUser.sevaUserID)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GoodsAndAmountDonations(
                          userId: SevaCore.of(context).loggedInUser.sevaUserID,
                          isGoods: false,
                          timebankId: widget.timebankModel.id,
                          isTimeBank: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return GoodsAndAmountDonationsList(
                                    type: "timebank",
                                    isGoods: false,
                                    timebankid: widget.timebankModel.id,
                                  );
                                },
                              ),
                            );
                          }),
                      SizedBox(
                        height: 15,
                      ),
                      GoodsAndAmountDonations(
                          userId: SevaCore.of(context).loggedInUser.sevaUserID,
                          isGoods: true,
                          timebankId: widget.timebankModel.id,
                          isTimeBank: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return GoodsAndAmountDonationsList(
                                      type: "timebank",
                                      isGoods: true,
                                      timebankid: widget.timebankModel.id);
                                },
                              ),
                            );
                          }),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  )
                : Offstage(),
            widget.timebankModel.members.contains(
              SevaCore.of(context).loggedInUser.sevaUserID,
            )
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
                                child: Text(S.of(context).getting_volunteers),
                              );
                            }

                            if (widget.timebankModel.members.length == 0) {
                              return Container(
                                margin: EdgeInsets.only(left: 15),
                                child: Text(S.of(context).no_volunteers_yet),
                              );
                            }

                            List<UserModel> memberPhotoUrlList = [];
                            for (var i = 0;
                                i < widget.timebankModel.members.length;
                                i++) {
                              UserModel userModel = snapshot.data[i];
                              if (userModel != null) {
                                // userModel.photoURL != null
                                memberPhotoUrlList.add(userModel);
                              }
                            }

                            return ListView(
                              padding: EdgeInsets.only(left: 15),
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                ...memberPhotoUrlList.map((user) {
                                  return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.5),
                                      child: UserProfileImage(
                                        photoUrl: user.photoURL,
                                        email: user.email,
                                        userId: user.sevaUserID,
                                        height: 40,
                                        width: 40,
                                        timebankModel: widget.timebankModel,
                                      ));
                                }).toList()
                              ],
                            );
                          }),
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 20),
              child: Text(
                widget.timebankModel.members.length.toString() +
                    ' ${S.of(context).members}',
                style: TextStyle(
                  fontFamily: 'Europa',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.timebankModel.address ?? '',
                style: TextStyle(
                  fontFamily: 'Europa',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Divider(
                color: Colors.black12,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 0, bottom: 5),
              child: Text(
                S.of(context).help_about_us,
                style: TextStyle(
                  fontFamily: 'Europa',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 5.0, 15, 0),
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
                    child: widget.timebankModel.missionStatement.length > 100
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              descTextShowFlag
                                  ? Text(
                                      S.of(context).read_less,
                                      style: TextStyle(
                                        fontFamily: 'Europa',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.lightBlueAccent,
                                      ),
                                    )
                                  : Text(
                                      S.of(context).read_more,
                                      style: TextStyle(
                                        fontFamily: 'Europa',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.lightBlueAccent,
                                      ),
                                    )
                            ],
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
            Offstage(
              offstage: widget.timebankModel.sponsors.isEmpty ||
                      widget.timebankModel.sponsors == null
                  ? true
                  : false,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Divider(
                  color: Colors.black12,
                ),
              ),
            ),
            Offstage(
              offstage: widget.timebankModel.sponsors.isEmpty ||
                      widget.timebankModel.sponsors == null
                  ? true
                  : false,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: SponsorsWidget(
                  sponsorsMode: SponsorsMode.ABOUT,
                  sponsors: widget.timebankModel.sponsors,
                  isAdminVerified: GetUserVerified<bool>().verify(
                    userId: SevaCore.of(context).loggedInUser.sevaUserID,
                    creatorId: widget.timebankModel.creatorId,
                    admins: widget.timebankModel.admins,
                    organizers: widget.timebankModel.organizers,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Divider(
                color: Colors.black12,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                S.of(context).owner,
                style: TextStyle(
                  fontFamily: 'Europa',
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 5),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      isAdminLoaded
                          ? Text(
                              user.fullname ?? ' ',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Europa'),
                            )
                          : Container(
                              child: Text(S.of(context).admin_not_available),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            if (isAccessAvailable(widget.timebankModel,
                                SevaCore.of(context).loggedInUser.sevaUserID)) {
                              _showAdminMessage();
                            } else {
                              startChat(
                                widget.timebankModel.id,
                                widget.email,
                                context,
                                widget.timebankModel,
                              );
                            }
                          },
                          child: Text(
                            S.of(context).message,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: 'Europa',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  isAdminLoaded
                      ? UserProfileImage(
                          photoUrl: user.photoURL ?? defaultUserImageURL,
                          email: user.email,
                          userId: user.sevaUserID,
                          height: 60,
                          width: 60,
                          timebankModel: widget.timebankModel,
                        )
                      : CircleAvatar()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).admin_cannot_create_message),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                right: 15,
                bottom: 15,
              ),
              child: CustomTextButton(
                color: Colors.grey,
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                shape: StadiumBorder(),
                child: Text(
                  S.of(context).close,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Europa',
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

var timeStamp = DateTime.now().millisecondsSinceEpoch;

void startChat(
  String email,
  String loggedUserEmail,
  BuildContext context,
  TimebankModel timebankModel,
) async {
  if (email == loggedUserEmail) {
    return null;
  } else {
    UserModel loggedInUser = SevaCore.of(context).loggedInUser;
    ParticipantInfo sender = ParticipantInfo(
      id: loggedInUser.sevaUserID,
      name: loggedInUser.fullname,
      photoUrl: loggedInUser.photoURL,
      type: ChatType.TYPE_PERSONAL,
    );

    ParticipantInfo reciever = ParticipantInfo(
      id: timebankModel.id,
      name: timebankModel.name,
      photoUrl: timebankModel.photoUrl,
      type: ChatType.TYPE_TIMEBANK,
    );
    createAndOpenChat(
      context: context,
      timebankId: timebankModel.id,
      sender: sender,
      reciever: reciever,
      communityId: loggedInUser.currentCommunity,
      isTimebankMessage: true,
    );
  }
}
