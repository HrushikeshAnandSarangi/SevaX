import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'dart:async';

import 'package:sevaexchange/models/news_model.dart';

Future<void> createNews({@required NewsModel newsObject}) async {
  await Firestore.instance
      .collection('news')
      .document(newsObject.id)
      .setData(newsObject.toMap());
}

Stream<List<NewsModel>> getNewsStream() async* {
  var data = Firestore.instance
      .collection('news')
      .where('entity', isEqualTo: {
        'entityType': 'timebanks',
        'entityId': 'ajilo297@gmail.com*1559128156543',
        'entityName': 'Yang 2020',
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

Future<NewsModel> getNewsForId(String newsId) async {
  NewsModel newsModel;
  await Firestore.instance
      .collection('news')
      .document(newsId)
      .get()
      .then((snapshot) {
    if (snapshot.data == null) return null;
    newsModel = NewsModel.fromMap(snapshot.data);
  });

  return newsModel;
}
