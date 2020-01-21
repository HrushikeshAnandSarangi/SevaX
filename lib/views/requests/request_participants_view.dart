

import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';

class RequestParticipantsView extends StatefulWidget {

  final RequestModel requestModel;


  RequestParticipantsView({@required this.requestModel});

  @override
  _RequestParticipantsViewState createState() => _RequestParticipantsViewState();
}

class _RequestParticipantsViewState extends State<RequestParticipantsView> {

  var acceptors =[];
  var approvedMembers =[];
  HashMap<String, AcceptorItem> filteredList =HashMap();

  Future<dynamic> getUserDetails({String memberEmail}) async {
    var user = await Firestore.instance
        .collection("users")
        .document(memberEmail)
        .get();

    return user.data;
  }


  @override
  Widget build(BuildContext context) {
    acceptors=widget.requestModel.acceptors;
    approvedMembers=widget.requestModel.approvedUsers;

   /* acceptors.map(f){

    }

    approvedMembers.map(f){

    }*/

    return Container();
  }
}


class AcceptorItem {
  final String sevaUserID;
  final bool approved;

  AcceptorItem({this.sevaUserID, this.approved});


}
