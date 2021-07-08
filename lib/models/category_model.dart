//class CategoryModel {
//  CategoryModel({
//    this.id,
//    this.category,
//    this.subCategories,
//    this.selectedSubCategories,
//    this.selectedCategories,
//  });
//
//  String id;
//  String category;
//  List<String> subCategories;
//  List<String> selectedSubCategories;
//  List<String> selectedCategories;
//
//  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
//        id: json["id"],
//        category: json["category"],
//        subCategories: List<String>.from(json["subCategories"].map((x) => x)),
//      );
//
//  Map<String, dynamic> toJson() => {
//        "id": id,
//        "category": category,
//        "subCategories": List<dynamic>.from(subCategories.map((x) => x)),
//      };
//}

class CategoryModel {
  CategoryModel({
    this.categoryId,
    this.title_en,
    this.type,
    this.typeId,
    this.logo,
    this.creatorId,
    this.creatorEmail,
  });

  String categoryId;
  String title_en;
  CategoryType type;
  String typeId;
  String logo;
  String creatorId;
  String creatorEmail;

  factory CategoryModel.fromMap(Map<String, dynamic> json) => CategoryModel(
        categoryId: json["categoryId"] == null ? null : json["categoryId"],
        title_en: json["title_en"] == null ? null : json["title_en"],
        type: json["type"] == null
            ? null
            : json["type"] == 'category'
                ? CategoryType.CATEGORY
                : CategoryType.SUB_CATEGORY,
        typeId: json["typeId"] == null ? null : json["typeId"],
        logo: json.containsKey('logo') ? json['logo'] : null,
        creatorId: json.containsKey('creatorId') ? json['creatorId'] : null,
        creatorEmail:
            json.containsKey('creatorEmail') ? json['creatorEmail'] : null,
      );

  Map<String, dynamic> toMap() => {
        "categoryId": categoryId == null ? null : categoryId,
        "title_en": title_en == null ? null : title_en,
        "type": type == null
            ? null
            : type == CategoryType.CATEGORY
                ? 'category'
                : 'subCategory',
        "typeId": typeId == null ? null : typeId,
        "logo": logo == null ? null : logo,
        "creatorId": creatorId == null ? null : creatorId,
        "creatorEmail": creatorEmail == null ? null : creatorEmail,
      };
}

enum CategoryType { CATEGORY, SUB_CATEGORY }
