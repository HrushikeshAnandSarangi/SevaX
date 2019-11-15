import 'dart:ui' as prefix0;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
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
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigator.push(
          //   parentContext,
          //   MaterialPageRoute(
          //     builder: (context) => SelectRequestView(
          //       offerModel: model,
          //       sevaUserIdOffer: model.sevaUserId,
          //     ),
          //   ),
          // );
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
                  UserModel user = snapshot.data;
                  return ClipOval(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: FadeInImage.assetNetwork(
                          placeholder: 'lib/assets/images/profile.png',
                          image: user.photoURL),
                    ),
                  );
                },
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      model.title,
                      style: Theme.of(parentContext).textTheme.subhead,
                    ),
                    Text(
                      model.description,
                      style: Theme.of(parentContext).textTheme.subtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // /// Create a [chat]
  // Future<void> createChat({
  //   @required ChatModel chat,
  // }) async {
  //   // log.i('createChat: MessageModel: ${chat.toMap()}');
  //   chat.rootTimebank = FlavorConfig.values.timebankId;
  //   return Firestore.instance
  //       .collection('chatsnew')
  //       .document(chat.user1 +
  //           '*' +
  //           chat.user2 +
  //           '*' +
  //           FlavorConfig.values.timebankId)
  //       .setData(chat.toMap(), merge: true);
  // }

}
