import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class NewsService {
  Future<void> updateFeedComments({
    required String feedId,
    required Comments comment,
  }) async {
    return await CollectionRef.feeds.doc(feedId).set({"comments": []});
  }

  Future<void> updateFeedById({
    required NewsModel newsModel,
  }) async {
    return await CollectionRef.feeds
        .doc(newsModel.id)
        .update(newsModel.toMap());
  }

  Future<void> updateFeed({
    required NewsModel newsModel,
  }) async {
    return await CollectionRef.feeds
        .doc(newsModel.id)
        .update(newsModel.toMap());
  }

  Future<void> updateFeedLikes({
    required NewsModel newsModel,
  }) async {
    // log.i('updateUser: UserModel: $user');
    return await CollectionRef.feeds
        .doc(newsModel.id)
        .update({'likes': newsModel.likes});
  }

  Stream<List<Comments>> getAllComments(String id) async* {
    // log.i('getNewsStream: ');
    var data = FirebaseFirestore.instance
        .collection("comments")
        .where("feedId", isEqualTo: id)
        .orderBy('createdAt', descending: true)
        .snapshots();

    yield* data.transform(StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
        List<Comments>>.fromHandlers(handleData: (querySnapshot, commentSink) {
      List<Comments> modelList = [];
      querySnapshot.docs.forEach((document) {
        modelList.add(Comments.fromMap(document.data()));
      });
      commentSink.add(modelList);
    }));
  }

  Stream<List<Comments>> getCommentsListByFeedId(String id) async* {
    // log.i('getNewsStream: ');
    var data = CollectionRef.feeds
        .where("id", isEqualTo: id)
        // .orderBy('createdAt', descending: true)
        .snapshots();

    yield* data.transform(
        StreamTransformer<QuerySnapshot, List<Comments>>.fromHandlers(
            handleData: (querySnapshot, commentSink) {
      List<Comments> modelList = [];

      querySnapshot.docs.forEach((document) {
        NewsModel feed =
            NewsModel.fromMap(document.data() as Map<String, dynamic>);
        feed.comments?.forEach((comment) {
          modelList
              .add(Comments.fromMap(document.data() as Map<String, dynamic>));
        });
      });
      commentSink.add(modelList);
    }));
  }

  Stream<NewsModel> getCommentsByFeedId({required String id}) async* {
    assert(id != null && id.isNotEmpty, "Seva UserId cannot be null or empty");
    var data = CollectionRef.feeds
        .where("id", isEqualTo: id)
        // .orderBy('createdAt', descending: true)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, NewsModel>.fromHandlers(
        handleData: (snapshot, userSink) async {
          if (snapshot.docs.isNotEmpty) {
            QueryDocumentSnapshot documentSnapshot = snapshot.docs.first;
            NewsModel model = NewsModel.fromMap(
                documentSnapshot.data() as Map<String, dynamic>);
            model.id = id;
            userSink.add(model);
          }
        },
      ),
    );
  }

//  Stream<NewsModel> getCommentsByFeedId({@required String id}) async* {
//    assert(id != null && id.isNotEmpty, "Seva UserId cannot be null or empty");
//    var data = CollectionRef
//        .feeds
//        .where("id", isEqualTo: id)
//        // .orderBy('createdAt', descending: true)
//        .snapshots();
//
//    yield* data.transform(
//      StreamTransformer<QuerySnapshot, NewsModel>.fromHandlers(
//        handleData: (snapshot, userSink) async {
//          DocumentSnapshot documentSnapshot = snapshot.documents[0];
//          NewsModel model = NewsModel.fromMap(documentSnapshot.data());
//
//
//          model.id = id;
//          userSink.add(model);
//        },
//      ),
//    );
//  }
}
