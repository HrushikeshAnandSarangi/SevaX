import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:sevaexchange/models/data_model.dart';

class NewsModel extends DataModel {
  String? id;
  String? title;
  String? subheading;
  String? description;
  String? email;
  String? fullName;
  String? sevaUserId;
  String? communityId;
  String? newsImageUrl;
  String? newsDocumentUrl;
  String? newsDocumentName;
  String? photoCredits;
  int? postTimestamp;
  GeoFirePoint? location;
  EntityModel? entity;
  List<String>? likes;
  List<String>? reports;
  String? root_timebank_id;
  String? placeAddress;
  bool? isPinned;
  bool? softDelete;
  List<Comments>? comments = [];
  List<String>? urlsFromPost = [];
  List<String>? hashTags = [];

  String? userPhotoURL;
  String? imageScraped = "NoData";
  List<String>? timebanksPosted = [];
  bool? liveMode;

  NewsModel({
    this.id,
    this.title,
    this.subheading,
    this.description,
    this.email,
    this.fullName,
    this.sevaUserId,
    this.communityId,
    this.newsImageUrl,
    this.photoCredits,
    this.postTimestamp,
    this.location,
    this.entity,
    this.likes,
    this.reports,
    this.root_timebank_id,
    this.isPinned,
    this.userPhotoURL,
    this.newsDocumentName,
    this.newsDocumentUrl,
    this.softDelete,
    this.timebanksPosted,
    this.comments,
    this.liveMode,
  });

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (this.title != null) {
      map['title'] = this.title;
    }
    if (this.softDelete != null) {
      map['softDelete'] = this.softDelete;
    }

    if (this.description != null) {
      map['description'] = this.description;
    }

    if (this.subheading != null && this.subheading?.isNotEmpty == true) {
      map['subheading'] = this.subheading;
    }

    if (this.urlsFromPost != null) {
      map['urlsFromPost'] = this.urlsFromPost;
    }

    if (this.hashTags != null) {
      map['hashTags'] = this.hashTags;
    }

    if (this.placeAddress != null) {
      map['placeAddress'] = placeAddress;
    }

    if (this.userPhotoURL != null) {
      map['userPhotoURL'] = userPhotoURL;
    }

    if (this.imageScraped != null) {
      map['imageScraped'] = this.imageScraped;
    }

    if (this.root_timebank_id != null &&
        this.root_timebank_id?.isNotEmpty == true) {
      map['root_timebank_id'] = this.root_timebank_id;
    }
    if (this.id != null && this.id!.isNotEmpty) {
      map['id'] = this.id;
    }
    if (this.email != null && this.email?.isNotEmpty == true) {
      map['email'] = this.email;
    }
    if (this.fullName != null && this.fullName?.isNotEmpty == true) {
      map['fullname'] = this.fullName;
    }
    if (this.sevaUserId != null && this.sevaUserId?.isNotEmpty == true) {
      map['sevauserid'] = this.sevaUserId;
    }

    if (this.communityId != null && this.communityId?.isNotEmpty == true) {
      map['communityId'] = this.communityId;
    }
    if (this.newsImageUrl != null && this.newsImageUrl?.isNotEmpty == true) {
      map['newsimageurl'] = this.newsImageUrl;
    } else {
      map['newsimageurl'] = null;
    }
    if (this.photoCredits != null && this.photoCredits?.isNotEmpty == true) {
      map['photocredits'] = this.photoCredits;
    }
    if (this.postTimestamp != null) {
      map['posttimestamp'] = this.postTimestamp;
    }
    if (this.location != null) {
      map['location'] = this.location?.data;
    }

    if (this.isPinned != null) {
      map['pinned'] = this.isPinned;
    }
    if (this.entity != null) {
      map['entity'] = this.entity?.toMap();
    }
    if (this.likes != null) {
      map['likes'] = this.likes;
    } else
      map['likes'] = [];

    if (this.reports != null) {
      map['reports'] = this.reports;
    } else
      map['reports'] = [];

    if (this.timebanksPosted != null) {
      map['timebanksposted'] = this.timebanksPosted;
    } else
      map['timebanksposted'] = [];

    if (this.comments != null && this.comments?.isNotEmpty == true) {
      map['comments'] = List<dynamic>.from(comments!.map((x) => x.toMap()));
    } else {
      map['comments'] = [];
    }
    if (this.newsDocumentName != null &&
        this.newsDocumentName?.isNotEmpty == true) {
      map['newsDocumentName'] = this.newsDocumentName;
    } else {
      map['newsDocumentName'] = null;
    }
    if (this.newsDocumentUrl != null &&
        this.newsDocumentUrl?.isNotEmpty == true) {
      map['newsDocumentUrl'] = this.newsDocumentUrl;
    } else {
      map['newsDocumentUrl'] = null;
    }
    if (this.liveMode != null) {
      map['liveMode'] = this.liveMode;
    }
    return map;
  }

  NewsModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('imageScraped')) {
      this.imageScraped = map['imageScraped'];
    }

    if (map.containsKey('urlsFromPost')) {
      List<String> urlsFromPost = List.castFrom(map['urlsFromPost']);
      this.urlsFromPost = urlsFromPost;
    } else
      this.urlsFromPost = [];

    if (map.containsKey('hashTags')) {
      List<String> hashTags = List.castFrom(map['hashTags']);
      this.hashTags = hashTags;
    } else
      this.hashTags = [];

    if (map.containsKey('id')) {
      this.id = map['id'];
    }
    if (map.containsKey('title')) {
      this.title = map['title'];
    }
    if (map.containsKey('root_timebank_id')) {
      this.root_timebank_id = map['root_timebank_id'];
    }

    if (map.containsKey('placeAddress')) {
      this.placeAddress = map['placeAddress'];
    }

    if (map.containsKey('pinned')) {
      this.isPinned = map['pinned'];
    } else {
      this.isPinned = false;
    }

    if (map.containsKey('subheading')) {
      this.subheading = map['subheading'];
    }

    if (map.containsKey('description')) {
      this.description = map['description'];
    }
    if (map.containsKey('email')) {
      this.email = map['email'];
    }

    if (map.containsKey('fullname')) {
      this.fullName = map['fullname'];
    }
    if (map.containsKey('sevauserid')) {
      this.sevaUserId = map['sevauserid'];
    }
    if (map.containsKey('communityId')) {
      this.communityId = map['communityId'];
    }
    if (map.containsKey('newsimageurl')) {
      this.newsImageUrl = map['newsimageurl'];
    }

    if (map.containsKey('newsDocumentUrl')) {
      this.newsDocumentUrl = map['newsDocumentUrl'];
    }

    if (map.containsKey('newsDocumentName')) {
      this.newsDocumentName = map['newsDocumentName'];
    }

    if (map.containsKey('userPhotoURL')) {
      this.userPhotoURL = map['userPhotoURL'];
    }
    if (map.containsKey('photocredits')) {
      this.photoCredits = map['photocredits'];
    }
    if (map.containsKey('posttimestamp')) {
      this.postTimestamp = map['posttimestamp'];
    }
    if (map.containsKey('location')) {
      GeoPoint geoPoint = map['location']['geopoint'];
      this.location =
          GeoFirePoint(GeoPoint(geoPoint.latitude, geoPoint.longitude));
    }

    if (map.containsKey('entity')) {
      Map<String, dynamic> dataMap = Map.castFrom(map['entity']);
      this.entity = EntityModel.fromMap(dataMap);
    }

    if (map.containsKey('likes')) {
      List<String> likesList = List.castFrom(map['likes']);
      this.likes = likesList;
    } else
      this.likes = [];

    if (map.containsKey('reports')) {
      List<String> likesList = List.castFrom(map['reports']);
      this.reports = likesList;
    } else
      this.reports = [];

    if (map.containsKey('timebanksposted')) {
      List<String> timebanksPosted = List.castFrom(map['timebanksposted']);
      this.timebanksPosted = timebanksPosted;
    } else
      this.timebanksPosted = [];

    if (map.containsKey('comments')) {
      List<Comments> commentsList = [];
      List commentsDataList = List.castFrom(map['comments']);

      commentsList = commentsDataList.map<Comments>((data) {
        Map<String, dynamic> commentsmap = Map.castFrom(data);
        return Comments.fromMap(commentsmap);
      }).toList();

      this.comments = commentsList;
    }
    if (map.containsKey('liveMode')) {
      this.liveMode = map['liveMode'];
    } else {
      this.liveMode = true;
    }
  }

  NewsModel.fromMapElasticSearch(Map<String, dynamic> map) {
    if (map.containsKey('imageScraped')) {
      this.imageScraped = map['imageScraped'];
    }

    if (map.containsKey('urlsFromPost')) {
      List<String> urlsFromPost = List.castFrom(map['urlsFromPost']);
      this.urlsFromPost = urlsFromPost;
    } else
      this.urlsFromPost = [];

    if (map.containsKey('hashTags')) {
      List<String> hashTags = List.castFrom(map['hashTags']);
      this.hashTags = hashTags;
    } else
      this.hashTags = [];

    if (map.containsKey('id')) {
      this.id = map['id'];
    }
    if (map.containsKey('userPhotoURL')) {
      this.userPhotoURL = map['userPhotoURL'];
    }
    if (map.containsKey('title')) {
      this.title = map['title'];
    }
    if (map.containsKey('root_timebank_id')) {
      this.root_timebank_id = map['root_timebank_id'];
    }
    if (map.containsKey('placeAddress')) {
      this.placeAddress = map['placeAddress'];
    }

    if (map.containsKey('subheading')) {
      this.subheading = map['subheading'];
    }

    if (map.containsKey('description')) {
      this.description = map['description'];
    }
    if (map.containsKey('pinned')) {
      this.isPinned = map['pinned'];
    } else {
      this.isPinned = false;
    }
    if (map.containsKey('email')) {
      this.email = map['email'];
    }
    if (map.containsKey('fullname')) {
      this.fullName = map['fullname'];
    }
    if (map.containsKey('sevauserid')) {
      this.sevaUserId = map['sevauserid'];
    }

    if (map.containsKey('communityId')) {
      this.sevaUserId = map['communityId'];
    }
    if (map.containsKey('newsimageurl')) {
      this.newsImageUrl = map['newsimageurl'];
    }

    if (map.containsKey('newsDocumentUrl')) {
      this.newsDocumentUrl = map['newsDocumentUrl'];
    }

    if (map.containsKey('newsDocumentName')) {
      this.newsDocumentName = map['newsDocumentName'];
    }
    if (map.containsKey('photocredits')) {
      this.photoCredits = map['photocredits'];
    }
    if (map.containsKey('posttimestamp')) {
      this.postTimestamp = map['posttimestamp'];
    }
    if (map.containsKey('location')) {
      GeoPoint geoPoint = GeoPoint(map['location']['geopoint']['_latitude'],
          map['location']['geopoint']['_longitude']);
      this.location =
          GeoFirePoint(GeoPoint(geoPoint.latitude, geoPoint.longitude));
    }

    if (map.containsKey('entity')) {
      Map<String, dynamic> dataMap = Map.castFrom(map['entity']);
      this.entity = EntityModel.fromMap(dataMap);
    }

    if (map.containsKey('likes')) {
      List<String> likesList = List.castFrom(map['likes']);
      this.likes = likesList;
    } else
      this.likes = [];

    if (map.containsKey('reports')) {
      List<String> likesList = List.castFrom(map['reports']);
      this.reports = likesList;
    } else
      this.reports = [];

    if (map.containsKey('timebanksposted')) {
      List<String> timebanksPosted = List.castFrom(map['timebanksposted']);
      this.timebanksPosted = timebanksPosted;
    } else
      this.timebanksPosted = [];

    if (map.containsKey('comments')) {
      List<Comments> commentsList = [];
      List commentsDataList = List.castFrom(map['comments']);

      commentsList = commentsDataList.map<Comments>((data) {
        Map<String, dynamic> commentsmap = Map.castFrom(data);
        return Comments.fromMap(commentsmap);
      }).toList();

      this.comments = commentsList;
    }
    if (map.containsKey('liveMode')) {
      this.liveMode = map['liveMode'];
    } else {
      this.liveMode = true;
    }
  }

  @override
  String toString() {
    return 'NewsModel{id: $id, title: $title, subheading: $subheading, description: $description, email: $email,liveMode: $liveMode, fullName: $fullName, sevaUserId: $sevaUserId, newsImageUrl: $newsImageUrl, photoCredits: $photoCredits, postTimestamp: $postTimestamp, location: $location, entity: $entity, likes: $likes, reports: $reports, comments: $comments, timebanksPosted: $timebanksPosted, root_timebank_id: $root_timebank_id, placeAddress: $placeAddress, isPinned: $isPinned, urlsFromPost: $urlsFromPost, hashTags: $hashTags, userPhotoURL: $userPhotoURL, imageScraped: $imageScraped}';
  }
}

class EntityModel extends DataModel {
  String? entityId;
  String? entityName;
  EntityType? entityType;

  EntityModel({this.entityType, this.entityId, this.entityName});

  EntityModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('entityId')) {
      this.entityId = map['entityId'];
    }

    if (map.containsKey('entityName')) {
      this.entityName = map['entityName'];
    }

    if (map.containsKey('entityType')) {
      String entityTypeString = map['entityType'];
      switch (entityTypeString) {
        case 'timebanks':
          this.entityType = EntityType.timebank;
          break;
        case 'campaigns':
          this.entityType = EntityType.campaign;
          break;
        case 'general':
          this.entityType = EntityType.general;
          break;
        default:
          this.entityType = EntityType.general;
          break;
      }
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> obj = {};

    if (this.entityId != null && this.entityId!.isNotEmpty) {
      obj['entityId'] = this.entityId;
    }

    if (this.entityName != null && this.entityName!.isNotEmpty) {
      obj['entityName'] = this.entityName;
    }

    if (this.entityType != null) {
      switch (this.entityType) {
        case EntityType.campaign:
          obj['entityType'] = 'campaigns';
          break;
        case EntityType.timebank:
          obj['entityType'] = 'timebanks';
          break;
        case EntityType.general:
          obj['entityType'] = 'general';
          break;
        default:
          obj['entityType'] = 'general';
          break;
      }
    } else {
      obj['entityType'] = 'general';
    }

    return obj;
  }
}

enum EntityType { timebank, campaign, general }

class Comments extends DataModel {
  String? userPhotoURL; // create photo URL
  String? createdEmail;
  String? fullName;
  String? comment;
  String? feedId;
  List<String>? mentions = []; // user ids for future.
  List<Comments>? comments = [];
  List<String>? likes = [];
  int? createdAt;

  Comments({
    this.userPhotoURL,
    this.createdEmail,
    this.fullName,
    this.comment,
    this.feedId,
    this.mentions,
    this.comments,
    this.likes,
    this.createdAt,
  }) {}

  Comments.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('userPhotoURL')) {
      this.userPhotoURL = map['userPhotoURL'];
    }
    if (map.containsKey('createdEmail')) {
      this.createdEmail = map['createdEmail'];
    }
    if (map.containsKey('fullName')) {
      this.fullName = map['fullName'];
    }
    if (map.containsKey('comment')) {
      this.comment = map['comment'];
    }
    if (map.containsKey('feedId')) {
      this.feedId = map['feedId'];
    }
    if (map.containsKey('createdAt')) {
      this.createdAt = map['createdAt'];
    }
    if (map.containsKey('mentions')) {
      List<String> mentions = List.castFrom(map['mentions']);
      this.mentions = mentions;
    } else {
      this.mentions = [];
    }
    if (map.containsKey('comments')) {
      List<Comments> commentsList = [];
      List commentsDataList = List.castFrom(map['comments']);

      commentsList = commentsDataList.map<Comments>((data) {
        Map<String, dynamic> commentsmap = Map.castFrom(data);
        return Comments.fromMap(commentsmap);
      }).toList();

      this.comments = commentsList;
    } else {
      this.comments = [];
    }

    if (map.containsKey('likes')) {
      List<String> likesList = List.castFrom(map['likes']);
      this.likes = likesList;
    } else
      this.likes = [];
  }

  @override
  String toString() {
    return 'Comments{userPhotoURL: $userPhotoURL, createdEmail: $createdEmail, fullName: $fullName, comment: $comment, feedId: $feedId, mentions: $mentions, comments: $comments, likes: $likes, createdAt: $createdAt}';
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.userPhotoURL != null && this.userPhotoURL?.isNotEmpty == true) {
      object['userPhotoURL'] = this.userPhotoURL;
    }
    if (this.createdEmail != null && this.createdEmail?.isNotEmpty == true) {
      object['createdEmail'] = this.createdEmail;
    }
    if (this.comment != null && this.comment?.isNotEmpty == true) {
      object['comment'] = this.comment;
    }
    if (this.fullName != null && this.fullName?.isNotEmpty == true) {
      object['fullName'] = this.fullName;
    }
    if (this.feedId != null && this.feedId?.isNotEmpty == true) {
      object['feedId'] = this.feedId;
    }
    if (this.createdAt != null) {
      object['createdAt'] = this.createdAt;
    }
    if (this.likes != null) {
      object['likes'] = this.likes;
    } else
      object['likes'] = [];
    if (this.mentions != null && this.mentions?.isNotEmpty == true) {
      object['mentions'] = this.mentions;
    } else {
      object['mentions'] = [];
    }
    if (this.comments != null && this.comments?.isNotEmpty == true) {
      object['comments'] =
          List<dynamic>.from(comments?.map((x) => x.toMap()) ?? []);
    } else {
      object['comments'] = [];
    }
    return object;
  }
}

class CommentsList {
  List<Comments> comments = [];
  bool loading = false;
  CommentsList();

  add(comment) {
    this.comments.add(comment);
  }

  removeall() {
    this.comments = [];
  }

  List<Comments> get getComments => comments;
}
