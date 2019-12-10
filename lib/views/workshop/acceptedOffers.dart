import 'dart:ui' as prefix0;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/exchange/createrequest.dart';
import 'package:sevaexchange/views/exchange/help.dart';
import 'package:sevaexchange/views/exchange/select_request_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sevaexchange/views/core.dart';

import 'dart:ui';

import '../../flavor_config.dart';

class AcceptedOffers extends StatefulWidget {
  final String timebankId;

  AcceptedOffers({@required this.timebankId});

  AcceptedOffers.shareFeed({this.timebankId});

  @override
  State<StatefulWidget> createState() {
    return AcceptedOffersViewState();
  }
}

class AcceptedOffersViewState extends State<AcceptedOffers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Accepted Offers',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: <Widget>[],
      ),
      body: _ViewAcceptedOffers(
        timebankId: widget.timebankId,
      ),
    );
  }
}

class _ViewAcceptedOffers extends StatelessWidget {
  final String timebankId;

  _ViewAcceptedOffers({@required this.timebankId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OfferModel>>(
      stream: FirestoreManager.getOffersApprovedByAdmin(
        timebankId: timebankId,
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
            child: Text("No Offers accepted Yet"),
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
              userModel: user, model: model, context: parentContext);
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
                        )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                model.title,
                                style:
                                    Theme.of(parentContext).textTheme.subhead,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                model.description,
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Text(userModel.email),
                  ),
                  if (userModel.bio != null)
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Text(
                        "About ${userModel.fullname}",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(userModel.bio),
                  ),
                  Center(
                    child: Text(
                        "${userModel.fullname} will be automatically added to the campaign request.",
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
                            'Create Campaign Request',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        onPressed: () async {
                          // Once approved
                          print("UserModel ${userModel.fullname}");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateRequest(
                                  isOfferRequest: true,
                                  offer: model,
                                  timebankId: timebankId,
                                  userModel: userModel,),
                            ),
                          );

                          Navigator.pop(viewContext);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                      ),
                      RaisedButton(
                        child: Container(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                'Cancel',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red),
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
