import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/admin_personal_requests_view.dart';

import 'admin_offer_requests_tab.dart';

class AcceptedOffers extends StatefulWidget {
  final String sevaUserId;
  final String timebankId;

  AcceptedOffers({@required this.sevaUserId, @required this.timebankId});

  // AcceptedOffers.shareFeed({this.timebankId});

  @override
  State<StatefulWidget> createState() {
    return AcceptedOffersViewState();
  }
}

class AcceptedOffersViewState extends State<AcceptedOffers> {
  TimebankModel timebankModel = TimebankModel({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("time id --- ${widget.timebankId}");

    FirestoreManager.getTimebankModelStream(timebankId: widget.timebankId)
        .listen((onValue) {
      timebankModel = onValue;
      print("toimeppppp --- ${timebankModel}");
    });
    setState(() {});

    // timeBankBloc.getRequestsStreamFromTimebankId(widget.timebankId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Accepted Offers',
      //     style: TextStyle(fontSize: 18),
      //   ),
      //   elevation: 0,
      //   actions: <Widget>[],
      // ),
      body: _ViewAcceptedOffers(
        sevaUserId: widget.sevaUserId,
        timebankId: widget.timebankId,
        timebankModel: timebankModel,
      ),
    );
  }
}

class _ViewAcceptedOffers extends StatelessWidget {
  final String sevaUserId;
  final String timebankId;
  final TimebankModel timebankModel;

  _ViewAcceptedOffers(
      {@required this.sevaUserId,
      @required this.timebankId,
      this.timebankModel});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OfferModel>>(
      stream: FirestoreManager.getOffersApprovedByAdmin(
        sevaUserId: sevaUserId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        var acceptedOffersList = snapshot.data;

        if (acceptedOffersList.length > 0) {
          return ListView(
            children: <Widget>[
              ...acceptedOffersList.map((element) {
                return getOfferViewHolder(element, context);
              }).toList()
            ],
          );
        } else {
          return Center(
            child: Text("No offer accepted"),
          );
        }
      },
    );
  }

  Widget getOfferViewHolder(OfferModel model, BuildContext parentContext) {
    UserModel user;
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          showDialogForMakingAnOffer(
              userModel: user,
              model: model,
              context: parentContext,
              timebankId: timebankId);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder<UserModel>(
                stream: FirestoreManager.getUserForIdStream(
                  sevaUserId: model.sevaUserId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return CircleAvatar(foregroundColor: Colors.red);
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircleAvatar();
                  }

                  user = snapshot.data;

                  return Expanded(
                    child: Row(
                      children: <Widget>[
                        ClipOval(
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: FadeInImage.assetNetwork(
                                placeholder: 'lib/assets/images/profile.png',
                                image: user.photoURL),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                getOfferTitle(offerDataModel: model),
                                style:
                                    Theme.of(parentContext).textTheme.subhead,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                getOfferDescription(offerDataModel: model),
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(parentContext).textTheme.subtitle,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  );

                  // return Card(
                  //   child: ListTile(
                  //     leading: CircleAvatar(
                  //       backgroundImage: NetworkImage(user.photoURL),
                  //     ),
                  //     title: Text(user.fullname),
                  //     subtitle: Text(user.email),
                  //   ),
                  // );

                  // return Card(
                  //   child: ListTile(
                  //     leading: ClipOval(
                  //       child: FadeInImage.assetNetwork(
                  //         placeholder: 'lib/assets/images/profile.png',
                  //         image: user.photoURL,
                  //       ),
                  //     ),
                  //     onTap: () {},
                  //   ),
                  // );

                  // return ClipOval(
                  //   child: SizedBox(
                  //     height: 40,
                  //     width: 40,
                  //     child: FadeInImage.assetNetwork(
                  //         placeholder: 'lib/assets/images/profile.png',
                  //         image: user.photoURL),
                  //   ),
                  // );
                },
              ),
              // SizedBox(width: 16),
              // Expanded(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: <Widget>[
              //       Text(
              //         model.title,
              //         style: Theme.of(parentContext).textTheme.subhead,
              //       ),
              //       Text(
              //         model.description,
              //         style: Theme.of(parentContext).textTheme.subtitle,
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void showDialogForMakingAnOffer({
    UserModel userModel,
    OfferModel model,
    BuildContext context,
    String timebankId,
  }) {
    // show dialog here for new offer;
    showDialog(
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
                      userModel.fullname,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (userModel.bio != null)
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Text(
                        "About ${userModel.fullname}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  getBio(userModel),
                  Center(
                    child: Text(
                        "${userModel.fullname} will be automatically added to the request.",
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
                      RaisedButton(
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            'Create Request',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onPressed: () async {
                          // Once approved
                          print("UserModel ${userModel.fullname}");
                          Navigator.pop(viewContext);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateRequest(
                                isOfferRequest: true,
                                offer: model,
                                timebankId: timebankId,
                                userModel: userModel,
                                projectId: "",
                              ),
                            ),
                          );

                          // if (results != null &&
                          //     (results['response'] == "ACCEPTED" ||
                          //         results['response'] == "SKIPPED")) {
                          //   Navigator.pop(context);
                          // }
                        },
                      ),

//                      Padding(
//                        padding: EdgeInsets.all(8.0),
//                      ),
                      RaisedButton(
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            'Add to Existing Request',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onPressed: () async {
                          // Once approved
                          print("UserModel ${userModel.sevaUserID}");
                          print("admint ${timebankModel.admins}");
                          Navigator.pop(viewContext);
                          if (timebankModel.admins.contains(
                              SevaCore.of(context).loggedInUser.sevaUserID)) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminOfferRequestsTab(
                                  timebankid: timebankId,
                                  parentContext: context,
                                  userModel: userModel,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminPersonalRequests(
                                  timebankId: timebankId,
                                  isTimebankRequest: true,
                                  parentContext: context,
                                  userModel: userModel,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      RaisedButton(
                        color: Theme.of(context).accentColor,
                        child: Container(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                'Cancel',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                        onPressed: () async {
                          // request declined
                          Navigator.pop(viewContext);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget getBio(UserModel userModel) {
    if (userModel.bio != null) {
      if (userModel.bio.length < 100) {
        return Container(
          margin: EdgeInsets.all(8),
          child: Center(
            child: Text(
              userModel.bio,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return Container(
        margin: EdgeInsets.all(8),
        height: 100,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Text(
            userModel.bio,
            maxLines: null,
            overflow: null,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text("Bio not yet updated"),
    );
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
}
