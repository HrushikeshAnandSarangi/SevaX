import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:sevaexchange/models/models.dart';

class PaymentsApiProvider {
  Client client = Client();

  Future<bool> addCard(
      String token, String timebankid, bool isNegotiatedPlan, UserModel user, String planName) async {
    Firestore.instance
        .collection('cards')
        .document(timebankid)
        .collection('tokens')
        .add({'tokenId': token}).then((val) {});
    Firestore.instance.collection('cards').document(timebankid).setData({
      'email': user.email,
      'timebankid': timebankid,
      'currentplan': planName,
      'isNegotiatedPlan': isNegotiatedPlan
    }, merge: true);
  }
}
