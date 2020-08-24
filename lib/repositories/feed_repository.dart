import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/news_model.dart';

class FeedsRepository {
  static Future<NewsModel> getFeedFromId(String newsId) async {
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
