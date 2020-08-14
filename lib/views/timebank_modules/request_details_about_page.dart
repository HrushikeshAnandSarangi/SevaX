import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/views/requests/donations/donation_view.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';

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
  String location = 'Location';
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

  var futures = <Future>[];

  Widget get appBarForMembers {
    return AppBar(
      backgroundColor: Colors.white,
      leading: BackButton(
        color: Colors.black,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
      title: Text(
        S.of(context).my_requests,
        style:
            TextStyle(fontFamily: "Europa", fontSize: 20, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: !isAdmin ? appBarForMembers : null,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                children: <Widget>[
                  SizedBox(height: 10),
                  requestTitleComponent,
                  SizedBox(height: 10),
                  totalGoodsReceived,
                  // SizedBox(height: 10),
                  cashDonationDetails,
                  timestampComponent,
                  addressComponent,
                  hostNameComponent,
                  SizedBox(height: 20),
                  membersEngagedComponent,
                  SizedBox(height: 10),
                  engagedMembersPicturesScroll,
                  requestDescriptionComponent,
                ],
              ),
            ),
            getBottombar,
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

  bool isApplied = false;
  Widget get getBottombar {
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
                          ? S.of(context).creator_of_request_message
                          : isApplied
                              ? S.of(context).applied_for_request
                              : S.of(context).particpate_in_request_question,
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
                            ? S.of(context).withdraw
                            : S.of(context).apply,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonationView(
                          timabankName: widget.timebankModel.name,
                          requestModel: widget.requestItem,
                        ),
                      ),
                    );
                    //applyAction();
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void applyAction() {
    if (isApplied) {
      print("Withraw request");
      _withdrawRequest();
    } else {
      print("Accept request");
      _acceptRequest();
      Navigator.pop(context);
    }
  }

  void _acceptRequest() {
    Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
    acceptorList.add(SevaCore.of(context).loggedInUser.email);

    widget.requestItem.acceptors = acceptorList.toList();
    acceptRequest(
      loggedInUser: SevaCore.of(context).loggedInUser,
      requestModel: widget.requestItem,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      directToMember: !widget.timebankModel.protected,
    );
  }

  void _withdrawRequest() {
    bool isAlreadyApproved = widget.requestItem.approvedUsers
        .contains(SevaCore.of(context).loggedInUser.email);
    var assosciatedEmail = SevaCore.of(context).loggedInUser.email;

    Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
    acceptorList.remove(assosciatedEmail);
    widget.requestItem.acceptors = acceptorList.toList();

    if (widget.requestItem.approvedUsers.contains(assosciatedEmail)) {
      Set<String> approvedUsers = Set.from(widget.requestItem.approvedUsers);
      approvedUsers.remove(SevaCore.of(context).loggedInUser.email);
      widget.requestItem.approvedUsers = approvedUsers.toList();
    }

    acceptRequest(
      loggedInUser: SevaCore.of(context).loggedInUser,
      isAlreadyApproved: isAlreadyApproved,
      requestModel: widget.requestItem,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      isWithdrawal: true,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      directToMember: !widget.timebankModel.protected,
    );
    Navigator.pop(context);
  }

  Widget get membersEngagedComponent {
    return Text(
      '${widget.requestItem.approvedUsers.length} / ${widget.requestItem.numberOfApprovals} Accepted',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget get hostNameComponent {
    return CustomListTile(
      leading: Icon(
        Icons.person,
        color: Colors.grey,
      ),
      title: Text(
        "${S.of(context).hosted_by} ${widget.requestItem.fullName ?? ""}",
        style: titleStyle,
        maxLines: 1,
      ),
    );
  }

  Widget get requestTitleComponent {
    return Text(
      widget.requestItem.title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget get date {
    return Text(
      DateFormat(
              'EEEEEEE, MMMM dd',
              Locale(AppConfig.prefs.getString('language_code'))
                  .toLanguageTag())
          .format(
        getDateTimeAccToUserTimezone(
            dateTime: DateTime.fromMillisecondsSinceEpoch(
                widget.requestItem.requestStart),
            timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
      ),
      style: titleStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget get subtitleComponent {
    return Text(
      DateFormat(
                  'h:mm a',
                  Locale(AppConfig.prefs.getString('language_code'))
                      .toLanguageTag())
              .format(
            getDateTimeAccToUserTimezone(
                dateTime: DateTime.fromMillisecondsSinceEpoch(
                    widget.requestItem.requestStart),
                timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
          ) +
          ' - ' +
          DateFormat(
                  'h:mm a',
                  Locale(AppConfig.prefs.getString('language_code'))
                      .toLanguageTag())
              .format(
            getDateTimeAccToUserTimezone(
              dateTime: DateTime.fromMillisecondsSinceEpoch(
                  widget.requestItem.requestEnd),
              timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
            ),
          ),
      style: subTitleStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget get timestampComponent {
    return CustomListTile(
      leading: Icon(
        Icons.access_time,
        color: Colors.grey,
      ),
      title: date,
      subtitle: subtitleComponent,
      trailing: trailingComponent,
    );
  }

  Widget get addressComponent {
    return widget.requestItem.address != null
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
        : Container();
  }

  Widget get trailingComponent {
    return Container(
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
                S.of(context).edit,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditRequest(
                      timebankId:
                          SevaCore.of(context).loggedInUser.currentTimebank,
                      requestModel: widget.requestItem,
                    ),
                  ),
                );
              },
            )
          : Container(),
    );
  }

  Widget get requestDescriptionComponent {
    return Text(
      widget.requestItem.description,
      style: TextStyle(fontSize: 16),
    );
  }

  Widget get engagedMembersPicturesScroll {
    futures.clear();
    return FutureBuilder(
      future: Future.wait(futures),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasError)
          return Text(
            '${S.of(context).general_stream_error}',
          );
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (widget.requestItem.approvedUsers.length == 0) {
          return Container(
            margin: EdgeInsets.only(left: 0, top: 10),
            child: Text(
              S.of(context).no_approved_members,
            ),
          );
        }

        var snap = snapshot.data.map((f) {
          return UserModel.fromDynamic(f ?? {});
        }).toList();
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
                  padding: const EdgeInsets.only(left: 3, right: 3, top: 8),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          snap[index].photoURL ?? defaultUserImageURL,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget get totalGoodsReceived {
    return CustomListTile(
      title: Text(
        'Total Goods Received',
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(''),
      leading: Icon(
        Icons.show_chart,
        color: Colors.grey,
      ),
      trailing: Text(
        '10',
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
          // fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget get cashDonationDetails {
    return Column(
      children: [
        CustomListTile(
          title: Text(
            'Total amount raised',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text('\$100'),
          leading: Icon(
            Icons.show_chart,
            color: Colors.grey,
          ),
          trailing: Text(
            '',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 30, bottom: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              semanticsLabel: '20%',
              backgroundColor: Colors.grey[200],
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              minHeight: 10,
              value: 0.4,
            ),
          ),
        )
      ],
    );
  }
}
