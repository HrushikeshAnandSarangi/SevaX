import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class PaymentsApiProvider {
  Client client = Client();

  Future<bool> addCard(String token, String timebankid, bool isNegotiatedPlan,
      UserModel user, String planName) async {
    try {
      await CollectionRef.cards
          .doc(timebankid)
          .collection('tokens')
          .add({'tokenId': token});
      await CollectionRef.cards.doc(timebankid).set({
        'email': user.email,
        'timebankid': timebankid,
        'currentplan': planName,
        'isNegotiatedPlan': isNegotiatedPlan
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }
}
