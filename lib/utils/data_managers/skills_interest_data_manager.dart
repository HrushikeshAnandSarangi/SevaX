import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import '../search_manager.dart';

Future<List<String>> getSkillsForTimebank({
  @required String timebankId,
}) async {
  log('getSkillsForTimebankId: $timebankId');
  try {
    QuerySnapshot data =
        await FirebaseFirestore.instance.collection('constants').get();
    List dataList = data.docs
        .where((document) => document.id == timebankId)
        .map((document) => document.data())
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
        await FirebaseFirestore.instance.collection('constants').get();
    List dataList = data.docs
        .where((document) => document.id == timebankId)
        .map((document) => document.data())
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
  String languageCode,
}) async {
  List<String> skillsarr, interestsarr;

  skillsarr = [];
  interestsarr = [];
  QuerySnapshot queryData1, queryData2;
  Map<String, dynamic> resultMap = HashMap();

  if (skillsIdList != null && skillsIdList.length != 0) {
    skillsarr = await SearchManager.getSkills(
        skillsList: skillsIdList, languageCode: languageCode);
    //queryData1 = await CollectionRef.skills.get();
//    queryData1.docs.forEach((docsnapshot) {
//      if (skillsIdList.contains(docsnapshot.id)) {
//        if (docsnapshot.data != null)
//          skillsarr.add(docsnapshot.data[languageCode] != null
//              ? docsnapshot.data[languageCode]
//              : docsnapshot.data["name"]);
//      }
//    });

    resultMap["skills"] = skillsarr;
  }

  if (interestsIdList != null && interestsIdList.length != 0) {
    interestsarr = await SearchManager.getInterests(
        interestList: interestsIdList, languageCode: languageCode);
//    queryData2 =
//        await CollectionRef.interests.get();
//    queryData2.docs.forEach((docsnapshot) {
//      if (interestsIdList.contains(docsnapshot.id)) {
//        interestsarr.add(docsnapshot.data[languageCode] != null
//            ? docsnapshot.data[languageCode]
//            : docsnapshot.data["name"]);
//      }
//    });

    resultMap["interests"] = interestsarr;
  }
  return resultMap;
}
