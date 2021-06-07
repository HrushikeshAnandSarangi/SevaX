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
  });

  String categoryId;
  String title_en;
  CategoryType type;
  String typeId;
  String logo;

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
      );
}

enum CategoryType { CATEGORY, SUB_CATEGORY }
