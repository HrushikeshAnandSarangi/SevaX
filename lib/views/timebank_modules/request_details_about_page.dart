// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../flavor_config.dart';
// import 'package:timezone/browser.dart';

class RequestDetailsAboutPage extends StatefulWidget {
  final RequestModel requestItem;
  final TimebankModel timebankModel;
  final bool applied;
  final bool isAdmin;
  RequestDetailsAboutPage({
    Key key,
    this.applied = false,
    this.requestItem,
    this.timebankModel,
    this.isAdmin,
  }) : super(key: key);

  @override
  _RequestDetailsAboutPageState createState() =>
      _RequestDetailsAboutPageState();
}

class _RequestDetailsAboutPageState extends State<RequestDetailsAboutPage> {
  // String timeRange = '10:00 AM - 12:00 PM';
  String location = 'Location';
  // String subLocation = '881, 6th Cross Rd, Bengaluru, India';

  // String description =
  //     'India Startup in association with BullerProof. Your Startup is hostion this FREE workshop "Idea to opportunity" at Excel Partner ';

  TextStyle titleStyle = TextStyle(
    fontSize: 18,
    color: Colors.black,
  );

  TextStyle subTitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );
  bool isAdmin = false;
  @override
  void initState() {
    super.initState();
    print("fullname ${widget.requestItem.fullName}");
  }

  @override
  Widget build(BuildContext context) {
    var futures = <Future>[];
    futures.clear();

    if (widget.requestItem.acceptors != null ||
        widget.requestItem.acceptors.length != 0 ||
        widget.requestItem.approvedUsers.length != 0 ||
        widget.requestItem.invitedUsers != null ||
        widget.requestItem.invitedUsers.length != 0) {
      widget.requestItem.acceptors.forEach((memberEmail) {
        futures.add(getUserDetails(memberEmail: memberEmail));
      });
      isApplied = widget.requestItem.acceptors
              .contains(SevaCore.of(context).loggedInUser.email) ||
          widget.requestItem.approvedUsers
              .contains(SevaCore.of(context).loggedInUser.email) ||
          widget.requestItem.invitedUsers
              .contains(SevaCore.of(context).loggedInUser.sevaUserID) ||
          false;
    } else {
      isApplied = false;
    }
    if (widget.requestItem.sevaUserId ==
            SevaCore.of(context).loggedInUser.sevaUserID ||
        widget.timebankModel.admins
            .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
      isAdmin = true;
    }
    return Scaffold(
      appBar: !isAdmin
          ? AppBar(
              backgroundColor: Colors.white,
              leading: BackButton(
                color: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              centerTitle: true,
              title: Text(
                AppLocalizations.of(context)
                    .translate('requests', 'my_requests'),
                style: TextStyle(
                    fontFamily: "Europa", fontSize: 20, color: Colors.black),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
//                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10),
                  Text(
                    widget.requestItem.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomListTile(
                      leading: Icon(
                        Icons.access_time,
                        color: Colors.grey,
                      ),
                      title: Text(
                        DateFormat(
                                'EEEEEEE, MMMM dd',
                                Locale(AppConfig.prefs
                                        .getString('language_code'))
                                    .toLanguageTag())
                            .format(
                          getDateTimeAccToUserTimezone(
                              dateTime: DateTime.fromMillisecondsSinceEpoch(
                                  widget.requestItem.requestStart),
                              timezoneAbb:
                                  SevaCore.of(context).loggedInUser.timezone),
                        ),
                        style: titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        DateFormat(
                                    'h:mm a',
                                    Locale(AppConfig.prefs
                                            .getString('language_code'))
                                        .toLanguageTag())
                                .format(
                              getDateTimeAccToUserTimezone(
                                  dateTime: DateTime.fromMillisecondsSinceEpoch(
                                      widget.requestItem.requestStart),
                                  timezoneAbb: SevaCore.of(context)
                                      .loggedInUser
                                      .timezone),
                            ) +
                            ' - ' +
                            DateFormat(
                                    'h:mm a',
                                    Locale(AppConfig.prefs
                                            .getString('language_code'))
                                        .toLanguageTag())
                                .format(
                              getDateTimeAccToUserTimezone(
                                dateTime: DateTime.fromMillisecondsSinceEpoch(
                                    widget.requestItem.requestEnd),
                                timezoneAbb:
                                    SevaCore.of(context).loggedInUser.timezone,
                              ),
                            ),
                        style: subTitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Container(
                        height: 25,
                        width: 90,
                        child: widget.requestItem.sevaUserId ==
                                SevaCore.of(context).loggedInUser.sevaUserID
                            ? FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: Color.fromRGBO(44, 64, 140, 1),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('requests', 'edit'),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                                onPressed: () {
                                  RequestModel _modelItem = widget.requestItem;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditRequest(
                                        timebankId: SevaCore.of(context)
                                            .loggedInUser
                                            .currentTimebank,
                                        requestModel: widget.requestItem,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(),
                      )),
                  widget.requestItem.address != null
                      ? CustomListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: Colors.grey,
                          ),
                          title: Text(
                            location,
                            style: titleStyle,
                            maxLines: 1,
                          ),
                          subtitle: widget.requestItem.address != null
                              ? Text(widget.requestItem.address)
                              : Text(''),
                        )
                      : Container(),
                  CustomListTile(
                    // contentPadding: EdgeInsets.all(0),

                    leading: Icon(
                      Icons.person,
                      color: Colors.grey,
                    ),
                    title: Text(
                      "${AppLocalizations.of(context).translate('requests', 'hosted_by')} ${widget.requestItem.fullName ?? ""}",
                      style: titleStyle,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '${widget.requestItem.approvedUsers.length} / ${widget.requestItem.numberOfApprovals} Accepted',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  FutureBuilder(
                      future: Future.wait(futures),
                      builder:
                          (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (snapshot.hasError)
                          return Text(
                              '${AppLocalizations.of(context).translate('requests', 'error')} ${snapshot.error}');
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (widget.requestItem.approvedUsers.length == 0) {
                          return Container(
                            margin: EdgeInsets.only(left: 0, top: 10),
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('requests', 'none_approved_yet'),
                            ),
                          );
                        }

                        var snap = snapshot.data.map((f) {
                          return UserModel.fromDynamic(f ?? {});
                        }).toList();

                        print(" $snap ---------------------------- ");

                        return Container(
                          height: 40,
                          child: InkWell(
                            onTap: () {
                              print('tapped');
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              scrollDirection: Axis.horizontal,
                              itemCount: snap.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 3, right: 3, top: 8),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          snap[index].photoURL ??
                                              defaultUserImageURL,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                  SizedBox(height: 10),

                  // NetworkImage(
                  //   imageUrl:
                  //       'https://technext.github.io/Evento/images/demo/bg-slide-01.jpg',
                  //   fit: BoxFit.fitWidth,
                  //   placeholder: (context, url) => Center(
                  //     child: CircularProgressIndicator(),
                  //   ),
                  //   errorWidget: (context, url, error) => Icon(Icons.error),
                  // ),
                  Text(
                    widget.requestItem.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  /*CachedNetworkImage(
                      imageUrl: widget.requestItem.photoUrl,
                      errorWidget: (context,url,error) =>
                          Container(),
                      placeholder: (context,url){
                        return Center(child: CircularProgressIndicator());
                      }

                  ),*/
                ],
              ),
            ),
            getBottombar(),
          ],
        ),
      ),
    );
  }

  Future<dynamic> getUserDetails({String memberEmail}) async {
    var user = await Firestore.instance
        .collection("users")
        .document(memberEmail)
        .get();

    return user.data;
  }

  Future<String> _getLocation(double lat, double lng) async {
    String address = await LocationUtility().getFormattedAddress(lat, lng);
    // log('_getLocation: $address');
    // setState(() {
    //   this.selectedAddress = address;
    // });

    return address;
  }

  bool isApplied = false;
  Widget getBottombar() {
    return Container(
      decoration: BoxDecoration(color: Colors.white54, boxShadow: [
        BoxShadow(color: Colors.grey[300], offset: Offset(2.0, 2.0))
      ]),
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: widget.requestItem.sevaUserId ==
                              SevaCore.of(context).loggedInUser.sevaUserID
                          ? AppLocalizations.of(context)
                              .translate('requests', 'creator_you')
                          : isApplied
                              ? AppLocalizations.of(context)
                                  .translate('requests', 'applied_you')
                              : AppLocalizations.of(context)
                                  .translate('requests', 'want_part'),
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Europa',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Offstage(
              offstage: widget.requestItem.sevaUserId ==
                  SevaCore.of(context).loggedInUser.sevaUserID,
              child: Container(
                margin: EdgeInsets.only(right: 5),
                width: 100,
                height: 32,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(0),
                  color:
                      isApplied ? Theme.of(context).accentColor : Colors.green,
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 1),
                      Spacer(),
                      Text(
                        isApplied
                            ? AppLocalizations.of(context)
                                .translate('requests', 'withdraw_button')
                            : AppLocalizations.of(context)
                                .translate('requests', 'apply'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                    ],
                  ),
                  onPressed: () {
                    if(SevaCore.of(context).loggedInUser.calendarId==null) {
                      _settingModalBottomSheet(context);
                    }else{
                      applyAction();
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showProtectedTimebankMessage() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(AppLocalizations.of(context)
              .translate('requests', 'protected_alert')),
          content: Text(AppLocalizations.of(context)
              .translate('requests', 'projected_alert_dialog')),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              textColor: Colors.red,
              child: Text(
                AppLocalizations.of(context).translate('shared', 'close'),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void applyAction() async {
    if (isApplied) {
      print("Withraw request");
      _withdrawRequest();
    } else {
      print("Accept request");
      await _acceptRequest();
      Navigator.pop(context);
    }
  }

  void _acceptRequest() async {

    Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
    acceptorList.add(SevaCore.of(context).loggedInUser.email);

    widget.requestItem.acceptors = acceptorList.toList();
    await acceptRequest(
      requestModel: widget.requestItem,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      directToMember: !widget.timebankModel.protected,
    );
  }

  void _withdrawRequest() async {
    var assosciatedEmail = SevaCore.of(context).loggedInUser.email;
    // if (widget.requestItem.approvedUsers
    //     .contains(SevaCore.of(context).loggedInUser.email)) {
    //   _showAlreadyApprovedMessage();
    // } else {}

    Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
    acceptorList.remove(assosciatedEmail);
    widget.requestItem.acceptors = acceptorList.toList();

    if (widget.requestItem.approvedUsers.contains(assosciatedEmail)) {
      Set<String> approvedUsers = Set.from(widget.requestItem.approvedUsers);
      approvedUsers.remove(SevaCore.of(context).loggedInUser.email);
      widget.requestItem.approvedUsers = approvedUsers.toList();
    }

    await acceptRequest(
      requestModel: widget.requestItem,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      isWithdrawal: true,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      directToMember: !widget.timebankModel.protected,
    );
    Navigator.pop(context);
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                  child: Text(
                    "Would you like to link your calendar with Sevax ?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6,6,6,6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: Image.asset(
                                "lib/assets/images/googlecal.png"),
                          ),
                          onTap: () async {
                            String redirectUrl = "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl = "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=google_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            applyAction();
                            Navigator.of(bc).pop();
                          }
                      ),
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: Image.asset(
                                "lib/assets/images/outlookcal.png"),
                          ),
                          onTap: () async {
                            String redirectUrl = "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl = "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            applyAction();
                            Navigator.of(bc).pop();
                          }
                      ),
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: Image.asset(
                                "lib/assets/images/ical.png"),
                          ),
                          onTap: () async {
                            String redirectUrl = "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl = "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=icloud_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            applyAction();
                            Navigator.of(bc).pop();
                          }
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    FlatButton(
                        child: Text("Do it later", style: TextStyle(color: FlavorConfig.values.theme.primaryColor),),
                        onPressed: () async {
                          applyAction();
                          Navigator.of(bc).pop();
                        }
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  void _showAlreadyApprovedMessage() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(AppLocalizations.of(context)
              .translate('requests', 'already_approved')),
          content: Text(AppLocalizations.of(context)
              .translate('requests', 'cant_withdraw')),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                  AppLocalizations.of(context).translate('shared', 'close')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
