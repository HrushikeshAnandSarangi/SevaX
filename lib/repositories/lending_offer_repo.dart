import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/new_baseline/models/amenities_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_item_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_place_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/extensions.dart';

class LendingOffersRepo {
  static Future<List<AmenitiesModel>> getAllAmenities() async {
    List<AmenitiesModel> modelList = [];
    await CollectionRef.amenities.get().then((data) {
      data.docs.forEach((document) {
        AmenitiesModel model = AmenitiesModel.fromMap(document.data());
        modelList.add(model);
      });
    });
    return modelList;
  }

  static Future<List<LendingModel>> getAllLendingPlaces(
      {String creatorId}) async {
    List<LendingModel> modelList = [];
    await CollectionRef.lendingItems
      ..where('creatorId', isEqualTo: creatorId).get().then((data) {
        data.docs.forEach((document) {
          LendingModel model = LendingModel.fromMap(document.data());
          modelList.add(model);
        });
      });
    return modelList;
  }

  static Future<void> addAmenitiesToDb({
    String id,
    String title,
    String languageCode,
  }) async {
    await CollectionRef.skills.doc(id).set(
      {'title_' + languageCode ?? 'en': title?.firstWordUpperCase(), 'id': id},
    );
  }

  static Future<void> addNewLendingPlace({LendingModel model}) async {
    await CollectionRef.lendingItems.doc(model.id).set(model.toMap());
  }

  static Future<void> updateNewLendingPlace({LendingModel model}) async {
    await CollectionRef.lendingItems.doc(model.id).update(model.toMap());
  }

  static Future<void> addNewLendingItem({LendingModel model}) async {
    await CollectionRef.lendingItems.doc(model.id).set(model.toMap());
  }

  static Future<void> updateNewLendingItem({LendingModel model}) async {
    await CollectionRef.lendingItems.doc(model.id).update(model.toMap());
  }
}
