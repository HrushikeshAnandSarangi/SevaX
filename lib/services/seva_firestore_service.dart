import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_model.dart';

final CollectionReference newsCollection =
    Firestore.instance.collection('news');

class SevaFirestoreService {
  static final SevaFirestoreService _instance =
      new SevaFirestoreService.internal();

  factory SevaFirestoreService() => _instance;

  SevaFirestoreService.internal();

  Future<NewsModel> createNews(String title, String description) async {
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(newsCollection.document());

      final NewsModel news =
          NewsModel(id: ds.documentID, title: title, description: description);
      final Map<String, dynamic> data = news.toMap();

      await tx.set(ds.reference, data);

      return data;
    };

    return Firestore.instance.runTransaction(createTransaction).then((mapData) {
      return NewsModel.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
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
      final DocumentSnapshot ds =
          await tx.get(newsCollection.document(news.id));

      await tx.update(ds.reference, news.toMap());
      return {'updated': true};
    };

    return Firestore.instance
        .runTransaction(updateTransaction)
        .then((result) => result['updated'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }

  Future<dynamic> deleteNews(String id) async {
    final TransactionHandler deleteTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(newsCollection.document(id));

      await tx.delete(ds.reference);
      return {'deleted': true};
    };

    return Firestore.instance
        .runTransaction(deleteTransaction)
        .then((result) => result['deleted'])
        .catchError((error) {
      print('error: $error');
      return false;
    });
  }
}
