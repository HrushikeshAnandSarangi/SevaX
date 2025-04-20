import 'package:sevaexchange/models/news_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class FeedsRepository {
  static Future<NewsModel?> getFeedFromId(String newsId) async {
    NewsModel? newsModel;
    await CollectionRef.feeds.doc(newsId).get().then((snapshot) {
      if (snapshot.data == null) return null;
      newsModel = NewsModel.fromMap(snapshot.data() as Map<String, dynamic>);
    });
    return newsModel;
  }
}
