import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/campaign_model.dart';
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';

class ReviewLandingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ReviewLandingPageState();
}

String textView = "Approve Transaction";


Stream<List<NewsModel>> getNewsStream({@required String timebankID}) async* {
  var data = Firestore.instance
      .collection('news')
      .where('entity', isEqualTo: {
        'entityType': 'timebanks',
        'entityId': timebankID,
        //'entityName': FlavorConfig.timebankName,
      })
      .orderBy('posttimestamp', descending: true)
      .snapshots();

  yield* data.transform(
      StreamTransformer<QuerySnapshot, List<NewsModel>>.fromHandlers(
          handleData: (querySnapshot, newsSink) {
    List<NewsModel> modelList = [];
    querySnapshot.documents.forEach((document) {
      modelList.add(NewsModel.fromMap(document.data));
    });
    newsSink.add(modelList);
  }));
}


class ReviewLandingPageState extends State<ReviewLandingPage> {
  @override
  Widget build(BuildContext context) {
    print("inside-------------------------------------------");

    getNewsStream( 
      timebankID: "ef9069a6-2e9b-4bae-b474-d0cfe206877f"
    );

    var query = Firestore.instance
        .collection("reviews")
        .where("user_id", isEqualTo: "burhan@uipep.com")
        // .where("requestId", isEqualTo: "requestId")
        .snapshots();

        query.transform(
          StreamTransformer<QuerySnapshot, ReviewModel>.fromHandlers(
            handleData: (snapshot, userSink) async {
              print("inside-------------------------------------------");
            },
          ),
        );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Review Landing"),
        ),
        body: RaisedButton(
          child: Text(textView),
          onPressed: pushNavigator,
        ),
      ),
    );
  }

  Future pushNavigator() async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return ReviewFeedback.forVolunteer(
          forVolunteer: false,
        );
      },
    ));

    if (results != null && results.containsKey('selection')) {
      setState(() {
        textView = "Ratings : " +
            results['selection'].toString() +
            "\n" +
            (results['didComment'] ? results['comment'] : "No comments");
      });
    } else {
      setState(() {
        textView = "User cancelled";
      });
    }
  }
}

class ReviewModel {
  double ratings;
  String req_Id;
  String comments;
  String user_id;

  String toString(){
    return "Ratings ${ratings} \n" + 
            "RequestId ${req_Id} \n" + 
            "Comments ${comments} \n" + 
            "UserID ${user_id} \n" + 
            "Ratings ${ratings} \n" ; 
  }

}
