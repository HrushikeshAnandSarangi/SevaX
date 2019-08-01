import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/base/base_service.dart';
import 'dart:async';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/news_model.dart';

class NewsService extends BaseService {
  /// create a [newsObject]
  Future<void> createNews({@required NewsModel newsObject}) async {
    log.i('createNews: newsObject: ${newsObject.toMap()}');
    await Firestore.instance
        .collection('news')
        .document(newsObject.id)
        .setData(newsObject.toMap());
  }
  /// update a [newsObject]
  Future<void> updateNews({@required NewsModel newsObject}) async {
    log.i('updateNews: newsObject: ${newsObject.toMap()}');
    await Firestore.instance
        .collection('news')
        .document(newsObject.id)
        .updateData(newsObject.toMap());
  }

  /// get a stream of news in [newsSink]
  Stream<List<NewsModel>> getNewsStream() async* {
    log.i('getNewsStream: ');
    var data = Firestore.instance
        .collection('news')
        .where('entity', isEqualTo: {
          'entityType': 'timebanks',
          'entityId': FlavorConfig.timebankId,
          'entityName': FlavorConfig.timebankName,
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

  /// get [newsModel] for a [newsId]
  Future<NewsModel> getNewsForId(String newsId) async {
    log.i('getNewsForId: newsId: $newsId');
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
}
