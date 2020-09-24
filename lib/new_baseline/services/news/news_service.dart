import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/models/models.dart';

class NewsService {
  Future<void> updateFeedComments({
    @required String feedId,
    @required Comments comment,
  }) async {
    return await Firestore.instance
        .collection('news')
        .document(feedId)
        .setData({"comments": []});
  }

  Future<void> updateFeedById({
    @required NewsModel newsModel,
  }) async {
    print(newsModel.id);
    return await Firestore.instance
        .collection('news')
        .document(newsModel.id)
        .updateData(newsModel.toMap());
  }

  Future<void> updateFeed({
    @required NewsModel newsModel,
  }) async {
    return await Firestore.instance
        .collection('news')
        .document(newsModel.id)
        .updateData(newsModel.toMap());
  }

  Future<void> updateFeedLikes({
    @required NewsModel newsModel,
  }) async {
    // log.i('updateUser: UserModel: $user');
    return await Firestore.instance
        .collection('news')
        .document(newsModel.id)
        .updateData({'likes': newsModel.likes});
  }

  Stream<List<Comments>> getAllComments(String id) async* {
    // log.i('getNewsStream: ');
    var data = Firestore.instance
        .collection('comments')
        .where("feedId", isEqualTo: id)
        .orderBy('createdAt', descending: true)
        .snapshots();

    yield* data.transform(
        StreamTransformer<QuerySnapshot, List<Comments>>.fromHandlers(
            handleData: (querySnapshot, commentSink) {
      List<Comments> modelList = [];
      querySnapshot.documents.forEach((document) {
        Comments comment = Comments.fromMap(document.data);
        print(comment.comment);
        modelList.add(Comments.fromMap(document.data));
      });
      commentSink.add(modelList);
    }));
  }

  Stream<List<Comments>> getCommentsListByFeedId(String id) async* {
    // log.i('getNewsStream: ');
    var data = Firestore.instance
        .collection('news')
        .where("id", isEqualTo: id)
        // .orderBy('createdAt', descending: true)
        .snapshots();

    yield* data.transform(
        StreamTransformer<QuerySnapshot, List<Comments>>.fromHandlers(
            handleData: (querySnapshot, commentSink) {
      List<Comments> modelList = [];

      querySnapshot.documents.forEach((document) {
        NewsModel feed = NewsModel.fromMap(document.data);
        feed.comments.forEach((comment) {
          print("This is comment text ${comment.comment.toString()}");
          modelList.add(Comments.fromMap(document.data));
        });
      });
      commentSink.add(modelList);
    }));
  }

  Stream<NewsModel> getCommentsByFeedId({@required String id}) async* {
    assert(id != null && id.isNotEmpty, "Seva UserId cannot be null or empty");
    var data = Firestore.instance
        .collection('news')
        .where("id", isEqualTo: id)
        // .orderBy('createdAt', descending: true)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, NewsModel>.fromHandlers(
        handleData: (snapshot, userSink) async {
          if (snapshot.documents.isNotEmpty) {
            DocumentSnapshot documentSnapshot = snapshot.documents?.first;
            NewsModel model = NewsModel.fromMap(documentSnapshot.data);
            model.id = id;
            userSink.add(model);
          }
        },
      ),
    );
  }

//  Stream<NewsModel> getCommentsByFeedId({@required String id}) async* {
//    assert(id != null && id.isNotEmpty, "Seva UserId cannot be null or empty");
//    var data = Firestore.instance
//        .collection('news')
//        .where("id", isEqualTo: id)
//        // .orderBy('createdAt', descending: true)
//        .snapshots();
//
//    yield* data.transform(
//      StreamTransformer<QuerySnapshot, NewsModel>.fromHandlers(
//        handleData: (snapshot, userSink) async {
//          DocumentSnapshot documentSnapshot = snapshot.documents[0];
//          NewsModel model = NewsModel.fromMap(documentSnapshot.data);
//          print("test............");
//          print(model.toString());
//          model.id = id;
//          userSink.add(model);
//        },
//      ),
//    );
//  }
}
