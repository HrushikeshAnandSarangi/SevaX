import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/models/data_model.dart';

class NewsModel extends DataModel {
  String id;
  String title;
  String subheading;
  String description;
  String email;
  String fullName;
  String sevaUserId;
  String newsImageUrl;
  String newsDocumentUrl;
  String newsDocumentName;
  String photoCredits;
  int postTimestamp;
  GeoFirePoint location;
  EntityModel entity;
  List<String> likes;
  List<String> reports;
  String root_timebank_id;
  String placeAddress;
  bool isPinned;

  List<String> urlsFromPost = List();
  List<String> hashTags = List();

  String userPhotoURL;
  String imageScraped = "NoData";

  NewsModel(
      {this.id,
      this.title,
      this.subheading,
      this.description,
      this.email,
      this.fullName,
      this.sevaUserId,
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
      this.newsDocumentUrl});

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    if (this.title != null && this.title.isNotEmpty) {
      map['title'] = this.title;
    }

    if (this.description != null && this.description.isNotEmpty) {
      map['description'] = this.description;
    }

    if (this.subheading != null && this.subheading.isNotEmpty) {
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

    if (this.root_timebank_id != null && this.root_timebank_id.isNotEmpty) {
      map['root_timebank_id'] = this.root_timebank_id;
    }
    if (this.id != null && this.id.isNotEmpty) {
      map['id'] = this.id;
    }
    if (this.email != null && this.email.isNotEmpty) {
      map['email'] = this.email;
    }
    if (this.fullName != null && this.fullName.isNotEmpty) {
      map['fullname'] = this.fullName;
    }
    if (this.sevaUserId != null && this.sevaUserId.isNotEmpty) {
      map['sevauserid'] = this.sevaUserId;
    }
    if (this.newsImageUrl != null && this.newsImageUrl.isNotEmpty) {
      map['newsimageurl'] = this.newsImageUrl;
    }
    if (this.photoCredits != null && this.photoCredits.isNotEmpty) {
      map['photocredits'] = this.photoCredits;
    }
    if (this.postTimestamp != null) {
      map['posttimestamp'] = this.postTimestamp;
    }
    if (this.location != null) {
      map['location'] = this.location.data;
    }

    if (this.isPinned != null) {
      map['pinned'] = this.isPinned;
    }
    if (this.entity != null) {
      map['entity'] = this.entity.toMap();
    }
    if (this.likes != null) {
      map['likes'] = this.likes;
    } else
      map['likes'] = [];

    if (this.reports != null) {
      map['reports'] = this.reports;
    } else
      map['reports'] = [];

    if (this.newsDocumentName != null && this.newsDocumentName.isNotEmpty) {
      map['newsDocumentName'] = this.newsDocumentName;
    }
    if (this.newsDocumentUrl != null && this.newsDocumentUrl.isNotEmpty) {
      map['newsDocumentUrl'] = this.newsDocumentUrl;
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
      this.location = Geoflutterfire()
          .point(latitude: geoPoint.latitude, longitude: geoPoint.longitude);
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
      this.location = Geoflutterfire()
          .point(latitude: geoPoint.latitude, longitude: geoPoint.longitude);
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
  }

  @override
  String toString() {
    return 'NewsModel{id: $id, title: $title, subheading: $subheading, description: $description, email: $email, fullName: $fullName, sevaUserId: $sevaUserId, newsImageUrl: $newsImageUrl, photoCredits: $photoCredits, postTimestamp: $postTimestamp, location: $location, entity: $entity, likes: $likes, reports: $reports, root_timebank_id: $root_timebank_id, placeAddress: $placeAddress, isPinned: $isPinned, urlsFromPost: $urlsFromPost, hashTags: $hashTags, userPhotoURL: $userPhotoURL, imageScraped: $imageScraped}';
  }
}

class EntityModel extends DataModel {
  String entityId;
  String entityName;
  EntityType entityType;

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

    if (this.entityId != null && this.entityId.isNotEmpty) {
      obj['entityId'] = this.entityId;
    }

    if (this.entityName != null && this.entityName.isNotEmpty) {
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
