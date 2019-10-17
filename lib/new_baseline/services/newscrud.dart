import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrudMethods {
  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addNews(newsData) async {
    if (isLoggedIn()) {
      Firestore.instance.collection('news').add(newsData).catchError((e) {
        log('addNews: error: $e');
      });
    }
  }

  getData() async {
    return Firestore.instance.collection('news').snapshots();
  }

  updateData(selectedDoc, newValues) {
    Firestore.instance
        .collection('news')
        .document(selectedDoc)
        .updateData(newValues)
        .catchError((e) {
    });
  }

  deleteData(docId) {
    Firestore.instance
        .collection('news')
        .document(docId)
        .delete()
        .catchError((e) {
    });
  }
}
