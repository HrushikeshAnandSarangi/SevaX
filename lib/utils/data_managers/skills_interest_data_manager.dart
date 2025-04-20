import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import '../search_manager.dart';

Future<List<String>> getSkillsForTimebank({
  required String timebankId,
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
        : <String>[];
  } catch (error) {
    log('getSkillsForTimebank: error: $error');
    return null!;
  }
}

Future<List<String>> getInterestsForTimebank({
  required String timebankId,
}) async {
  log('getInterestsForTimebankId: $timebankId');
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
        : <String>[];
  } catch (error) {
    log('getInterestsForTimebank: error: $error');
    return <String>[];
  }
}

Future<Map<String, dynamic>> getUserSkillsInterests({
  List<dynamic>? skillsIdList,
  List<dynamic>? interestsIdList,
  String? languageCode,
}) async {
  List<String> skillsarr, interestsarr;

  skillsarr = [];
  interestsarr = [];
  Map<String, dynamic> resultMap = HashMap();

  if (skillsIdList != null && skillsIdList.length != 0) {
    skillsarr = await SearchManager.getSkills(
        skillsList: List<String>.from(skillsIdList),
        languageCode: languageCode!);

    resultMap["skills"] = skillsarr;
  }

  if (interestsIdList != null && interestsIdList.length != 0) {
    interestsarr = await SearchManager.getInterests(
        interestList: List<String>.from(interestsIdList),
        languageCode: languageCode!);

    resultMap["interests"] = interestsarr;
  }
  return resultMap;
}
