class NewsModel {
    String id;
    String title;
    String subHeading;
    String description;
    String creatorId;
    String photoUrl;
    String photoCredits;
    int createdAt;
    List<String> likes;
    EntityModel entityModel;

    NewsModel({
        this.id,
        this.title,
        this.subHeading,
        this.description,
        this.creatorId,
        this.photoUrl,
        this.photoCredits,
        this.createdAt,
        this.likes,
        this.entityModel,
    });

    factory NewsModel.fromMap(Map<String, dynamic> json) => new NewsModel(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        subHeading: json["sub_heading"] == null ? null : json["sub_heading"],
        description: json["description"] == null ? null : json["description"],
        creatorId: json["creator_id"] == null ? null : json["creator_id"],
        photoUrl: json["photo_url"] == null ? null : json["photo_url"],
        photoCredits: json["photo_credits"] == null ? null : json["photo_credits"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        likes: json["likes"] == null ? null : new List<String>.from(json["likes"].map((x) => x)),
        entityModel: json["entity_model"] == null ? null : EntityModel.fromMap(json["entity_model"]),
    );

    Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "sub_heading": subHeading == null ? null : subHeading,
        "description": description == null ? null : description,
        "creator_id": creatorId == null ? null : creatorId,
        "photo_url": photoUrl == null ? null : photoUrl,
        "photo_credits": photoCredits == null ? null : photoCredits,
        "created_at": createdAt == null ? null : createdAt,
        "likes": likes == null ? null : new List<dynamic>.from(likes.map((x) => x)),
        "entity_model": entityModel == null ? null : entityModel.toMap(),
    };
}

class EntityModel {
  String id;
  EntityType type;

  EntityModel({this.type, this.id});

  EntityModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('id')) {
      this.id = map['id'];
    }

    if (map.containsKey('type')) {
      String entityTypeString = map['type'];
      switch (entityTypeString) {
        case 'timebanks':
          this.type = EntityType.timebank;
          break;
        case 'projects':
          this.type = EntityType.projects;
          break;
        case 'global':
          this.type = EntityType.global;
          break;
        default:
          this.type = EntityType.global;
          break;
      }
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> obj = {};

    if (this.id != null && this.id.isNotEmpty) {
      obj['id'] = this.id;
    }

    if (this.type != null) {
      switch (this.type) {
        case EntityType.projects:
          obj['type'] = 'projects';
          break;
        case EntityType.timebank:
          obj['type'] = 'timebanks';
          break;
        case EntityType.global:
          obj['type'] = 'global';
          break;
        default:
          obj['type'] = 'global';
          break;
      }
    } else {
      obj['type'] = 'global';
    }

    return obj;
  }
}

enum EntityType { timebank, projects, global }
