import 'dart:convert';
import 'dart:ui' as prefix0;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart' as prefix1;
import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/profile/profile.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/workshop/MembersInvolved.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sevaexchange/views/core.dart';

import 'dart:ui';

import '../../flavor_config.dart';

class RequestStatusView extends StatefulWidget {
  final String requestId;

  RequestStatusView({@required this.requestId});

  @override
  State<StatefulWidget> createState() {
    return RequestStatusViewState();
  }
}

class RequestStatusViewState extends State<RequestStatusView> {
  Future<List<MemberForRequest>> membersInRequest;

  @override
  void initState() {
    super.initState();
    membersInRequest = fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(
            'Approved Members',
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0,
          actions: <Widget>[],
        ),
        body: Center(
            child: FutureBuilder<List<MemberForRequest>>(
          future: membersInRequest,
          builder: (builderContext, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: <Widget>[
                  ...snapshot.data.map((member) {
                    return getUserWidget(member, context);
                  }).toList()
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Error ${snapshot.error}');
            }
            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        )));
  }

  Widget getUserWidget(MemberForRequest userSelected, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileViewer(
                  userEmail: userSelected.email,
                )));
      },
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(userSelected.photourl),
          ),
          title: Text(
            userSelected.fullname,
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            userSelected.email,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Future<List<MemberForRequest>> fetchPost() async {
    final response = await http.post(
        'https://us-central1-sevaexchange.cloudfunctions.net/getApprovedMembers',
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"requestId": widget.requestId}));

    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      return responseJson.map((m) => MemberForRequest.fromJson(m)).toList();
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }
}
