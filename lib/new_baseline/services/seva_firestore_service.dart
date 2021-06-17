import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

import '../models/news_model.dart';

final CollectionReference newsCollection = CollectionRef.feeds;

class SevaFirestoreService {
  static final SevaFirestoreService _instance = SevaFirestoreService.internal();

  factory SevaFirestoreService() => _instance;

  SevaFirestoreService.internal();

  Future<NewsModel> createNews(String title, String description) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(newsCollection.doc());

      final NewsModel news =
          NewsModel(id: ds.id, title: title, description: description);
      final Map<String, dynamic> data = news.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return FirebaseFirestore.instance
        .runTransaction(createTransaction)
        .then((mapData) {
      return NewsModel.fromMap(mapData);
    }).catchError((error) {
      log('error: $error');
      return null;
    });
  }

  Stream<QuerySnapshot> getNewsList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = newsCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Future<dynamic> updateNews(NewsModel news) async {
    final TransactionHandler updateTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(newsCollection.doc(news.id));

      await tx.update(ds.reference, news.toMap());
      return {'updated': true};
    };

    return FirebaseFirestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      log('error: $error');
      return false;
    });
  }

  Future<dynamic> deleteNews(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(newsCollection.doc(id));

      await tx.delete(ds.reference);
      return {'deleted': true};
    };

    return FirebaseFirestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      log('error: $error');
      return false;
    });
  }
}
