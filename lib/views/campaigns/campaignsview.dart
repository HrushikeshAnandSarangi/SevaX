import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sevaexchange/views/campaigns/campaignedit.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/campaigns/campaign_join_request.dart';
import 'package:sevaexchange/views/campaigns/campaign_join_requests_view.dart';
import 'package:sevaexchange/views/membersmanagecampaign.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart'
    as FireStoreManager;

class CampaignsView extends StatelessWidget {
  final TimebankModel timebankModel;

  CampaignsView({@required this.timebankModel}) {
    assert(timebankModel != null && timebankModel.id != null);
  }

  @override
  Widget build(BuildContext context) {
    // _getPreferences();
    // _getAvatarURL();
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaigns'),
        backgroundColor: Colors.deepPurple,
        centerTitle: false,
      ),
      body: CampaignsList(
        parentTimebankModel: timebankModel,
      ),
    );
  }
}

class CampaignsList extends StatelessWidget {
  final TimebankModel parentTimebankModel;

  CampaignsList({@required this.parentTimebankModel});

  ImageProvider _avatarImage(CampaignModel campaignModel) {
    return campaignModel.avatarUrl != null && campaignModel.avatarUrl.isNotEmpty
        ? NetworkImage(campaignModel.avatarUrl)
        : AssetImage('lib/assets/images/profile.png');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CampaignModel>>(
      stream: FireStoreManager.getCampaignsForTimebankStream(
          timebankModel: parentTimebankModel),
      builder: (BuildContext context,
          AsyncSnapshot<List<CampaignModel>> campaignSnapshot) {
        if (campaignSnapshot.hasError)
          return new Text('Error: ${campaignSnapshot.error}');
        switch (campaignSnapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            return ListView(
              children: campaignSnapshot.data.map(
                (CampaignModel campaignModel) {
                  return GestureDetector(
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.only(top: 5.0),
                        constraints: BoxConstraints.expand(
                          height: 120.0,
                        ),
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              left: 10,
                              child: CircleAvatar(
                                minRadius: 40.0,
                                backgroundColor: Colors.grey,
                                backgroundImage: _avatarImage(campaignModel),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 100.0, right: 5.0),
                              child: Wrap(
                                children: <Widget>[
                                  Text(
                                    campaignModel.name ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 10.0,
                              right: 100.0,
                              child: Icon(
                                Icons.notifications_none,
                                color: Colors.black,
                              ),
                            ),
                            Positioned(
                              bottom: 10.0,
                              right: 145.0,
                              child: Icon(
                                Icons.favorite_border,
                                color: Colors.black,
                              ),
                            ),
                            Positioned(
                              bottom: 10.0,
                              right: 55.0,
                              child: Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.black,
                              ),
                            ),
                            Positioned(
                              bottom: 10.0,
                              right: 10.0,
                              child: Icon(
                                Icons.share,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () async {
                      Duration(milliseconds: 10);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return CampaignView(
                              campaignId: campaignModel.id,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ).toList(),
            );
        }
      },
    );
  }
}

class CampaignView extends StatefulWidget {
  final String campaignId;

  CampaignView({
    Key key,
    @required this.campaignId,
  }) : super(key: key) {
    assert(campaignId != null);
  }

  _CampaignViewState createState() => _CampaignViewState();
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

void onItemMenuPress(Choice choice) {}

class _CampaignViewState extends State<CampaignView> {
  CampaignModel campaignModel;

  _CampaignViewState({Key key});

  List<Choice> choices = const <Choice>[
    const Choice(title: 'Bookmark', icon: Icons.bookmark_border),
    const Choice(title: 'Share', icon: Icons.share),
  ];
  final primaryColor = Color(0xff203152);

//  void initState() {
//    super.initState();
//    ApiManager.getUserForIdStream(sevaUserId: campaignModel.ownerSevaUserId)
//        .listen((ownerModel) {
//      setState(() {
//        this.ownerModel = ownerModel;
//      });
//    });
//  }

  ImageProvider _avatarImage(String avatarURL) {
    if (avatarURL == null || avatarURL == '') {
      return AssetImage('lib/assets/images/profile.png');
    } else {
      return NetworkImage(avatarURL);
    }
  }

  Widget _showEditCampaignButton(CampaignModel campaignItem) {
    if (campaignItem.ownerSevaUserId ==
        SevaCore.of(context).loggedInUser.sevaUserID) {
      return FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampaignEdit(
                    timebankId: campaignItem.parentTimebankId,
                    campaignModel: campaignItem,
                  ),
            ),
          );
        },
        child: Text(
          'Edit Campaign',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(0.0),
      );
    }
  }

  Widget _showJoinRequests(CampaignModel campaignItem) {
    if (campaignItem.ownerSevaUserId ==
        SevaCore.of(context).loggedInUser.sevaUserID) {
      return FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CampaignJoinRequestView()),
          );
        },
        child: Text(
          'View Campaign Join Requests',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(0.0),
      );
    }
  }

  Widget _requestToJoin(CampaignModel campaignItem) {
    if (campaignItem.ownerSevaUserId !=
        SevaCore.of(context).loggedInUser.sevaUserID) {
      return FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampaignJoinRequest(
                    campaignModel: campaignItem,
                  ),
            ),
          );
        },
        child: Text(
          'Request To Join This Campaign!',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(0.0),
      );
    }
  }

  Widget getTextWidgets() {
    List<Widget> list = List<Widget>();

    campaignModel.members.forEach((member) {
      list.add(
        FlatButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileViewer(
                      userEmail: member.email,
                    ),
              ),
            );
          },
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  // minRadius: 20.0,
                  backgroundImage: member != null && member.photoUrl != null
                      ? NetworkImage(member.photoUrl)
                      : Image.asset('lib/assets/images/noimagefound.png'),
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(right: 13.0),
                  child: Text(
                    member.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }

  Widget _showManageMembersButton(CampaignModel tbItem) {
    if (tbItem.ownerSevaUserId ==
        SevaCore.of(context).loggedInUser.sevaUserID) {
      return FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MembersManageCampaign(
                      campaignID: '${tbItem.id}',
                    )),
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CampaignModel>(
      stream: FireStoreManager.getCampaignForIdStream(
          campaignId: widget.campaignId),
      builder: (context, campaignSnapshot) {
        if (campaignSnapshot.hasError) {
          return Text('error: ${campaignSnapshot.error}');
        }
        if (campaignSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        this.campaignModel = campaignSnapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: StreamBuilder<TimebankModel>(
                stream: FireStoreManager.getTimebankModelStream(
                  timebankId: campaignModel.parentTimebankId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text('Error');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading');
                  }
                  return Text(
                    snapshot.data.name,
                    style: TextStyle(fontSize: 16.0),
                  );
                }),
            backgroundColor: Colors.deepPurple,
            actions: <Widget>[
              PopupMenuButton<Choice>(
                onSelected: onItemMenuPress,
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            choice.icon,
                            color: primaryColor,
                          ),
                          Container(
                            width: 10.0,
                          ),
                          Text(
                            choice.title,
                            style: TextStyle(color: primaryColor),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              // padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.only(left: 0.0, right: 20.0, top: 25.0),
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
                                _avatarImage(campaignModel.avatarUrl),
                            minRadius: 40.0,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            campaignModel.name ?? '',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Divider(
                        color: Colors.deepPurple,
                      ),
                    ),
                    _showEditCampaignButton(campaignModel),
                    _showJoinRequests(campaignModel),
                    _requestToJoin(campaignModel),
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
                        campaignModel.missionStatement ?? '',
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
                        campaignModel.address,
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
                          campaignModel.primaryNumber,
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w400),
                        ),
                        onPressed: () {
                          String _number = campaignModel.primaryNumber;
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
                          campaignModel.creatorEmail,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onPressed: () {
                          String _email = campaignModel.primaryEmail;
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
                                fontSize: 18.0, fontWeight: FontWeight.w700),
                          ),
                          _showManageMembersButton(campaignModel)
                        ],
                      ),
                    ),
                    StreamBuilder<Object>(
                        stream: FireStoreManager.getUserForIdStream(
                          sevaUserId: campaignModel.ownerSevaUserId,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          UserModel ownerModel = snapshot.data;
                          return FlatButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileViewer(
                                        userEmail: ownerModel.email,
                                      ),
                                ),
                              );
                            },
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
                                    backgroundImage: ownerModel != null &&
                                            ownerModel.photoURL != null
                                        ? NetworkImage(ownerModel.photoURL)
                                        : AssetImage(
                                            'lib/assets/images/noimagefound.png'),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.only(right: 13.0),
                                    child: Text(
                                      ownerModel == null
                                          ? 'Loading'
                                          : ownerModel.fullname ?? 'Loading',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    getTextWidgets(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

//  @override
//  Widget build(BuildContext context) {
//    // Use the Todo to create our UI
//    return Scaffold(
//      appBar: AppBar(
//        title: Text(
//          widget.parentTimebankModel.name,
//          style: TextStyle(fontSize: 16.0),
//        ),
//        backgroundColor: Colors.deepPurple,
//        actions: <Widget>[
//          PopupMenuButton<Choice>(
//            onSelected: onItemMenuPress,
//            itemBuilder: (BuildContext context) {
//              return choices.map((Choice choice) {
//                return PopupMenuItem<Choice>(
//                  value: choice,
//                  child: Row(
//                    children: <Widget>[
//                      Icon(
//                        choice.icon,
//                        color: primaryColor,
//                      ),
//                      Container(
//                        width: 10.0,
//                      ),
//                      Text(
//                        choice.title,
//                        style: TextStyle(color: primaryColor),
//                      ),
//                    ],
//                  ),
//                );
//              }).toList();
//            },
//          ),
//        ],
//      ),
//      body: SafeArea(
//        child: SingleChildScrollView(
//          // padding: const EdgeInsets.all(16.0),
//          child: Container(
//            padding: EdgeInsets.only(left: 0.0, right: 20.0, top: 25.0),
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.start,
//                  children: <Widget>[
//                    Container(
//                      padding: EdgeInsets.only(right: 15.0, left: 20.0),
//                      child: CircleAvatar(
//                        backgroundColor: Colors.grey,
//                        backgroundImage: _avatarImage(campaignModel.avatarUrl),
//                        minRadius: 40.0,
//                      ),
//                    ),
//                    Flexible(
//                      child: Text(
//                        campaignModel.name ?? '',
//                        style: TextStyle(
//                            fontSize: 18.0,
//                            fontStyle: FontStyle.normal,
//                            fontWeight: FontWeight.bold),
//                      ),
//                    ),
//                  ],
//                ),
//                Container(
//                  padding: EdgeInsets.only(left: 20.0),
//                  child: Divider(
//                    color: Colors.deepPurple,
//                  ),
//                ),
//                _showEditCampaignButton(campaignModel),
//                _showJoinRequests(campaignModel),
//                _requestToJoin(campaignModel),
//                Padding(
//                  padding: EdgeInsets.only(top: 10.0, left: 20.0),
//                  child: Text(
//                    'Mission Statement',
//                    style: TextStyle(
//                      fontSize: 18.0,
//                      fontWeight: FontWeight.w700,
//                      decoration: TextDecoration.underline,
//                    ),
//                  ),
//                ),
//                Padding(
//                  padding: EdgeInsets.only(top: 10.0, left: 20.0),
//                  child: Text(
//                    campaignModel.missionStatement ?? '',
//                    style: TextStyle(fontSize: 18.0),
//                  ),
//                ),
//                Padding(
//                  padding: EdgeInsets.only(top: 20.0, left: 20.0),
//                  child: Text(
//                    'Address',
//                    style: TextStyle(
//                      fontSize: 18.0,
//                      fontWeight: FontWeight.w700,
//                      decoration: TextDecoration.underline,
//                    ),
//                  ),
//                ),
//                Padding(
//                  padding: EdgeInsets.only(top: 10.0, left: 20.0),
//                  child: Text(
//                    campaignModel.address,
//                    style: TextStyle(fontSize: 18.0),
//                  ),
//                ),
//                Padding(
//                  padding: EdgeInsets.only(top: 20.0, left: 20.0),
//                  child: Text(
//                    'Phone Number',
//                    style: TextStyle(
//                      fontSize: 18.0,
//                      fontWeight: FontWeight.w700,
//                      decoration: TextDecoration.underline,
//                    ),
//                  ),
//                ),
//                Padding(
//                  padding: EdgeInsets.only(left: 3.0),
//                  child: FlatButton(
//                    child: Text(
//                      campaignModel.primaryNumber,
//                      style: TextStyle(
//                          fontSize: 18.0, fontWeight: FontWeight.w400),
//                    ),
//                    onPressed: () {
//                      String _number = campaignModel.primaryNumber;
//                      launch('tel:$_number');
//                    },
//                  ),
//                ),
//                Padding(
//                  padding: EdgeInsets.only(top: 10.0, left: 20.0),
//                  child: Text(
//                    'Email',
//                    style: TextStyle(
//                      fontSize: 18.0,
//                      fontWeight: FontWeight.w700,
//                      decoration: TextDecoration.underline,
//                    ),
//                  ),
//                ),
//                Padding(
//                  padding: EdgeInsets.only(left: 3.0),
//                  child: FlatButton(
//                    child: Text(
//                      campaignModel.creatorEmail,
//                      style: TextStyle(
//                        fontSize: 18.0,
//                        fontWeight: FontWeight.w400,
//                      ),
//                    ),
//                    onPressed: () {
//                      String _email = campaignModel.primaryEmail;
//                      launch('mailto:$_email');
//                    },
//                  ),
//                ),
//                Padding(
//                  padding: EdgeInsets.all(20.0),
//                  child: Row(
//                    children: <Widget>[
//                      Text(
//                        'Member List',
//                        style: TextStyle(
//                            fontSize: 18.0, fontWeight: FontWeight.w700),
//                      ),
//                      _showManageMembersButton(campaignModel)
//                    ],
//                  ),
//                ),
//                FlatButton(
//                  onPressed: () {
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                        builder: (context) => ProfileViewer(
//                              userEmail: ownerModel.email,
//                            ),
//                      ),
//                    );
//                  },
//                  child: Row(
//                    children: <Widget>[
//                      Padding(
//                        padding: const EdgeInsets.only(
//                            left: 28.0, right: 8.0, top: 8.0, bottom: 8.0),
//                        child: CircleAvatar(
//                          // minRadius: 20.0,
//                          backgroundImage:
//                              ownerModel != null && ownerModel.photoUrl != null
//                                  ? NetworkImage(ownerModel.photoUrl)
//                                  : AssetImage(
//                                      'lib/assets/images/noimagefound.png'),
//                        ),
//                      ),
//                      Flexible(
//                        child: Container(
//                          padding: EdgeInsets.only(right: 13.0),
//                          child: Text(
//                            ownerModel == null
//                                ? 'Loading'
//                                : ownerModel.fullName ?? 'Loading',
//                            overflow: TextOverflow.ellipsis,
//                            style: TextStyle(
//                              fontSize: 18.0,
//                            ),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//                getTextWidgets(),
//              ],
//            ),
//          ),
//        ),
//      ),
//    );
//  }
}
