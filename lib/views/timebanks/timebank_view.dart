import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart'
    as FirestoreManager;
import 'package:sevaexchange/views/timebanks/timebankedit.dart';
import 'package:sevaexchange/views/campaigns/campaigncreate.dart';
import 'package:sevaexchange/views/campaigns/campaignjoin.dart';
import 'package:sevaexchange/views/timebanks/timebank_join_request.dart';
import 'package:sevaexchange/views/timebanks/timebank_join_requests_view.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/campaigns/campaignsview.dart';
import 'package:sevaexchange/views/membersmanage.dart';
import 'package:sevaexchange/globals.dart' as globals;

import 'package:sevaexchange/views/core.dart';

class TimebankView extends StatefulWidget {
  final String timebankId;

  TimebankView({
    @required this.timebankId,
  });

  @override
  _TimebankViewState createState() => _TimebankViewState();
}

class _TimebankViewState extends State<TimebankView> {
  TimebankModel timebankModel;
  UserModel ownerModel;
  String title = 'Loading';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return timebankStreamBuilder();
  }

  StreamBuilder<TimebankModel> timebankStreamBuilder() {
    return StreamBuilder<TimebankModel>(
      stream: FirestoreManager.getTimebankModelStream(
          timebankId: widget.timebankId),
      builder: (streamContext, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Scaffold(
              appBar: AppBar(
                title: Text('Loading'),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
            break;
          default:
            this.timebankModel = snapshot.data;
            globals.timebankAvatarURL = timebankModel.avatarUrl;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  '${timebankModel.name}',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 20.0,
                      right: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(right: 15.0, left: 20.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    _avatarImage(timebankModel.avatarUrl),
                                minRadius: 40.0,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '${timebankModel.name}' ?? '',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Divider(color: Colors.deepPurple),
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => _whichRoute('timebanks'),
                              ),
                            );
                          },
                          child: _whichButton('timebanks'),
                        ),
                        _showCreateCampaignButton(context),
                        _showJoinRequests(context),
                        FlatButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      _whichRoute('viewcampaigns')),
                            );
                          },
                          child: _whichButton('viewcampaigns'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, left: 20.0),
                          child: Text(
                            'Mission Statement',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, left: 20.0),
                          child: Text(
                            '${timebankModel.missionStatement}',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0, left: 20.0),
                          child: Text(
                            'Address',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, left: 20.0),
                          child: Text(
                            '${timebankModel.address}',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0, left: 20.0),
                          child: Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 3.0),
                          child: FlatButton(
                            child: Text(
                              '${timebankModel.primaryNumber}',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.w400),
                            ),
                            onPressed: () {
                              String _number = timebankModel.primaryNumber;
                              launch('tel:$_number');
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, left: 20.0),
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 3.0),
                          child: FlatButton(
                            child: Text(
                              '${timebankModel.primaryEmail}',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onPressed: () {
                              String _email = '${timebankModel.primaryEmail}';
                              launch('mailto:$_email');
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                'Member List',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w700),
                              ),
                              _showManageMembersButton(context)
                            ],
                          ),
                        ),
                        StreamBuilder<UserModel>(
                          stream: FirestoreManager.getUserForIdStream(
                              sevaUserId: timebankModel.ownerSevaUserId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError)
                              return Text('Error: ${snapshot.error}');
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Center(
                                    child: CircularProgressIndicator());
                                break;
                              default:
                                UserModel ownerModel = snapshot.data;
                                this.ownerModel = ownerModel;
                                return FlatButton(
                                  onPressed: ownerModel != null
                                      ? () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileViewer(
                                                        userEmail:
                                                            ownerModel.email,
                                                      )));
                                        }
                                      : null,
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 28.0,
                                            right: 8.0,
                                            top: 8.0,
                                            bottom: 8.0),
                                        child: CircleAvatar(
                                          // minRadius: 20.0,
                                          backgroundImage: ownerModel == null ||
                                                  ownerModel.photoURL == null ||
                                                  ownerModel.photoURL.isEmpty
                                              ? AssetImage(
                                                  'lib/assets/images/noimagefound.png')
                                              : NetworkImage(
                                                  ownerModel.photoURL),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.only(right: 13.0),
                                          child: ownerModel != null &&
                                                  ownerModel.fullname != null
                                              ? Text(
                                                  ownerModel.fullname,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                  ),
                                                )
                                              : Container(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                            }
                          },
                        ),
                        getTextWidgets(context),
                      ],
                    ),
                  ),
                ),
              ),
            );
        }
      },
    );
  }

  Widget _showCreateCampaignButton(BuildContext context) {
    if (timebankModel.ownerSevaUserId ==
        SevaCore.of(context).loggedInUser.sevaUserID) {
      return FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _whichRoute('campaigns'),
            ),
          );
        },
        child: _whichButton('campaigns'),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(0.0),
      );
    }
  }

  Widget _showJoinRequests(BuildContext context) {
    if (timebankModel.ownerSevaUserId ==
        SevaCore.of(context).loggedInUser.sevaUserID) {
      return FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _whichRoute('joinrequests'),
            ),
          );
        },
        child: _whichButton('joinrequests'),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(0.0),
      );
    }
  }

  Widget _whichRoute(String section) {
    switch (section) {
      case 'timebanks':
        if (timebankModel.ownerSevaUserId ==
            SevaCore.of(context).loggedInUser.sevaUserID) {
          return TimebankEdit(
            ownerModel: ownerModel,
            timebankModel: timebankModel,
          );
        } else {
          return TimebankJoinRequest(
            timebankModel: timebankModel,
            owner: ownerModel,
          );
        }
        break;
      case 'campaigns':
        if (timebankModel.ownerSevaUserId ==
            SevaCore.of(context).loggedInUser.sevaUserID) {
          return CampaignCreate(
            timebankModel: timebankModel,
          );
        } else {
          return CampaignJoin();
        }
        break;
      case 'viewcampaigns':
        return CampaignsView(
          timebankModel: timebankModel,
        );
        break;
      case 'joinrequests':
        return TimebankJoinRequestView(
          timebankModel: timebankModel,
        );
        break;
      default:
        return null;
    }
  }

  Widget _whichButton(String section) {
    switch (section) {
      case 'timebanks':
        if (timebankModel.ownerSevaUserId ==
            SevaCore.of(context).loggedInUser.sevaUserID) {
          return Text(
            'Edit Timebank',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue),
          );
        } else {
          return Text(
            'Request to join this Timebank!',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue),
          );
        }
        break;
      case 'campaigns':
        if (timebankModel.ownerSevaUserId ==
            SevaCore.of(context).loggedInUser.sevaUserID) {
          return Text(
            'Create a Campaign (Project)',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue),
          );
        } else {
          return Text(
            'Join a Campaign (Project)',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue),
          );
        }
        break;
      case 'viewcampaigns':
        return Text(
          'View Current Campaigns',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue),
        );
        break;
      case 'joinrequests':
        return Text(
          'View Timebank Join Requests',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue),
        );
        break;
      default:
        return null;
    }
  }

  Widget _showManageMembersButton(BuildContext context) {
    assert(timebankModel.id != null);
    if (timebankModel.ownerSevaUserId ==
        SevaCore.of(context).loggedInUser.sevaUserID) {
      return FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return MembersManage(
                  timebankModel: timebankModel,
                );
              },
            ),
          );
        },
        child: Icon(Icons.edit),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(0.0),
      );
    }
  }

  Widget getTextWidgets(BuildContext context) {
    List<Widget> list = List<Widget>();

    timebankModel.members.forEach(
      (member) {
        list.add(
          FlatButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (routeContext) => ProfileViewer(userEmail: member),
                ),
              );
            },
            child: StreamBuilder<UserModel>(
                stream: FirestoreManager.getUserForEmailStream(member),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }
                  UserModel user = snapshot.data;
                  return Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          // minRadius: 20.0,
                          backgroundImage: user.photoURL == null ||
                                  user.photoURL.isEmpty
                              ? AssetImage('lib/assets/images/noimagefound.png')
                              : NetworkImage(user.photoURL),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.only(right: 13.0),
                          child: Text(
                            user.fullname ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          ),
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: list),
    );
  }

  ImageProvider _avatarImage(avatarURL) {
    if (avatarURL == null || avatarURL == '') {
      return AssetImage('lib/assets/images/profile.png');
    } else {
      return NetworkImage(avatarURL);
    }
  }
}
