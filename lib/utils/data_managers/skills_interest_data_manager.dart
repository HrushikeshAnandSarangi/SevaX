import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

Future<List<String>> getSkillsForTimebank({
  @required String timebankId,
}) async {
  log('getSkillsForTimebankId: $timebankId');
  try {
    QuerySnapshot data =
        await Firestore.instance.collection('constants').getDocuments();
    List dataList = data.documents
        .where((document) => document.documentID == timebankId)
        .map((document) => document.data)
        .toList();

    Map dataMap = dataList != null && dataList.isNotEmpty ? dataList.first : {};

    return dataMap.containsKey('skills')
        ? List.castFrom(dataMap['skills'])
        : null;
  } catch (error) {
    log('getSkillsForTimebank: error: $error');
    return null;
  }
}

Future<List<String>> getInterestsForTimebank({
  @required String timebankId,
}) async {
  log('getSkillsForTimebankId: $timebankId');
  try {
    QuerySnapshot data =
        await Firestore.instance.collection('constants').getDocuments();
    List dataList = data.documents
        .where((document) => document.documentID == timebankId)
        .map((document) => document.data)
        .toList();

    Map dataMap = dataList != null && dataList.isNotEmpty ? dataList.first : {};

    return dataMap.containsKey('interests')
        ? List.castFrom(dataMap['interests'])
        : null;
  } catch (error) {
    log('getInterestsForTimebank: error: $error');
    return null;
  }
}
