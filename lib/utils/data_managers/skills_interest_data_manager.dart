import 'dart:collection';
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

Future<Map<String, dynamic>> getUserSkillsInterests({
  List<dynamic> skillsIdList,
  List<dynamic> interestsIdList,
}) async {
  List<String> skillsarr, interestsarr;

  skillsarr = List();
  interestsarr = List();
  QuerySnapshot queryData1, queryData2;
  Map<String, dynamic> resultMap = HashMap();

  if (skillsIdList != null && skillsIdList.length != 0) {
    queryData1 = await Firestore.instance.collection('skills').getDocuments();
    queryData1.documents.forEach((docsnapshot) {
      if (skillsIdList.contains(docsnapshot.documentID)) {
        if (docsnapshot.data != null) skillsarr.add(docsnapshot.data["name"]);
      }
    });

    resultMap["skills"] = skillsarr;
  }

  if (interestsIdList != null && interestsIdList.length != 0) {
    queryData2 =
        await Firestore.instance.collection('interests').getDocuments();
    queryData2.documents.forEach((docsnapshot) {
      if (interestsIdList.contains(docsnapshot.documentID)) {
        interestsarr.add(docsnapshot.data["name"]);
      }
    });
    resultMap["interests"] = interestsarr;
  }
  return resultMap;
}
