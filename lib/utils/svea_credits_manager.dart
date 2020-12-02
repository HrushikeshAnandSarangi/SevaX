import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

import 'app_config.dart';

class SevaCreditLimitManager {
  static Future<double> getNegativeThresholdForCommunity(communityId) async {
    var communityDoc = await Firestore.instance
        .collection("communities")
        .document(communityId)
        .get();
    CommunityModel commModel = CommunityModel(communityDoc.data);
    return commModel.negativeCreditsThreshold;
  }

  static Future<double> getMemberBalancePerTimebank(
      String userSevaId, String timebankId) async {
    double sevaCoinsBalance = 0.0;

    var snapTransactions = await Firestore.instance
        .collection('transactions')
        .where("timebankid", isEqualTo: timebankId)
        .where("isApproved", isEqualTo: true)
        .where('transactionbetween', arrayContains: userSevaId)
        .orderBy("timestamp", descending: true)
        .getDocuments();

    TransactionModel transactionModel;
    snapTransactions.documents.forEach((transactionDoc) {
      transactionModel = TransactionModel.fromMap(transactionDoc.data);
      if (transactionModel.from == userSevaId) {
        //lost credits
        sevaCoinsBalance -= transactionModel.credits > 0
            ? transactionModel.credits
            : transactionModel.credits.abs();
      } else {
        //gained credits
        sevaCoinsBalance += transactionModel.credits > 0
            ? transactionModel.credits
            : transactionModel.credits.abs();
      }
    });

    return sevaCoinsBalance;
  }

  static Future<bool> hasSufficientCreditsIncludingRecurring({
    String userId,
    double credits,
    int recurrences,
    bool isRecurring,
  }) async {
    var sevaCoinsBalance = await getMemberBalance(userId);
    log("on mode recurrence count isss $recurrences");
    var lowerLimit = 50;
    try {
      lowerLimit =
          json.decode(AppConfig.remoteConfig.getString('user_minimum_balance'));
    } on Exception {
      //  Crashlytics.instance.log(error.toString());
    }
    var maxAvailableBalance = (sevaCoinsBalance + lowerLimit ?? 50);
    var creditsNew = isRecurring ? credits * recurrences : credits;

    return maxAvailableBalance - (creditsNew) >= 0;
  }

  static Future<double> getMemberBalance(userId) async {
    double sevaCoins = 0;
    var userModel = await FirestoreManager.getUserForIdFuture(
      sevaUserId: userId,
    );
    sevaCoins = userModel.currentBalance;

    return double.parse(sevaCoins.toStringAsFixed(2));
  }

  static Future<bool> hasSufficientCredits({
    @required String userId,
    @required double credits,
    @required String communityId,
    @required String timebankId,
  }) async {
//  var sevaCoinsBalance = await getMemberBalance(userId);
    double sevaCoinsBalance =
        await getMemberBalancePerTimebank(userId, timebankId);
    double lowerLimit = 50;
    double timebankUserNegativeLimit =
        await getNegativeThresholdForCommunity(communityId);

    try {
      lowerLimit =
          json.decode(AppConfig.remoteConfig.getString('user_minimum_balance'));
    } on Exception {
      // Crashlytics.instance.log(error.toString());
    }
    var maxAvailableBalance = (sevaCoinsBalance + lowerLimit ?? 50);

    return maxAvailableBalance - credits >= timebankUserNegativeLimit;
  }
}
